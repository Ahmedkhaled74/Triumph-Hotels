import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class AllOffersScreen extends StatefulWidget {
  final HotelModel hotel;
  final List<Offer> offers;

  const AllOffersScreen({
    super.key,
    required this.hotel,
    required this.offers,
  });

  @override
  State<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends State<AllOffersScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        title: Text(
          localizations.allOffers,
          style: GoogleFonts.roboto(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: widget.offers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 64, mediumSize: 80),
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No offers available for this hotel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
              itemCount: widget.offers.length,
              itemBuilder: (context, index) {
                final offer = widget.offers[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 32)),
                  child: _LuxuryOfferCard(offer: offer),
                ).animate().fadeIn(delay: (index * 150).ms, duration: 500.ms).slideY(begin: 0.2, end: 0);
              },
            ),
    );
  }
}

class _LuxuryOfferCard extends StatefulWidget {
  final Offer offer;
  const _LuxuryOfferCard({required this.offer});

  @override
  State<_LuxuryOfferCard> createState() => _LuxuryOfferCardState();
}

class _LuxuryOfferCardState extends State<_LuxuryOfferCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final localizations = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Ribbon
            Stack(
              children: [
                _buildOfferImage(offer),
                
                // Discount Ribbon
                if (offer.discountPercentage != null)
                  Positioned(
                    top: 20,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        '${offer.discountPercentage}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                // Featured Badge
                if (offer.isFeatured)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.star, color: AppColors.primary, size: 20),
                    ),
                  ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Expandable Description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Text(
                          offer.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            height: 1.5,
                          ),
                          maxLines: _isExpanded ? null : 3,
                          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                      ),
                      if (offer.description.length > 100)
                        GestureDetector(
                          onTap: () => setState(() => _isExpanded = !_isExpanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _isExpanded ? localizations.readLess : localizations.readMore,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info Grid
                  _buildInfoGrid(offer, localizations),
                  
                  const SizedBox(height: 24),
                  
                  // Premium Action Button
                  _buildActionButton(offer, localizations),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferImage(Offer offer) {
    final imageUrl = (offer.imageCover != null && offer.imageCover!.isNotEmpty)
        ? offer.imageCover!
        : (offer.imageCard != null && offer.imageCard!.isNotEmpty)
            ? offer.imageCard!
            : null;

    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/images/plaza/img17.jpg',
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.primary.withOpacity(0.4), size: 50),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(Offer offer, AppLocalizations localizations) {
    return Column(
      children: [
        if (offer.validityPeriod != null)
          _buildInfoRow(Icons.calendar_today_outlined, localizations.validityPeriod, offer.validityPeriod!),
        
        if (offer.offerCode != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(Icons.qr_code_outlined, 'Offer Code', offer.offerCode!, isCode: true),
          ),
          
        if (offer.startDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(Icons.timer_outlined, 'Availability', 'Starts ${_formatDate(offer.startDate!)}'),
          ),
        
        if (offer.endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(Icons.event_busy_outlined, 'Expires on', _formatDate(offer.endDate!)),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isCode = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCode ? AppColors.primary : null,
                  letterSpacing: isCode ? 1.2 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(Offer offer, AppLocalizations localizations) {
    final hasLink = offer.bookingLink != null && offer.bookingLink!.isNotEmpty;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (hasLink) {
            final Uri url = Uri.parse(offer.bookingLink!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Offer "${offer.title}" selected!'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasLink ? 'BOOK THIS OFFER NOW' : 'SELECT OFFER',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
