import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/restaurant_model.dart';
import 'package:triumph_hotels/features/booking/booking_screen.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/core/providers/theme_provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  final String hotelSlug;

  const RestaurantDetailScreen({
    super.key, 
    required this.restaurant,
    required this.hotelSlug,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final PageController _galleryController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context, listen: false)
          .fetchRestaurantDetail(widget.hotelSlug, widget.restaurant.slug);
    });
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final localizations = AppLocalizations.of(context)!;

    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);

    return Consumer<HotelProvider>(
      builder: (context, provider, child) {
        final detailedRestaurant = provider.getDetailedRestaurant(widget.restaurant.slug);
        final restaurant = detailedRestaurant ?? widget.restaurant;
        final isLoading = provider.isLoading && detailedRestaurant == null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Hero Image Header
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveHeight(context, isSmallScreen ? 0.45 : 0.5),
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildGalleryHeader(restaurant),
                  // Overlays
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.35, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    height: 180,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (isDark ? AppColors.darkBackground : AppColors.background).withOpacity(0),
                              (isDark ? AppColors.darkBackground : AppColors.background).withOpacity(0.6),
                              isDark ? AppColors.darkBackground : AppColors.background,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (restaurant.galleryImages.length > 1)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 20,
                      right: 20,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1} / ${restaurant.galleryImages.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. Content Sections
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.background,
              ),
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Center(child: LinearProgressIndicator(color: AppColors.primary)),
                      ),
                      
                    // Title and Cuisine Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: GoogleFonts.greatVibes(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 36, mediumSize: 44, largeSize: 52),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ).animate().fadeIn().slideX(begin: -0.1),
                        if (restaurant.slogan != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              restaurant.slogan!,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 15, mediumSize: 18),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _buildChip(context, restaurant.cuisine, Icons.restaurant_menu),
                      ],
                    ),

                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.04)),
                    
                    // Capacity and Style info
                    Row(
                      children: [
                        if (restaurant.noOfSeats != null)
                          Expanded(child: _buildQuickInfo(context, Icons.event_seat_outlined, '${restaurant.noOfSeats} Seats', isDark)),
                        if (restaurant.dressCode != null)
                          Expanded(child: _buildQuickInfo(context, Icons.checkroom_outlined, restaurant.dressCode!, isDark)),
                        if (restaurant.terrace)
                          Expanded(child: _buildQuickInfo(context, Icons.deck_outlined, 'Terrace', isDark)),
                      ],
                    ),

                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.04)),
                    _buildDivider(isDark),
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),

                    // Operational Hours
                    Text(
                      localizations.openingHours,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 20, mediumSize: 24),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHoursSlot(context, 'Full Service', restaurant.openingHours, isDark),
                    if (restaurant.lunchHours != null)
                      _buildHoursSlot(context, 'Lunch', restaurant.lunchHours!, isDark),
                    if (restaurant.dinnerHours != null)
                      _buildHoursSlot(context, 'Dinner', restaurant.dinnerHours!, isDark),

                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.04)),
                    _buildDivider(isDark),
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),

                    // Description Section
                    Text(
                      '${localizations.about} ${restaurant.name}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 20, mediumSize: 24),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      restaurant.description,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 15, mediumSize: 17),
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.05)),
                    
                    // Reserve Table Button
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUtils.getResponsiveHeight(context, 0.07),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingScreen(
                                bookingType: BookingType.restaurant,
                                itemName: restaurant.name,
                                itemDescription: restaurant.description,
                                itemImage: restaurant.imageCover,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          "Reserve a Table",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).scale(),
                    
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.04)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildQuickInfo(BuildContext context, IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 24, mediumSize: 32)),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 13, mediumSize: 15),
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHoursSlot(BuildContext context, String title, String hours, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 13, mediumSize: 15),
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                hours,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 15, mediumSize: 17),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label, 
            style: TextStyle(
              color: AppColors.primary, 
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 13, mediumSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: double.infinity,
      height: 1,
      color: isDark ? AppColors.darkDivider : AppColors.divider.withOpacity(0.5),
    );
  }

  Widget _buildImagePlaceholder({bool isLoading = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: isLoading 
          ? const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.restaurant, color: Colors.white, size: 64),
      ),
    );
  }

  Widget _buildGalleryHeader(RestaurantModel restaurant) {
    if (restaurant.galleryImages.isEmpty) {
      return Hero(
        tag: 'restaurant_image_${restaurant.id}',
        child: (restaurant.imageCover.startsWith('http'))
          ? CachedNetworkImage(
              imageUrl: restaurant.imageCover,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
            )
          : Image.asset(
              'assets/images/plaza/${restaurant.imageCover}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            ),
      );
    }

    return Hero(
      tag: 'restaurant_image_${restaurant.id}',
      child: PageView.builder(
        controller: _galleryController,
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemCount: restaurant.galleryImages.length,
        itemBuilder: (context, index) {
          final imageUrl = restaurant.galleryImages[index].image;
          return (imageUrl.startsWith('http'))
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              )
            : Image.asset(
                'assets/images/plaza/$imageUrl',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              );
        },
      ),
    );
  }
}
