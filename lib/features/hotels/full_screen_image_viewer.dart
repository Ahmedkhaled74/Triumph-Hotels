import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imagePath;
  final String title;
  final int currentIndex;
  final List<String> allImages;
  final List<String> allTitles;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
    required this.currentIndex,
    required this.allImages,
    required this.allTitles,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TransformationController _transformationController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: widget.currentIndex);
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.error,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Interactive Image Viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Reset zoom when changing images
              _transformationController.value = Matrix4.identity();
            },
            itemCount: widget.allImages.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: (widget.allImages[index].startsWith('http') || widget.allImages[index].startsWith('https'))
                    ? Image.network(
                        widget.allImages[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                      ).animate().scale(delay: 100.ms, duration: 300.ms)
                    : Image.asset(
                        widget.allImages[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                      ).animate().scale(delay: 100.ms, duration: 300.ms),
                ),
              );
            },
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Image Counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.allImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Title Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Title
                  Text(
                    widget.allTitles[_currentIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  // Page Indicator
                  if (widget.allImages.length <= 15)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.allImages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _currentIndex == index ? 24 : 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    )
                  else
                    // Numeric indicator for large galleries
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.allImages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Navigation Arrows (for desktop/tablet)
          if (widget.allImages.length > 1) ...[
            // Left Arrow
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: _currentIndex > 0
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            
            // Right Arrow
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _currentIndex < widget.allImages.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentIndex < widget.allImages.length - 1
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
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
