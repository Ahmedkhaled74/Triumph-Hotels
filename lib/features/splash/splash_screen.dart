import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:triumph_hotels/core/utils/video_cache_manager.dart';
import 'package:triumph_hotels/core/utils/splash_config.dart';
import 'package:triumph_hotels/features/intro/intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  bool _videoReady = false;  // true = show video (instant, no animation)
  bool _navigated = false;

  void _onControllerUpdate() {
    if (_navigated) return;
    final value = _controller.value;

    // Show video instantly once first real decoded frame is confirmed.
    if (!_videoReady &&
        value.isPlaying &&
        value.position > Duration.zero &&
        value.size != Size.zero) {
      if (mounted) {
        setState(() {
          _videoReady = true;
        });
      }
    }

    // Navigate when video finishes completely.
    if (_videoReady &&
        value.duration > Duration.zero &&
        value.position >= value.duration &&
        !value.isPlaying) {
      _navigateToIntro();
    }
  }

  void _navigateToIntro() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _controller.removeListener(_onControllerUpdate);
    // Instant navigation — no transition animation.
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const IntroScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Pre-fetch splash config from API while the splash logo video plays.
    SplashConfig.fetch().then((config) {
      if (config == null || !config.isActive || !config.hasVideo || config.videoUrl == null || config.videoUrl!.isEmpty) {
        return;
      }
      final videoUrl = config.videoUrl!;
      VideoCacheManager.isCacheValid(videoUrl, config.version).then((valid) {
        if (!valid) {
          VideoCacheManager.cacheVideoInBackground(videoUrl, version: config.version);
        }
      });
    });

    _controller = VideoPlayerController.asset(AppImages.splashVideo);
    _controller.addListener(_onControllerUpdate);

    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.setLooping(false);
      _controller.setVolume(1.0);
      _controller.play();

      // Safety fallback in case video never ends or listener never fires.
      final duration = _controller.value.duration;
      final fallback = duration > Duration.zero
          ? duration + const Duration(seconds: 2)
          : const Duration(seconds: 6);
      Future.delayed(fallback, () {
        if (mounted && !_navigated) _navigateToIntro();
      });
    }).catchError((Object e) {
      debugPrint('Splash video error: $e');
      Future.delayed(const Duration(seconds: 2), () => _navigateToIntro());
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine dimensions
    final size = _controller.value.size;
    final double vWidth = size.width > 0 ? size.width : 1920;
    final double vHeight = size.height > 0 ? size.height : 1080;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BLACK BACKGROUND
          const ColoredBox(color: Colors.black),

          // 2. THE VIDEO LAYER
          // We keep it in the tree and use Opacity to prevent any Surface shifts
          IgnorePointer(
            child: Opacity(
              opacity: _videoReady ? 1.0 : 0.0,
              child: RepaintBoundary(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.contain, // Maintain aspect ratio for splash
                    child: SizedBox(
                      width: vWidth,
                      height: vHeight,
                      child: Stack(
                        children: [
                          VideoPlayer(_controller),

                          // THE "GUTTER" MASK:
                          // Covers potential chroma artifacts on some decoders
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 4,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
