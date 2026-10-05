import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:triumph_hotels/core/utils/video_cache_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VideoWelcomeWidget extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const VideoWelcomeWidget({super.key, this.onExploreTap});

  @override
  State<VideoWelcomeWidget> createState() => _VideoWelcomeWidgetState();
}

class _VideoWelcomeWidgetState extends State<VideoWelcomeWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  late PageController _pageController;
  int _currentPage = 0;
  int _currentTestimonial = 0;
  
  final List<String> _testimonials = [
    "An unforgettable luxury experience that exceeded all expectations.",
    "The perfect blend of elegance and comfort. Truly exceptional.",
    "World-class service and stunning accommodations. Highly recommended!",
    "A masterpiece of hospitality. Every detail was perfect.",
  ];
  
  final List<String> _awards = [
    "Five Star Diamond Award",
    "World's Leading Luxury Hotel",
    "Excellence in Hospitality",
    "Guest Choice Award 2024",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeVideo();
    
    // Auto-scroll pages every 8 seconds (reduced from 5 to prevent vibration)
    _startAutoScroll();
    
    // Rotate testimonials every 4 seconds
    _startTestimonialRotation();
  }
  
  void _initializeVideo() async {
    try {
      const url = VideoCacheManager.homeVideoUrl;
      final cachedFile = await VideoCacheManager.getExistingCachedVideo(url);
      
      if (cachedFile != null) {
        _controller = VideoPlayerController.file(cachedFile);
        await _controller!.initialize();
      } else {
        VideoCacheManager.cacheVideoInBackground(url);
        
        try {
          _controller = VideoPlayerController.networkUrl(Uri.parse(url));
          await _controller!.initialize().timeout(const Duration(seconds: 4));
        } catch (_) {
          _controller?.dispose();
          _controller = VideoPlayerController.asset(AppImages.welcomeVideo);
          await _controller!.initialize();
        }
      }

      if (mounted) {
        _controller!.setLooping(true);
        _controller!.setVolume(0.0); // Mute for autoplay
        _controller!.play();
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted && !_initialized) {
        try {
          _controller?.dispose();
          _controller = VideoPlayerController.asset(AppImages.welcomeVideo);
          await _controller!.initialize();
          if (mounted) {
            _controller!.setLooping(true);
            _controller!.setVolume(0.0);
            _controller!.play();
            setState(() {
              _initialized = true;
            });
          }
        } catch (_) {}
      }
    }
  }
  
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _pageController.hasClients) {
        if (_currentPage < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
        _startAutoScroll();
      }
    });
  }
  
  void _startTestimonialRotation() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentTestimonial = (_currentTestimonial + 1) % _testimonials.length;
        });
        _startTestimonialRotation();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Background - Isolated for maximum performance
          if (_initialized)
            RepaintBoundary(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final videoAspectRatio = _controller?.value.aspectRatio ?? 16/9;
                  final screenAspectRatio = constraints.maxWidth / constraints.maxHeight;
                  
                  // Determine how to scale the video based on aspect ratios
                  if (_controller != null && videoAspectRatio > screenAspectRatio) {
                    // Video is wider than screen - fit to height
                    return SizedBox(
                      width: constraints.maxHeight * videoAspectRatio,
                      height: constraints.maxHeight,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    );
                  } else if (_controller != null) {
                    // Video is taller than screen - fit to width
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth / videoAspectRatio,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            )
          else
            Image.asset(
              AppImages.videoPlaceholder,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),

          // Dark Overlay - Simple non-interactive layer
          RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // PageView Content - Isolated for smooth swiping
          RepaintBoundary(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Page 1: Welcome Text
                _buildWelcomePage(screenWidth, screenHeight),
                
                // Page 2: Guest Experiences
                _buildGuestExperiencesPage(screenWidth, screenHeight),
                
                // Page 3: Rewards & Recognition
                _buildRewardsPage(screenWidth, screenHeight),
              ],
            ),
          ),

          // Page Indicators - Lightweight overlay
          Positioned(
            bottom: screenHeight * 0.25,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => 
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
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

  Widget _buildWelcomePage(double screenWidth, double screenHeight) {
    // Responsive calculations for all devices
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    
    // Responsive font sizes
    final welcomeFontSize = isSmallScreen ? screenWidth * 0.08 : 
                           isTablet ? screenWidth * 0.06 : 
                           screenWidth * 0.05;
    final hotelFontSize = isSmallScreen ? screenWidth * 0.12 : 
                         isTablet ? screenWidth * 0.10 : 
                         screenWidth * 0.08;
    final taglineFontSize = isSmallScreen ? screenWidth * 0.06 : 
                            isTablet ? screenWidth * 0.05 : 
                            screenWidth * 0.04;
    final descriptionFontSize = isSmallScreen ? screenWidth * 0.035 : 
                                isTablet ? screenWidth * 0.03 : 
                                screenWidth * 0.025;
    
    // Responsive spacing
    final horizontalPadding = isSmallScreen ? screenWidth * 0.06 : 
                             isTablet ? screenWidth * 0.08 : 
                             screenWidth * 0.10;
    final verticalPadding = isSmallScreen ? screenHeight * 0.06 : 
                           isTablet ? screenHeight * 0.08 : 
                           screenHeight * 0.10;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Welcome to',
            style: GoogleFonts.greatVibes(
              color: Colors.white.withOpacity(0.9),
              fontSize: welcomeFontSize,
              letterSpacing: 1.5,
            ),
          ).animate().fade(duration: 800.ms).slideY(begin: -0.3, end: 0),
         
          const SizedBox(height: 10),
         
          Text(
            'Triumph Hotels',
            style: GoogleFonts.greatVibes(
              color: AppColors.primary,
              fontSize: hotelFontSize,
              fontWeight: FontWeight.w400,
              height: 1.0,
              shadows: [
                Shadow(
                  offset: const Offset(0, 4),
                  blurRadius: 8.0,
                  color: Colors.black.withOpacity(0.6),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 300.ms, duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
         
          const SizedBox(height: 20),
          Divider(
            color: AppColors.primary.withOpacity(0.8),
            thickness: 2,
            indent: isSmallScreen ? screenWidth * 0.20 : screenWidth * 0.25,
            endIndent: isSmallScreen ? screenWidth * 0.20 : screenWidth * 0.25,
          ).animate().scaleX(delay: 600.ms, duration: 600.ms),
          const SizedBox(height: 20),

          Text(
            'Where Luxury Meets Comfort',
            style: GoogleFonts.greatVibes(
              color: Colors.white.withOpacity(0.95),
              fontSize: taglineFontSize,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 800.ms, duration: 800.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 30),
          
          // Brand Philosophy - Responsive container
          Container(
            padding: EdgeInsets.all(isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.03),
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? screenWidth * 0.08 : screenWidth * 0.10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              'Since 1985, we have crafted unforgettable experiences\nwhere every guest becomes family and every stay becomes a memory.',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white.withOpacity(0.9),
                fontSize: descriptionFontSize,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 1000.ms, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildGuestExperiencesPage(double screenWidth, double screenHeight) {
    // Responsive calculations for all devices
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    
    // Responsive font sizes
    final titleFontSize = isSmallScreen ? screenWidth * 0.08 : 
                         isTablet ? screenWidth * 0.07 : 
                         screenWidth * 0.06;
    final testimonialFontSize = isSmallScreen ? screenWidth * 0.04 : 
                                 isTablet ? screenWidth * 0.035 : 
                                 screenWidth * 0.03;
    final guestFontSize = isSmallScreen ? screenWidth * 0.032 : 
                           isTablet ? screenWidth * 0.028 : 
                           screenWidth * 0.025;
    
    // Responsive spacing
    final horizontalPadding = isSmallScreen ? screenWidth * 0.05 : 
                             isTablet ? screenWidth * 0.08 : 
                             screenWidth * 0.10;
    final verticalPadding = isSmallScreen ? screenHeight * 0.06 : 
                           isTablet ? screenHeight * 0.08 : 
                           screenHeight * 0.10;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Guest Experiences',
            style: GoogleFonts.greatVibes(
              color: AppColors.primary,
              fontSize: titleFontSize,
              letterSpacing: 1.5,
            ),
          ).animate().fade(duration: 800.ms).slideY(begin: -0.3, end: 0),
          
          const SizedBox(height: 40),
          
          // Testimonial Container - Responsive
          Container(
            padding: EdgeInsets.all(isSmallScreen ? screenWidth * 0.05 : screenWidth * 0.04),
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? screenWidth * 0.05 : screenWidth * 0.08),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  color: AppColors.primary,
                  size: isSmallScreen ? 28 : 32,
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _testimonials[_currentTestimonial],
                    key: ValueKey(_testimonials[_currentTestimonial]),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: testimonialFontSize,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '- Satisfied Guest',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.primary,
                    fontSize: guestFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 600.ms, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildRewardsPage(double screenWidth, double screenHeight) {
    // Responsive calculations for all devices
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    
    // Responsive font sizes
    final titleFontSize = isSmallScreen ? screenWidth * 0.08 : 
                         isTablet ? screenWidth * 0.07 : 
                         screenWidth * 0.06;
    final awardFontSize = isSmallScreen ? screenWidth * 0.035 : 
                         isTablet ? screenWidth * 0.03 : 
                         screenWidth * 0.025;
    
    // Responsive spacing
    final horizontalPadding = isSmallScreen ? screenWidth * 0.05 : 
                             isTablet ? screenWidth * 0.08 : 
                             screenWidth * 0.10;
    final verticalPadding = isSmallScreen ? screenHeight * 0.06 : 
                           isTablet ? screenHeight * 0.08 : 
                           screenHeight * 0.10;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Awards & Recognition',
            style: GoogleFonts.greatVibes(
              color: AppColors.primary,
              fontSize: titleFontSize,
              letterSpacing: 1.5,
            ),
          ).animate().fade(duration: 800.ms).slideY(begin: -0.3, end: 0),
          
          const SizedBox(height: 40),
          
          // Awards Container - Responsive
          Container(
            padding: EdgeInsets.all(isSmallScreen ? screenWidth * 0.05 : screenWidth * 0.04),
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? screenWidth * 0.05 : screenWidth * 0.08),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppColors.primary,
                  size: isSmallScreen ? 28 : 32,
                ),
                const SizedBox(height: 20),
                ..._awards.map((award) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.primary,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          award,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: awardFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ).animate().fade(delay: 600.ms, duration: 800.ms),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
