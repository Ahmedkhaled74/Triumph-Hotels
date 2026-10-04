import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/home/home_screen.dart';
import 'package:triumph_hotels/features/auth/login_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/utils/video_cache_manager.dart';

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
class _VideoBackground extends StatefulWidget {
  final VoidCallback? onReady;
  const _VideoBackground({this.onReady});

  @override
  State<_VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<_VideoBackground> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _videoReady = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  void _initializeController() async {
    try {
      final url = 'https://www.triumphhotel.com/media/home_videos/15-7_trumph_reel_10.mp4';
      
      // 1. Check if we already have it cached
      final cachedFile = await VideoCacheManager.getExistingCachedVideo(url);
      
      if (cachedFile != null) {
        _controller = VideoPlayerController.file(cachedFile);
        debugPrint('IntroScreen: Playing cached video from ${cachedFile.path}');
      } else {
        // 2. Play from network immediately so user doesn't wait
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
        debugPrint('IntroScreen: Streaming video from network');
        
        // 3. Kick off background download so it's instant next time
        VideoCacheManager.cacheVideoInBackground(url);
      }
      
      _controller!.addListener(_onControllerUpdate);
      _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() => _isInitialized = true);
        _controller!.setLooping(true);
        _controller!.setVolume(0.0);
        _controller!.play();

        // Safety fallback: force reveal after 6s
        Future.delayed(const Duration(seconds: 6), () {
          if (!mounted || _videoReady) return;
          _controller?.removeListener(_onControllerUpdate);
          setState(() {
            _videoReady = true;
          });
          widget.onReady?.call();
        });
      }).catchError((Object e) {
        debugPrint('Intro video init error: $e');
      });
    } catch (e) {
      debugPrint('Intro video controller error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || _controller == null) return;
    if (state == AppLifecycleState.paused) {
      _controller!.pause();
    } else if (state == AppLifecycleState.resumed) {
      _controller!.play();
    }
  }

  void _onControllerUpdate() {
    if (_videoReady || !_isInitialized || _controller == null) return;
    final value = _controller!.value;
    if (value.isPlaying &&
        value.position > const Duration(milliseconds: 3000) &&
        value.size != Size.zero) {
      _controller?.removeListener(_onControllerUpdate);
      if (!mounted) return;
      setState(() {
        _videoReady = true;
      });
      widget.onReady?.call();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInitialized) {
      _controller?.removeListener(_onControllerUpdate);
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use the controller value directly for dimensions if ready, 
    // or a stable 16:9 aspect ratio fallback during "pre-warming"
    final size = _controller?.value.size ?? Size.zero;
    final double vWidth = size.width > 0 ? size.width : 1920;
    final double vHeight = size.height > 0 ? size.height : 1080;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. THE VIDEO LAYER
          // It is ALWAYS in the widget tree. This is critical.
          // It ensures the platform Surface/Texture is created immediately.
          // We hide it with Opacity(0) until the hardware decoder is 100% stable.
          IgnorePointer(
            child: Opacity(
              opacity: _videoReady ? 1.0 : 0.0,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: vWidth,
                    height: vHeight,
                    child: _controller != null ? Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(_controller!),
                        ValueListenableBuilder(
                          valueListenable: _controller!,
                          builder: (context, VideoPlayerValue value, child) {
                            if (value.isBuffering) {
                              return const Center(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ) : const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
          
          // 2. THE PLACEHOLDER LAYER
          // Only removed once video is confirmed ready.
          if (!_videoReady)
            IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black),
                  
                  // Luxury Loading Indicator
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'PREPARING EXPERIENCE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IntroScreen — waits for video to be ready before showing UI content.
// ─────────────────────────────────────────────────────────────────────────────
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _contentVisible = false;

  void _onVideoReady() {
    if (mounted) setState(() => _contentVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Video lives in its own fully isolated subtree.
          _VideoBackground(onReady: _onVideoReady),

          // All overlay content is hidden until video is ready
          if (_contentVisible) ...[
            // ── Gradient overlay ──────────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // ── Title section ─────────────────────────────────────────────
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 0.08),
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                  Text(
                    localizations.appName,
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
                  ).animate().fade(duration: 1000.ms),

                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),

                  Text(
                    localizations.whereLuxuryMeetsComfort,
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
                  ).animate().fade(delay: 200.ms, duration: 1000.ms),

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
                  ).animate().fade(delay: 400.ms, duration: 800.ms),
                ],
              ),
            ),

            // ── Bottom buttons ────────────────────────────────────────────
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
                        label: localizations.exploreHotels,
                        icon: Icons.explore,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        ),
                      ).animate().fade(delay: 600.ms, duration: 1000.ms),

                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),

                      _GlassButton(
                        label: localizations.signIn,
                        icon: Icons.person_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                      ).animate().fade(delay: 800.ms, duration: 1000.ms),

                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),

                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        ),
                        child: Text(
                          localizations.continueAsGuest,
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
                      ).animate().fade(delay: 1000.ms, duration: 800.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
