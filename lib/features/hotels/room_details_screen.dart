import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/room_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomDetailsScreen extends StatefulWidget {
  final RoomModel room;
  final String hotelSlug;

  const RoomDetailsScreen({
    super.key, 
    required this.room,
    required this.hotelSlug,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late RoomModel _roomDetail;
  bool _isLoading = true;
  final ApiClient _apiClient = ApiClient();
  final PageController _galleryController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _roomDetail = widget.room;
    _fetchRoomDetail();
  }

  Future<void> _fetchRoomDetail() async {
    if (widget.room.slug == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final dynamic data = await _apiClient.getRoomDetail(widget.hotelSlug, widget.room.slug!);
      if (mounted && data != null) {
        setState(() {
          _roomDetail = RoomModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Cinematic Image Gallery Header
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveHeight(context, isSmallScreen ? 0.45 : 0.55),
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gallery or Main Image
                  _buildGalleryHeader(),
                  
                  // Dark Overlay for readability
                  IgnorePointer(
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

                  // Melting Gradient (Transitions to background color)
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

                  // Image Indicator (Top Right to avoid title overlap)
                  if (_roomDetail.galleryImages != null && _roomDetail.galleryImages!.length > 1)
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
                            '${_currentImageIndex + 1} / ${_roomDetail.galleryImages!.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading 
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)))
                : _buildContent(context, localizations, isDark),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading ? null : _buildBottomAction(context, localizations),
    );
  }

  Widget _buildGalleryHeader() {
    final List<String> images = [];
    
    if (_roomDetail.galleryImages != null && _roomDetail.galleryImages!.isNotEmpty) {
      images.addAll(_roomDetail.galleryImages!.map((e) => e.image));
    } else {
      images.add(_roomDetail.imageUrl);
    }

    return PageView.builder(
      controller: _galleryController,
      onPageChanged: (index) => setState(() => _currentImageIndex = index),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final img = images[index];
        return (img.startsWith('http'))
            ? CachedNetworkImage(
                imageUrl: img, 
                fit: BoxFit.cover, 
                placeholder: (context, url) => _buildPlaceholder(isLoading: true),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : Image.asset('assets/images/plaza/$img', fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder());
      },
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      color: Colors.grey[800],
      child: isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : const Icon(Icons.hotel, color: Colors.white24, size: 48),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations, bool isDark) {
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24, largePadding: 32);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room Name & Badge
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_roomDetail.isSuit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PREMIUM SUITE',
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 10, mediumSize: 11), 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.2
                    ),
                  ),
                ),
              Text(
                _roomDetail.name,
                style: GoogleFonts.greatVibes(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 36, mediumSize: 44, largeSize: 52),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Key Specs Row (Always visible)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          child: _buildQuickInfo(context),
        ),
        
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_roomDetail.title != null)
                    Text(
                      _roomDetail.title!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20), 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.primary
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _roomDetail.description,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 15, mediumSize: 16),
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        _buildDivider(isDark),

        // 2. Amenities Accordion
        if (_roomDetail.fullAmenities != null || _roomDetail.fullFeatures != null)
          _buildExpansionTile(
            context,
            title: localizations.amenitiesAndFeatures,
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildAmenitiesGrid(context),
              ),
            ],
          ),

        if (_roomDetail.fullAmenities != null || _roomDetail.fullFeatures != null)
          _buildDivider(isDark),

        // 3. Specifications Accordion
        if (_roomDetail.specifications != null && _roomDetail.specifications!.isNotEmpty)
          _buildExpansionTile(
            context,
            title: 'Specifications',
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: _roomDetail.specifications!.map((s) => _buildSpecItem(context, s, isDark)).toList(),
                ),
              ),
            ],
          ),

        if (_roomDetail.specifications != null && _roomDetail.specifications!.isNotEmpty)
          _buildDivider(isDark),

        // 4. Policies Accordion
        if (_roomDetail.policySections != null && _roomDetail.policySections!.any((e) => e.isNotEmpty))
          _buildExpansionTile(
            context,
            title: 'Room Policies',
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: _roomDetail.policySections!.where((p) => p.isNotEmpty).map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p, 
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 13, mediumSize: 14), 
                              color: Colors.grey, 
                              height: 1.4
                            )
                          )
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),

        if (_roomDetail.policySections != null && _roomDetail.policySections!.any((e) => e.isNotEmpty))
          _buildDivider(isDark),
        
        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.1)),
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
        tilePadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24), 
          vertical: 8
        ),
        childrenPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)
        ),
        initiallyExpanded: initiallyExpanded,
        trailing: Icon(Icons.add, color: isDark ? Colors.white70 : Colors.black54),
        collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
        iconColor: AppColors.primary,
        children: children,
      ),
    );
  }

  Widget _buildQuickInfo(BuildContext context) {
    final iconSize = ResponsiveUtils.isSmallScreen(context) ? 24.0 : 32.0;
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, smallSize: 11, mediumSize: 13);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(context, Icons.square_foot, '${_roomDetail.size.toInt()} m²', iconSize, fontSize),
        _buildInfoItem(context, Icons.king_bed_outlined, _roomDetail.bedType ?? 'King', iconSize, fontSize),
        _buildInfoItem(context, Icons.visibility_outlined, _roomDetail.roomViews ?? 'View', iconSize, fontSize),
        _buildInfoItem(context, Icons.people_outline, _roomDetail.numberOfPersons ?? 'Capacity', iconSize, fontSize),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, double iconSize, double fontSize) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: iconSize),
        const SizedBox(height: 8),
        Text(
          label, 
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(BuildContext context) {
    final List<RoomAmenity> amenities = [];
    if (_roomDetail.fullAmenities != null) amenities.addAll(_roomDetail.fullAmenities!);
    if (_roomDetail.fullFeatures != null) amenities.addAll(_roomDetail.fullFeatures!);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((a) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
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

  Widget _buildSpecItem(BuildContext context, RoomSpecification spec, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(Icons.settings_suggest_outlined, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.name, 
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 15), 
                    fontWeight: FontWeight.bold
                  )
                ),
                if (spec.description != null)
                  Text(
                    spec.description!, 
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13), 
                      color: Colors.grey
                    )
                  ),
              ],
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
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }

  Widget _buildBottomAction(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24), 
        vertical: 16
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final url = _getBookingUrl();
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            localizations.applyForBooking,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 15, mediumSize: 17), 
              letterSpacing: 1.1
            ),
          ),
        ),
      ),
    );
  }

  String _getBookingUrl() {
    // Logic to be robust (copied from RoomsScreen pattern)
    final slug = widget.hotelSlug.toLowerCase();
    
    if (slug.contains('luxury')) {
      return "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=37005&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
    } else if (slug.contains('white-sands')) {
      return "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=41399&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
    } else {
      return "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=37004&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
    }
  }
}
