import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';

class OfferDetailPopup extends StatefulWidget {
  final String title;
  final String description;
  final String discount;
  final String validUntil;
  final IconData icon;
  final Color color;
  final String backgroundImage;
  final String? endDate;
  final String? offerCode;

  const OfferDetailPopup({
    super.key,
    required this.title,
    required this.description,
    required this.discount,
    required this.validUntil,
    required this.icon,
    required this.color,
    required this.backgroundImage,
    this.endDate,
    this.offerCode,
  });

  @override
  State<OfferDetailPopup> createState() => _OfferDetailPopupState();
}

class _OfferDetailPopupState extends State<OfferDetailPopup> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark Background Overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),

          // Central Popup
          Center(
            child: RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                constraints: BoxConstraints(
                  maxWidth: 500,
                  maxHeight: screenHeight * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Image Section
                    _buildElegantHeader(context),

                    // Scrollable Content
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildBoutiqueTitle(context),
                            const SizedBox(height: 20),
                            _buildGlassMetric(context, localizations),
                            const SizedBox(height: 24),
                            _buildElegantDescription(context, localizations),
                            const SizedBox(height: 24),
                            _buildHighlightsSection(context, localizations),
                            const SizedBox(height: 32),
                            _buildActionButtons(context, localizations),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(
                begin: 0.1, end: 0,
                duration: 400.ms,
                curve: Curves.easeOutQuart,
              ).fadeIn(duration: 300.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantHeader(BuildContext context) {
    return Stack(
      children: [
        // Hero Image
        SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              (widget.backgroundImage.startsWith('http'))
                ? Image.network(
                    widget.backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderAsset(),
                  )
                : _buildPlaceholderAsset(),
              // Gradient Fade to Content
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Close Button
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),

        // Discount Badge
        Positioned(
          bottom: 20,
          left: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              widget.discount.toUpperCase(),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoutiqueTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "EXCLUSIVE OFFER",
          style: GoogleFonts.montserrat(
            color: AppColors.primary.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 4.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.title,
          style: GoogleFonts.greatVibes(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 28,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassMetric(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.validityPeriod.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.validUntil,
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.endDate != null) ...[
                Container(
                  height: 30,
                  width: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "EXPIRES ON",
                        style: GoogleFonts.montserrat(
                          color: Colors.red.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(widget.endDate!),
                        style: GoogleFonts.roboto(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.offerCode != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 12),
                Text(
                  "OFFER CODE:",
                  style: GoogleFonts.montserrat(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.offerCode!,
                  style: GoogleFonts.roboto(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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


  Widget _buildElegantDescription(BuildContext context, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.aboutThisOffer.toUpperCase(),
          style: GoogleFonts.montserrat(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.description,
          style: GoogleFonts.roboto(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey,
            fontSize: 15,
            height: 1.6,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsSection(BuildContext context, AppLocalizations localizations) {
    final highlights = _getOfferHighlights();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.whatsIncluded.toUpperCase(),
          style: GoogleFonts.montserrat(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        ...highlights.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  h,
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        // Primary Action: Book Now
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.6) 
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${localizations.bookingInitiatedFor} ${widget.title}!'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  localizations.bookThisOffer.toUpperCase(),
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Secondary Action: Learn More
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            localizations.learnMore.toUpperCase(),
            style: GoogleFonts.roboto(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4) ?? Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getOfferHighlights() {
    switch (widget.title) {
      case 'Summer Escape':
        return [
          '20% off on all room types',
          'Complimentary breakfast for all guests',
          'Free WiFi access',
          'Pool and gym access included',
          'Late checkout (2 PM)'
        ];
      case 'Weekend Getaway':
        return [
          'Book 2 nights, get 3rd night free',
          '50 USD spa voucher included',
          'Complimentary room upgrade (subject to availability)',
          'Welcome drink on arrival',
          'Late checkout (2 PM)'
        ];
      default:
        return [
          'Special discount applied',
          'Premium amenities included',
          'Flexible booking terms',
          'Exclusive member benefits',
          'Priority customer support'
        ];
    }
  }

  Widget _buildPlaceholderAsset() {
    return Image.asset(
      'assets/images/plaza/img17.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: widget.color.withOpacity(0.2),
        child: Icon(widget.icon, color: Colors.white24, size: 64),
      ),
    );
  }
}
