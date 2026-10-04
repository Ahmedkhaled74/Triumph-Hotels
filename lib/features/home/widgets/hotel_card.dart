import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/features/hotels/hotel_details_screen.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final int index;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HotelDetailsScreen(hotel: hotel),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
        child: Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveHeight(context, 0.03)),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 16, mediumRadius: 18, largeRadius: 20, extraLargeRadius: 22)),
            boxShadow: [
              // Primary shadow for elevation
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              // Secondary shadow for depth
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: SizedBox(
            height: ResponsiveUtils.getResponsiveHeight(context, 0.38),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 16, mediumRadius: 18, largeRadius: 20, extraLargeRadius: 22)),
              child: Stack(
                children: [
                  // Full Card Image Section with Hero
                  Positioned.fill(
                    child: Hero(
                      tag: 'hotel_image_${hotel.id}',
                      child: (hotel.imageUrl.startsWith('http') || hotel.imageUrl.startsWith('https'))
                        ? Image.network(
                            hotel.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(context, localizations),
                          )
                        : Image.asset(
                            hotel.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(context, localizations),
                          ),
                    ),
                  ),
                  
                  // Gentle overlay just to preserve basic contrast
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // Floating Badge
                  Positioned(
                    top: ResponsiveUtils.getResponsiveHeight(context, 0.02),
                    right: ResponsiveUtils.getResponsiveWidth(context, 0.02),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveWidth(context, 0.02), 
                        vertical: ResponsiveUtils.getResponsiveHeight(context, 0.01)
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 16, largeRadius: 18, extraLargeRadius: 20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 4, mediumRadius: 6, largeRadius: 8, extraLargeRadius: 10),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[600],
                            size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 10, mediumSize: 12, largeSize: 14, extraLargeSize: 16),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.01)),
                          Text(
                            '${hotel.starRating ?? 4.8}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 10, mediumSize: 11, largeSize: 12, extraLargeSize: 13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Save Button
                  Positioned(
                    top: ResponsiveUtils.getResponsiveHeight(context, 0.02),
                    left: ResponsiveUtils.getResponsiveWidth(context, 0.02),
                    child: GestureDetector(
                      onTap: () {
                        // Add save functionality
                      },
                      child: Container(
                        width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 28, mediumSize: 32, largeSize: 36, extraLargeSize: 40),
                        height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 28, mediumSize: 32, largeSize: 36, extraLargeSize: 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 4, mediumRadius: 6, largeRadius: 8, extraLargeRadius: 10),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.primary,
                          size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 14, mediumSize: 16, largeSize: 18, extraLargeSize: 20),
                        ),
                      ),
                    ),
                  ),
  
                  // Content Section (High-Performance Styling)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.95),
                          ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 18, largePadding: 20, extraLargePadding: 24),
                          ResponsiveUtils.getResponsivePadding(context, smallPadding: 32, mediumPadding: 36, largePadding: 40, extraLargePadding: 48), // Extra top padding for gradient
                          ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 18, largePadding: 20, extraLargePadding: 24),
                          ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 18, largePadding: 20, extraLargePadding: 24),
                        ),
                        child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hotel Name and Location
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hotel.getLocalizedName(context),
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: Colors.white,
                                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 20, largeSize: 24, extraLargeSize: 28),
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          
                                          SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),
                                          
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                color: AppColors.primary,
                                                size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 12, mediumSize: 14, largeSize: 16, extraLargeSize: 18),
                                              ),
                                              
                                              SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.01)),
                                              
                                              Expanded(
                                                child: Text(
                                                  hotel.getLocalizedAddress(context).split(',').last.trim(),
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.white70,
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 11, mediumSize: 12, largeSize: 13, extraLargeSize: 14),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                                
                                // Brief Description
                                if (hotel.brief.isNotEmpty)
                                  Text(
                                    hotel.getLocalizedBrief(context),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 11, mediumSize: 12, largeSize: 12, extraLargeSize: 13),
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                                
                                // Price and Action Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Price Section
                                    // Price Section
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.from,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.white70,
                                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 10, mediumSize: 11, largeSize: 12, extraLargeSize: 13),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: hotel.name.toLowerCase().contains('luxury') 
                                                      ? '\$285' 
                                                      : hotel.name.toLowerCase().contains('plaza') 
                                                          ? '\$50' 
                                                          : '\$42',
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: AppColors.primary,
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: localizations.perNight,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.white70,
                                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 10, mediumSize: 11, largeSize: 12, extraLargeSize: 13),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const Spacer(),
                                    
                                    // View Details Button
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => HotelDetailsScreen(hotel: hotel),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(1.0, 0.0),
                                                  end: Offset.zero,
                                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                                                child: FadeTransition(opacity: animation, child: child),
                                              );
                                            },
                                            transitionDuration: const Duration(milliseconds: 350),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveUtils.getResponsiveWidth(context, 0.03), 
                                          vertical: ResponsiveUtils.getResponsiveHeight(context, 0.01)
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 15, mediumRadius: 20, largeRadius: 22, extraLargeRadius: 25)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.3),
                                              blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 4, mediumRadius: 6, largeRadius: 8, extraLargeRadius: 10),
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              localizations.viewDetails,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.white,
                                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 11, mediumSize: 12, largeSize: 13, extraLargeSize: 14),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.01)),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 12, mediumSize: 14, largeSize: 16, extraLargeSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ),
                      ),
                    ),
                  // Positioned (Content section) ends here.
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildErrorPlaceholder(BuildContext context, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel,
              size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 32, mediumSize: 40, largeSize: 48, extraLargeSize: 56),
              color: AppColors.primary.withOpacity(0.6),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
            Text(
              localizations.error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary.withOpacity(0.8),
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13, largeSize: 14, extraLargeSize: 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
