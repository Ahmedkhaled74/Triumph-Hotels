import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import '../features_screen.dart';
import '../restaurants_screen.dart';
import '../rooms_screen.dart';
import '../services_screen.dart';
import '../events_screen.dart';
import '../hotel_events_screen.dart';

class HotelExploreSection extends StatelessWidget {
  final HotelModel hotel;

  const HotelExploreSection({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final exploreItems = [
      {'title': localizations.roomsAndSuites, 'icon': Icons.bed, 'color': AppColors.primary},
      {'title': localizations.meetingRooms, 'icon': Icons.meeting_room, 'color': AppColors.primary},
      {'title': localizations.restaurantsAndCafes, 'icon': Icons.restaurant, 'color': AppColors.primary},
      {'title': localizations.events, 'icon': Icons.event, 'color': AppColors.primary},
      {'title': localizations.services, 'icon': Icons.room_service, 'color': AppColors.primary},
      {'title': localizations.otherFeatures, 'icon': Icons.more_horiz, 'color': AppColors.primary},
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveWidth(context, 0.05), 
        vertical: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 24)
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 16, largeRadius: 16, extraLargeRadius: 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 10, extraLargeRadius: 12),
            offset: Offset(0, ResponsiveUtils.getResponsiveHeight(context, 0.01)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 20, extraLargePadding: 24)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.explore, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.exploreOurHotel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.discoverAllFacilities,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 13, mediumSize: 14, largeSize: 14, extraLargeSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Optimized Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: ResponsiveUtils.isSmallScreen(context) ? 0.95 : 1.2,
              ),
              itemCount: exploreItems.length,
              itemBuilder: (context, index) {
                final item = exploreItems[index];
                return _ExploreCard(
                  title: item['title'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                  hotel: hotel,
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms).slideY(begin: 0.3, end: 0);
  }
}

class _ExploreCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final HotelModel hotel;

  const _ExploreCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        if (title == localizations.roomsAndSuites) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoomsScreen(hotel: hotel)));
        } else if (title == localizations.meetingRooms) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventsScreen(hotel: hotel)));
        } else if (title == localizations.events) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => HotelEventsScreen(hotel: hotel)));
        } else if (title == localizations.restaurantsAndCafes) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RestaurantsScreen(hotel: hotel)));
        } else if (title == localizations.services) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ServicesScreen(hotel: hotel)));
        } else if (title == localizations.otherFeatures) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => FeaturesScreen(hotel: hotel)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title ${localizations.comingSoon}'), backgroundColor: color, behavior: SnackBarBehavior.floating),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
