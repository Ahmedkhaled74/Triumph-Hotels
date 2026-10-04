import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import '../all_offers_screen.dart';
import '../offer_detail_popup.dart';

class HotelOffersSection extends StatelessWidget {
  final List<Offer>? offers;
  final HotelModel hotel;

  const HotelOffersSection({super.key, this.offers, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // Use API offers if available, otherwise fallback to empty list or mock if desired
    // For now, let's only show if there are offers
    if (offers == null || offers!.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.exclusiveOffers,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizations.specialDealsAndPackages,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Offers List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ...offers!
                    .take(2)
                    .map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _OfferCardWrapper(
                    offer: offer,
                    icon: Icons.local_offer,
                    color: AppColors.primary,
                  ),
                )),
                
                // View All Offers Button
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AllOffersScreen(
                              hotel: hotel,
                              offers: offers ?? [],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.viewAllOffers,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.3, end: 0);
  }
}

class _OfferCardWrapper extends StatelessWidget {
  final Offer offer;
  final IconData icon;
  final Color color;

  const _OfferCardWrapper({
    required this.offer,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return OfferDetailPopup(
              title: offer.title,
              description: offer.description,
              discount: offer.discountPercentage != null ? '${offer.discountPercentage}% OFF' : 'OFFER',
              validUntil: offer.validityPeriod ?? 'Limited Time',
              icon: icon,
              color: color,
              backgroundImage: offer.imageCard ?? offer.imageCover ?? '',
              endDate: offer.endDate,
              offerCode: offer.offerCode,
            );
          },
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background Image with Caching
              Positioned.fill(
                child: ((offer.imageCard ?? offer.imageCover ?? '').startsWith('http'))
                    ? Image.network(
                        offer.imageCard ?? offer.imageCover ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderAsset(),
                      )
                    : _buildPlaceholderAsset(),
              ),
              
              // Dark Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  offer.title,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'OFF',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            offer.description,
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.white.withOpacity(0.7)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  offer.validityPeriod ?? 'Limited Time',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAsset() {
    return Image.asset(
      'assets/images/plaza/img17.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(icon, color: color.withOpacity(0.5), size: 40),
        ),
      ),
    );
  }
}
