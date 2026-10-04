import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_menu_screen.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_venue_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Maps a venueType slug to a local hero image.
String _venueImage(String venueType) {
  switch (venueType) {
    case 'restaurant':
      return AppImages.placeholderHotel2;
    case 'room_service':
      return AppImages.placeholderHotel1;
    case 'pool_bar':
      return AppImages.placeholderHotel3;
    default:
      return AppImages.placeholderHotel1;
  }
}

class GuestPortalDiningScreen extends StatefulWidget {
  final bool showAppBar;

  const GuestPortalDiningScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<GuestPortalDiningScreen> createState() => _GuestPortalDiningScreenState();
}

class _GuestPortalDiningScreenState extends State<GuestPortalDiningScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch venues after first frame so the provider context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GuestPortalProvider>().fetchVenues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final horizontalPadding =
        isSmallScreen ? 16.0 : ResponsiveUtils.getScreenWidth(context) * 0.15;

    final provider = context.watch<GuestPortalProvider>();
    final venues = provider.venues;
    final isLoading = provider.isLoading && venues.isEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: AppColors.primary,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Dining & Cafes'.tr(context),
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // Pull-to-refresh button
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: AppColors.primary,
                  onPressed: () => context.read<GuestPortalProvider>().fetchVenues(forceRefresh: true),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: theme.dividerColor.withOpacity(0.5),
                  height: 1.0,
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<GuestPortalProvider>().fetchVenues(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Our Culinary Venues'.tr(context),
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fade().slideY(begin: 0.1),

              const SizedBox(height: 8),

              Text(
                'Discover a world of flavors tailored for every moment of your stay.'.tr(context),
                style: GoogleFonts.roboto(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 14,
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              if (isLoading)
                _buildLoadingState(theme)
              else if (venues.isEmpty)
                _buildEmptyState(theme)
              else
                isSmallScreen
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: venues.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          return _buildDiningCard(context, theme, venues[index])
                              .animate()
                              .fade(delay: Duration(milliseconds: 200 + (index * 100)))
                              .slideY(begin: 0.1);
                        },
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveUtils.isTablet(context) ? 2 : 3,
                          childAspectRatio: ResponsiveUtils.isTablet(context) ? 0.82 : 0.9,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: venues.length,
                        itemBuilder: (context, index) {
                          return _buildDiningCard(context, theme, venues[index])
                              .animate()
                              .fade(delay: Duration(milliseconds: 200 + (index * 100)))
                              .slideY(begin: 0.1);
                        },
                      ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 300,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary.withOpacity(0.4),
              strokeWidth: 2,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(color: AppColors.primary.withOpacity(0.05), duration: 1200.ms),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.restaurant_outlined, size: 64, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No Venues Available'.tr(context),
              style: GoogleFonts.roboto(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check back later or pull down to refresh.'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiningCard(BuildContext context, ThemeData theme, Map<String, dynamic> venue) {
    final bool isAvailable = venue['isAvailable'] as bool? ?? true;
    final statusColor = isAvailable ? Colors.greenAccent : Colors.orangeAccent;
    final statusLabel = isAvailable ? 'OPEN'.tr(context) : 'CLOSED'.tr(context);

    final String venueId = venue['id']?.toString() ?? '';
    final String venueType = venue['venueType'] as String? ?? 'restaurant';
    final String? apiImage = venue['image'] as String?;
    final String fallbackImage = _venueImage(venueType);
    final String title = venue['title'] as String? ?? 'Venue';
    final String subtitle = venue['subtitle'] as String? ?? '';
    final String hours = venue['hours'] as String? ?? '';
    final List<String> tags = List<String>.from(venue['tags'] as List? ?? []);

    Widget imageWidget;
    if (apiImage != null && apiImage.isNotEmpty) {
      final imageUrl = apiImage.startsWith('http')
          ? apiImage
          : 'https://ticketx.triumphhotel.com$apiImage';
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => Image.asset(fallbackImage, fit: BoxFit.cover),
        errorWidget: (ctx, url, err) => Image.asset(fallbackImage, fit: BoxFit.cover),
      );
    } else {
      imageWidget = Image.asset(fallbackImage, fit: BoxFit.cover);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image Header ──────────────────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: imageWidget,
                ),
                // Gradient overlay
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, theme.cardColor.withOpacity(0.9)],
                    ),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withOpacity(0.88),
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
                          statusLabel,
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

            // ── Content ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hours.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              hours,
                              style: GoogleFonts.roboto(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // View Menu button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isAvailable
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GuestPortalMenuScreen(
                                    venueId: venueId,
                                    venueName: title,
                                    venueImage: apiImage ?? fallbackImage,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(isAvailable ? 0.5 : 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'VIEW MENU'.tr(context),
                        style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Venue Details button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuestPortalVenueDetailScreen(
                              venueId: venueId,
                              title: title,
                              subtitle: subtitle,
                              image: apiImage ?? fallbackImage,
                              isOpen: isAvailable,
                              hours: hours,
                              tags: tags,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: Text(
                        'VENUE DETAILS'.tr(context),
                        style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
