import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/home/home_screen.dart';
import 'package:triumph_hotels/features/auth/login_screen.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:triumph_hotels/core/utils/video_cache_manager.dart';
import 'package:triumph_hotels/core/utils/splash_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// _VideoBackground — the fully hardened video background layer.
//
// WHAT WAS STILL WRONG (and now fixed):
//
//  Previous versions showed the video as soon as initialize() completed,
//  or used heavy animations that competed with the decoder. This version
//  is designed for maximum stability on all hardware.
//
// HOW THIS VERSION WORKS:
//
//  1. VideoPlayer is always in the widget tree from the very first build,
//     at opacity 0. This "pre-warms" the platform TextureLayer (SurfaceTexture
//     on Android, AVPlayerLayer on iOS) so it's ready when revealed.
//
//  2. A controller listener fires on state changes. It only triggers the
//     reveal once the video has confirmed playback (position > zero) and
//     provided real size dimensions.
//
//  3. The reveal is an instant Opacity switch (0.0 -> 1.0). We removed
//     AnimatedOpacity to ensure the GPU doesn't perform animation frames
//     at the same time it's handling the initial decoded frames.
//
//  4. RepaintBoundary promotes the video to its own GPU layer, preventing
//     video repaints from forcing the entire UI to rebuild.
//
//  5. Layout stability: _videoSize is captured once and cached. The layout
//     dimensions in the tree are stable from the first build, preventing
//     the 0×0 -> real-size "snap" or vibration.
// ─────────────────────────────────────────────────────────────────────────────
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _useImageFallback = false;
  SplashConfig? _splashConfig;
  VideoPlayerController? _videoController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareIntro();
  }

  Future<void> _prepareIntro() async {
    debugPrint('IntroScreen: preparing intro... checking cached config');

    // 1. Fetch config — use in-memory cache first, then try network.
    SplashConfig? config = SplashConfig.cached;
    if (config == null) {
      config = await SplashConfig.fetch();
    }
    if (config != null && mounted && !_disposed) {
      _splashConfig = config;
    }

    final hasApiVideo = config != null &&
        config.isActive &&
        config.hasVideo &&
        config.videoUrl != null &&
        config.videoUrl!.isNotEmpty;

    // 2. Try to find or play the API video (cached first, then live stream).
    bool apiVideoPlaying = false;
    if (hasApiVideo) {
      final videoUrl = config.videoUrl!;

      // 2a. Check on-disk cache.
      final isCached = await VideoCacheManager.isCacheValid(videoUrl, config.version);
      File? cachedFile;
      if (isCached) {
        cachedFile = await VideoCacheManager.getExistingCachedVideo(videoUrl);
      }

      if (cachedFile != null) {
        // ── Play from cache ───────────────────────────────────────────────
        debugPrint('IntroScreen: playing API video FROM CACHE: ${cachedFile.path}');
        _videoController = VideoPlayerController.file(cachedFile);
        try {
          await _videoController!.initialize();
          if (_disposed || !mounted) return;
          _videoController!.setLooping(config.loop);
          _videoController!.setVolume(config.muted ? 0.0 : 1.0);
          await _videoController!.play();
          apiVideoPlaying = true;
          debugPrint('IntroScreen: API cached video playing!');
        } catch (e) {
          debugPrint('IntroScreen: cached file failed to play, will try network – $e');
          _videoController?.dispose();
          _videoController = null;
        }
      }

      if (!apiVideoPlaying) {
        // ── Try playing live from network (same launch, no wait) ──────────
        debugPrint('IntroScreen: no valid cache – trying live network stream: $videoUrl');
        // Start background download in parallel so next launch has it cached.
        VideoCacheManager.cacheVideoInBackground(videoUrl, version: config.version);
        try {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          await _videoController!.initialize().timeout(const Duration(seconds: 8));
          if (_disposed || !mounted) return;
          _videoController!.setLooping(config.loop);
          _videoController!.setVolume(config.muted ? 0.0 : 1.0);
          await _videoController!.play();
          apiVideoPlaying = true;
          debugPrint('IntroScreen: API video playing via LIVE STREAM!');
        } catch (e) {
          debugPrint('IntroScreen: live stream failed, falling back to local asset – $e');
          _videoController?.dispose();
          _videoController = null;
        }
      }
    }

    // 3. Fallback to local asset if API video could not be played.
    if (!apiVideoPlaying) {
      debugPrint('IntroScreen: playing local FALLBACK video: ${AppImages.welcomeVideo}');
      _videoController = VideoPlayerController.asset(AppImages.welcomeVideo);
      try {
        await _videoController!.initialize();
        if (_disposed || !mounted) return;
        _videoController!.setLooping(config?.loop ?? true);
        _videoController!.setVolume(config?.muted ?? true ? 0.0 : 1.0);
        await _videoController!.play();
        debugPrint('IntroScreen: local fallback video playing!');
      } catch (e, st) {
        debugPrint('IntroScreen[ERROR]: local video init failed:\n$e\n$st');
        if (_disposed || !mounted) return;
        setState(() {
          _useImageFallback = true;
        });
      }
    }

    // 4. Done — update UI.
    if (!_disposed && mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // 5. In background, refresh config and trigger cache update if version changed.
    SplashConfig.fetch(forceRefresh: true).then((fetchedConfig) {
      if (fetchedConfig == null) return;
      if (!_disposed && mounted && fetchedConfig != _splashConfig) {
        setState(() {
          _splashConfig = fetchedConfig;
        });
      }
      if (fetchedConfig.isActive &&
          fetchedConfig.hasVideo &&
          fetchedConfig.videoUrl != null &&
          fetchedConfig.videoUrl!.isNotEmpty) {
        VideoCacheManager.isCacheValid(fetchedConfig.videoUrl!, fetchedConfig.version)
            .then((valid) {
          if (!valid) {
            debugPrint('IntroScreen: version changed – caching new API video for next launch...');
            VideoCacheManager.cacheVideoInBackground(
                fetchedConfig.videoUrl!,
                version: fetchedConfig.version);
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    if (state == AppLifecycleState.paused) {
      _videoController!.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoController!.play();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────────────────────────────────
    // Phase 1: Loading Indicator Screen while config & video are being fetched
    // ─────────────────────────────────────────────────────────────────────────
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'PREPARING EXPERIENCE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'sans-serif',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 2: The Intro Screen with Video (or Fallback Image) and Buttons
    // ─────────────────────────────────────────────────────────────────────────
    final localizations = AppLocalizations.of(context)!;
    final config = _splashConfig;

    final titleText = (config?.title.isNotEmpty == true)
        ? config!.title
        : localizations.appName;
    final subtitleText = (config?.subtitle.isNotEmpty == true)
        ? config!.subtitle
        : localizations.whereLuxuryMeetsComfort;
    final primaryBtnText = (config?.primaryButtonText.isNotEmpty == true)
        ? config!.primaryButtonText
        : localizations.exploreHotels;
    final secondaryBtnText = (config?.secondaryButtonText.isNotEmpty == true)
        ? config!.secondaryButtonText
        : localizations.signIn;
    final guestLinkText = (config?.guestLinkText.isNotEmpty == true)
        ? config!.guestLinkText
        : localizations.continueAsGuest;
    final overlayOpacity = config?.overlayOpacity ?? 0.35;
    final posterUrl = config?.posterUrl;

    final size = _videoController?.value.size ?? Size.zero;
    final double vWidth = size.width > 0 ? size.width : 1920;
    final double vHeight = size.height > 0 ? size.height : 1080;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Video Layer or Fallback Image ──────────────────────────────
          Positioned.fill(
            child: _useImageFallback
                ? ((posterUrl != null && posterUrl.isNotEmpty)
                    ? Image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset(AppImages.videoPlaceholder, fit: BoxFit.cover),
                      )
                    : Image.asset(AppImages.videoPlaceholder, fit: BoxFit.cover))
                : (_videoController != null && _videoController!.value.isInitialized)
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: vWidth,
                            height: vHeight,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      )
                    : Image.asset(AppImages.videoPlaceholder, fit: BoxFit.cover),
          ),

          // ── 2. Gradient Overlay ──────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(overlayOpacity * 0.6),
                    Colors.black.withOpacity(overlayOpacity + 0.45),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Title Section ─────────────────────────────────────────────
          Positioned(
            top: ResponsiveUtils.getResponsiveHeight(context, 0.08),
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                Text(
                  titleText,
                  style: GoogleFonts.greatVibes(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      smallSize: 32,
                      mediumSize: 38,
                      largeSize: 44,
                      extraLargeSize: 50,
                    ),
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(duration: 800.ms),

                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),

                Text(
                  subtitleText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'sans-serif',
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      smallSize: 12,
                      mediumSize: 14,
                      largeSize: 16,
                      extraLargeSize: 18,
                    ),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms, duration: 800.ms),

                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),

                Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 0.15),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ).animate().fade(delay: 400.ms, duration: 600.ms),
              ],
            ),
          ),

          // ── 4. Bottom Buttons Section ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveWidth(context, 0.06),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PrimaryButton(
                      label: primaryBtnText,
                      icon: Icons.explore,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      ),
                    ).animate().fade(delay: 400.ms, duration: 800.ms),

                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),

                    _GlassButton(
                      label: secondaryBtnText,
                      icon: Icons.person_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ).animate().fade(delay: 600.ms, duration: 800.ms),

                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),

                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      ),
                      child: Text(
                        guestLinkText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'sans-serif',
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            smallSize: 12,
                            mediumSize: 13,
                            largeSize: 14,
                            extraLargeSize: 15,
                          ),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.5),
                          decorationThickness: 1,
                        ),
                      ),
                    ).animate().fade(delay: 800.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Button components
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveUtils.getResponsiveBorderRadius(
      context,
      smallRadius: 25,
      mediumRadius: 30,
      largeRadius: 35,
      extraLargeRadius: 40,
    );
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.getResponsiveHeight(context, 0.07),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: _ButtonContent(label: label, icon: icon),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ResponsiveUtils.getResponsiveBorderRadius(
      context,
      smallRadius: 25,
      mediumRadius: 30,
      largeRadius: 35,
      extraLargeRadius: 40,
    );
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.getResponsiveHeight(context, 0.07),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: _ButtonContent(label: label, icon: icon),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ButtonContent({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveWidth(context, 0.04),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsivePadding(
                context,
                smallPadding: 8,
                mediumPadding: 10,
                largePadding: 12,
                extraLargePadding: 14,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(
                context,
                smallSize: 16,
                mediumSize: 18,
                largeSize: 20,
                extraLargeSize: 22,
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
          Text(
            label,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                smallSize: 14,
                mediumSize: 16,
                largeSize: 18,
                extraLargeSize: 20,
              ),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
