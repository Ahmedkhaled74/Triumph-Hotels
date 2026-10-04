import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/meeting_room_model.dart';
import 'package:triumph_hotels/features/booking/booking_screen.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/core/providers/theme_provider.dart';

class EventDetailScreen extends StatefulWidget {
  final MeetingRoomModel meetingRoom;
  final String hotelSlug;

  const EventDetailScreen({
    super.key, 
    required this.meetingRoom,
    required this.hotelSlug,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final PageController _galleryController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context, listen: false)
          .fetchMeetingRoomDetail(widget.hotelSlug, widget.meetingRoom.slug);
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
        final detailedRoom = provider.getDetailedMeetingRoom(widget.meetingRoom.slug);
        final room = detailedRoom ?? widget.meetingRoom;
        final isLoading = provider.isLoading && detailedRoom == null;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          body: CustomScrollView(
            slivers: [
              // 1. Hero Gallery Header
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
                      _buildGalleryHeader(room),
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
                      // Melting Gradient
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
                      if (room.images.length > 1)
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
                                '${_currentImageIndex + 1} / ${room.images.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Content
              SliverToBoxAdapter(
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

                      // Title and Basics
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: GoogleFonts.greatVibes(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 36, mediumSize: 44, largeSize: 52),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.1),
                          const SizedBox(height: 16),
                          _buildQuickInfoRow(context, room, isDark),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildDivider(isDark),

                      // 1. Description Accordion
                      _buildExpansionTile(
                        context,
                        title: localizations.description,
                        isDark: isDark,
                        initiallyExpanded: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              room.description,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 15, mediumSize: 17),
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                          ),
                        ],
                      ),

                      _buildDivider(isDark),

                      // 2. Seating Arrangements Accordion
                      if (room.seatingArrangements.isNotEmpty)
                        _buildExpansionTile(
                          context,
                          title: "Seating Arrangements",
                          isDark: isDark,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildSeatingList(context, room.seatingArrangements, isDark),
                            ),
                          ],
                        ),

                      if (room.seatingArrangements.isNotEmpty)
                        _buildDivider(isDark),

                      // 3. Amenities Accordion
                      if (room.amenities.isNotEmpty)
                        _buildExpansionTile(
                          context,
                          title: localizations.amenitiesAndFeatures,
                          isDark: isDark,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildAmenitiesGrid(context, room.amenities, isDark),
                            ),
                          ],
                        ),

                      if (room.amenities.isNotEmpty)
                        _buildDivider(isDark),

                      const SizedBox(height: 24),

                      // Wedding Special
                      if (room.canHostWedding) ...[
                        _buildWeddingSection(context, room, isDark),
                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.04)),
                      ],

                      // Book Now Button
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveUtils.getResponsiveHeight(context, 0.07),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(
                                  bookingType: BookingType.event,
                                  itemName: room.name,
                                  itemDescription: room.description,
                                  itemImage: room.imageCover,
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
                            "Inquire for Booking",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(),
                      
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickInfoRow(BuildContext context, MeetingRoomModel room, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickInfo(context, Icons.people_outline, '${room.capacity} Capacity', isDark),
        _buildQuickInfo(context, Icons.square_foot, '${room.area.toInt()} m²', isDark),
        _buildQuickInfo(context, Icons.check_circle_outline, room.available ? 'Available' : 'Booked', isDark),
      ],
    );
  }

  Widget _buildQuickInfo(BuildContext context, IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
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

  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    required bool isDark,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 17, mediumSize: 19),
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(vertical: 8),
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: initiallyExpanded,
        trailing: Icon(Icons.add, color: isDark ? Colors.white70 : Colors.black54),
        collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
        iconColor: AppColors.primary,
        children: children,
      ),
    );
  }

  Widget _buildSeatingList(BuildContext context, List<SeatingArrangement> arrangements, bool isDark) {
    final cardHeight = ResponsiveUtils.getResponsiveHeight(context, 0.22);
    final cardWidth = ResponsiveUtils.getResponsiveWidth(context, 0.35);

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: arrangements.length,
        itemBuilder: (context, index) {
          final arrangement = arrangements[index];
          return Container(
            width: cardWidth,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: arrangement.image,
                    height: cardHeight * 0.55,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arrangement.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 14)
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${arrangement.capacity} Max",
                        style: TextStyle(
                          color: AppColors.primary, 
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 10, mediumSize: 12), 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmenitiesGrid(BuildContext context, List<MeetingRoomAmenity> amenities, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((a) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              a.name, 
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 14), 
                fontWeight: FontWeight.w500
              )
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildWeddingSection(BuildContext context, MeetingRoomModel room, bool isDark) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.goldLight.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                "Wedding Services",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 22), 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primary
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "This venue is perfect for weddings and ceremonial celebrations. We provide comprehensive wedding planning and catering services.",
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 15),
              height: 1.5
            ),
          ),
          if (room.weddingBrochure != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(room.weddingBrochure!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Download Wedding Brochure"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
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
          : const Icon(Icons.meeting_room, color: Colors.white, size: 64),
      ),
    );
  }

  Widget _buildGalleryHeader(MeetingRoomModel room) {
    if (room.images.isEmpty) {
      return Hero(
        tag: 'room_image_${room.id}',
        child: (room.imageCover.startsWith('http'))
          ? CachedNetworkImage(
              imageUrl: room.imageCover,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
            )
          : Image.asset(
              'assets/images/plaza/${room.imageCover}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            ),
      );
    }

    return Hero(
      tag: 'room_image_${room.id}',
      child: PageView.builder(
        controller: _galleryController,
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemCount: room.images.length,
        itemBuilder: (context, index) {
          final imageUrl = room.images[index].image;
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
