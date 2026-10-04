import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_strings.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'full_description_screen.dart';

class HotelDetailsScreen extends StatefulWidget {
  final HotelModel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  late PageController _pageController;
  bool _showLogo = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChange);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChange);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChange() {
    if (_pageController.hasClients) {
      final newIndex = _pageController.page?.round() ?? 0;
      if (newIndex != _currentImageIndex) {
        setState(() => _currentImageIndex = newIndex);
        // Show logo when user scrolls to any image beyond the first one
        setState(() => _showLogo = newIndex > 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Image Gallery
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.hotel.gallery.length + 1, // +1 for main image
            itemBuilder: (context, index) {
              String imagePath = index == 0 
                  ? widget.hotel.imageUrl 
                  : widget.hotel.gallery[index - 1];
              
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
                  ),
                  
                  // Gradient Overlay for readability and elegance
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                  
                  // Hotel Logo (Large, in header)
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          // Professional main shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                            spreadRadius: 0,
                          ),
                          // Subtle depth shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                            spreadRadius: 0,
                          ),
                          // Soft ambient shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 2),
                            spreadRadius: -5,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment(-0.3, -0.3),
                            radius: 0.8,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Image.asset(
                          widget.hotel.logoUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    ),
                  ),

                  // Content Overlay (Name & Location)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '5-Star Luxury Hotel',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade().slideX(),
                        
                        const SizedBox(height: 12),
                        
                        // Hotel Name
                        Text(
                          widget.hotel.name,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'Great Vibes',
                            fontSize: 42,
                            height: 1.1,
                          ),
                        ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 8),
                        
                        // Location Row
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.hotel.address.split(',').last.trim(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ).animate().fade(delay: 400.ms),
                      ],
                    ),
                  ),
                  
                  // Floating Image Pagination Indicator
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.collections_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_currentImageIndex + 1}/${widget.hotel.gallery.length + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Custom App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showLogo ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        widget.hotel.logoUrl,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          
          // Scrollable Content Below
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height - 200,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Overview Card
                      _buildSectionCard(
                        context,
                        title: AppStrings.description,
                        icon: Icons.description_outlined,
                        delay: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.hotel.brief,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullDescriptionScreen(hotel: widget.hotel),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Read More',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.place, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.hotel.address,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'From',
                      style: GoogleFonts.roboto(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '\$299',
                      style: GoogleFonts.roboto(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/night',
                      style: GoogleFonts.roboto(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        // TODO: Implement booking functionality
                      },
                      child: Center(
                        child: Text(
                          'Book Now',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int delay,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: child,
          ),
        ],
      ),
    ).animate().fade(duration: 600.ms, delay: delay.ms).slideY(begin: 0.1, end: 0);
  }
}
