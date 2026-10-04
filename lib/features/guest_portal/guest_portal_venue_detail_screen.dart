import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_menu_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GuestPortalVenueDetailScreen extends StatelessWidget {
  final String venueId;
  final String title;
  final String subtitle;
  final String image;
  final bool isOpen;
  final String hours;
  final List<String> tags;

  const GuestPortalVenueDetailScreen({
    super.key,
    required this.venueId,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.isOpen,
    required this.hours,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final statusColor = isOpen ? Colors.greenAccent : Colors.redAccent;
    final horizontalPadding = isSmallScreen ? 20.0 : ResponsiveUtils.getScreenWidth(context) * 0.15;

    // Menu Highlights removed as requested
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Expandable Hero Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: theme.cardColor.withOpacity(0.85),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  color: AppColors.primary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  (image.startsWith('http') || image.startsWith('/')) 
                    ? CachedNetworkImage(
                        imageUrl: image.startsWith('/') ? 'https://ticketx.triumphhotel.com$image' : image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: theme.cardColor),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      )
                    : Image.asset(image, fit: BoxFit.cover),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: statusColor.withOpacity(0.6), blurRadius: 6)],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen ? 'OPEN NOW' : 'CLOSED',
                            style: GoogleFonts.roboto(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fade().slideY(begin: 0.1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tags Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // Hours
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opening Hours',
                            style: GoogleFonts.roboto(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            hours,
                            style: GoogleFonts.roboto(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fade(delay: 150.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: theme.dividerColor.withOpacity(0.4)),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About',
                    style: GoogleFonts.roboto(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 12),

                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ).animate().fade(delay: 250.ms).slideY(begin: 0.1),

                  // Removed Menu Highlights
                  const SizedBox(height: 40),

                  // Reserve / Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!isOpen) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('This venue is currently closed.', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        }
                        GuestPortalMenuScreen.showCartAndReservation(
                          context,
                          theme,
                          venueId,
                          title,
                          () {},
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu, size: 20),
                      label: Text('Reserve Table'.tr(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (!isOpen) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('This venue is currently closed.', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuestPortalMenuScreen(
                              venueId: venueId,
                              venueName: title,
                              venueImage: image,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book_outlined, size: 20),
                      label: Text('View Menu'.tr(context)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 650.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
