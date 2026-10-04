import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';

class FeaturesScreen extends StatefulWidget {
  final HotelModel hotel;
  
  const FeaturesScreen({super.key, required this.hotel});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  late ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Fetch detailed hotel info for banners if not available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hotel.slug != null && (widget.hotel.banners == null || widget.hotel.banners!.isEmpty)) {
        Provider.of<HotelProvider>(context, listen: false).fetchHotelDetail(widget.hotel.slug!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final shouldShowTitle = offset > 200; // Show title when scrolled past 200px
      if (shouldShowTitle != _showTitle) {
        setState(() {
          _showTitle = shouldShowTitle;
        });
      }
    }
  }

  // Get features based on hotel
  List<Map<String, dynamic>> _getFeatures([HotelModel? hotel]) {
    final targetHotel = hotel ?? widget.hotel;
    if (targetHotel.facilities != null && targetHotel.facilities!.isNotEmpty) {
      return targetHotel.facilities!.map((facility) {
        return {
          'id': facility.id.toString(),
          'title': facility.name,
          'description': facility.description,
          'imageUrl': facility.image,
          'features': [
            if (facility.shortNote1 != null) facility.shortNote1!,
            if (facility.shortNote2 != null) facility.shortNote2!,
            if (facility.shortNote3 != null) facility.shortNote3!,
          ],
          'hours': facility.shortNote1 ?? 'Varies',
          'icon': _getFacilityIcon(facility.icon ?? facility.type),
          'color': AppColors.primary,
        };
      }).toList();
    }

    // Fallback to hardcoded data if API returns nothing
    switch (widget.hotel.id) {
      case '1': // Triumph Plaza - Heliopolis
        return [
          {
            'id': 'executive_lounge',
            'title': 'Executive Lounge',
            'description': 'Need to conduct a quick business meeting on the side during your vacation? Or, do you simply want to relax with a drink in luxurious surroundings? Our Executive Lounge is ideal for all those possibilities. The Lounge is ready to serve you appetizing snacks and drinks 24 hours a day. The Executive Lounge offers a luxurious retreat daily from 7:00 Am to 11:00 Pm with an exclusive privilege.',
            'imageUrl': 'longue.jpg',
            'features': [
              '24/7 Snacks & Drinks',
              'Business Meeting Space',
              'Luxurious Surroundings',
              'Exclusive Privilege Access',
              'Professional Service',
              'Comfortable Seating',
              'High-Speed WiFi',
              'Premium Beverages'
            ],
            'hours': '7:00 AM - 11:00 PM',
            'icon': Icons.meeting_room,
            'color': AppColors.primary,
          },
        ];
      case '2': // Triumph Luxury - New Capital
        return [
          {
            'id': 'executive_lounge',
            'title': 'Royal Executive Lounge',
            'description': 'Indulge in unparalleled luxury at our Royal Executive Lounge, where exclusivity meets sophistication. Experience personalized service, gourmet cuisine, and breathtaking views from the heart of New Capital.',
            'imageUrl': 'royal_lounge.jpg',
            'features': [
              'Personal Butler Service',
              'Gourmet Cuisine',
              'Panoramic Views',
              'VIP Access Only',
              'Premium Spirits',
              'Private Meeting Rooms'
            ],
            'hours': '6:00 AM - 12:00 AM',
            'icon': Icons.meeting_room,
            'color': AppColors.primary,
          }
        ];
      case '3': // Triumph White Sands - North Coast
        return [
          {
            'id': 'beach_lounge',
            'title': 'Beach Executive Lounge',
            'description': 'Relax in style at our beachfront executive lounge, offering stunning Mediterranean views, refreshing cocktails, and exclusive beach access for our valued guests.',
            'imageUrl': 'beach_lounge.jpg',
            'features': [
              'Beachfront Views',
              'Tropical Cocktails',
              'Beach Access',
              'Sunset Dining',
              'Ocean Breeze',
              'Luxury Cabanas'
            ],
            'hours': '10:00 AM - 10:00 PM',
            'icon': Icons.beach_access,
            'color': AppColors.primary,
          }
        ];
      default:
        return [
          {
            'id': 'executive_lounge',
            'title': 'Executive Lounge',
            'description': 'Exclusive lounge area for business meetings and relaxation with premium amenities.',
            'imageUrl': 'longue.jpg',
            'features': [
              'Business Meeting Space',
              'Luxurious Surroundings',
              'Premium Beverages'
            ],
            'hours': '7:00 AM - 11:00 PM',
            'icon': Icons.meeting_room,
            'color': AppColors.primary,
          }
        ];
    }
  }

  IconData _getFacilityIcon(String? iconName) {
    if (iconName == null) return Icons.star;
    final name = iconName.toLowerCase();
    if (name.contains('pool')) return Icons.pool;
    if (name.contains('gym') || name.contains('fitness')) return Icons.fitness_center;
    if (name.contains('spa')) return Icons.spa;
    if (name.contains('meeting') || name.contains('lounge')) return Icons.meeting_room;
    if (name.contains('beach')) return Icons.beach_access;
    if (name.contains('wifi')) return Icons.wifi;
    if (name.contains('parking')) return Icons.local_parking;
    if (name.contains('restaurant')) return Icons.restaurant;
    return Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          final detailedHotel = widget.hotel.slug != null 
              ? provider.getDetailedHotel(widget.hotel.slug!) 
              : null;
          final hotel = detailedHotel ?? widget.hotel;
          final features = _getFeatures(hotel);
          final banner = hotel.getBanner(['services', 'features', 'service', 'feature']);
          final bannerImage = hotel.getBannerImage(['services', 'features', 'service', 'feature']);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: ResponsiveUtils.scaleHeight(context, 250),
                pinned: true,
                elevation: 0,
                backgroundColor: _showTitle ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
                centerTitle: true,
                titleSpacing: 0,
                iconTheme: IconThemeData(
                  color: _showTitle ? Theme.of(context).iconTheme.color : Colors.white,
                ),
                title: AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.only(bottom: ResponsiveUtils.scaleHeight(context, 8)),
                    child: Text(
                      localizations.features,
                      style: TextStyle(
                        color: _showTitle 
                            ? (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)
                            : Colors.white,
                        fontSize: ResponsiveUtils.scaleFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Top background banner image from API if available, else first feature image / default
                      if (bannerImage != null && bannerImage.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: bannerImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildDefaultHeader(),
                          errorWidget: (context, url, error) => _buildDefaultHeader(),
                        )
                      else if (features.isNotEmpty && features[0]['imageUrl'] != null)
                        (features[0]['imageUrl'].toString().startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: features[0]['imageUrl'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildDefaultHeader(),
                              errorWidget: (context, url, error) => _buildDefaultHeader(),
                            )
                          : Image.asset(
                              'assets/images/plaza/${features[0]['imageUrl']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildDefaultHeader(),
                            ))
                      else
                        _buildDefaultHeader(),
                      
                      // Dark Overlay for readability
                      Container(
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
                      
                      // Melting Gradient
                      Positioned(
                        bottom: -1,
                        left: 0,
                        right: 0,
                        height: ResponsiveUtils.scaleHeight(context, 180),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Content Overlay (only when not collapsed)
                      if (!_showTitle)
                        Positioned(
                          bottom: ResponsiveUtils.scaleHeight(context, 20),
                          left: ResponsiveUtils.scaleWidth(context, 20),
                          right: ResponsiveUtils.scaleWidth(context, 20),
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.features,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.scaleFontSize(context, 32),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: ResponsiveUtils.scaleHeight(context, 8)),
                                Text(
                                  banner?.title?.isNotEmpty == true
                                      ? banner!.title!
                                      : localizations.exclusiveAmenitiesAndPrivileges,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.scaleFontSize(context, 16),
                                    fontWeight: FontWeight.w400,
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
              
              // Features Grid — 2 columns on mobile, 3 on tablet
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUtils.scaleWidth(context, 16),
                  ResponsiveUtils.scaleHeight(context, 8),
                  ResponsiveUtils.scaleWidth(context, 16),
                  ResponsiveUtils.scaleHeight(context, 24),
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveUtils.isTablet(context) ? 3 : 2,
                    mainAxisSpacing: ResponsiveUtils.scaleHeight(context, 16),
                    crossAxisSpacing: ResponsiveUtils.scaleWidth(context, 12),
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final feature = features[index];
                      return _buildFeatureCard(feature, index);
                    },
                    childCount: features.length,
                  ),
                ),
              ),
              
              // Bottom Space
              SliverToBoxAdapter(
                child: SizedBox(height: ResponsiveUtils.scaleHeight(context, 100)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDefaultHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.goldLight.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.featured_play_list,
          color: Colors.white.withOpacity(0.5),
          size: ResponsiveUtils.scaleWidth(context, 80),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    final theme = Theme.of(context);
    final color = feature['color'] as Color;
    final hasImage = feature['imageUrl'] != null &&
        feature['imageUrl'].toString().isNotEmpty;
    final imageUrl = feature['imageUrl']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _showFeatureDetails(feature),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── TOP: Image / Icon area ──────────────────────────
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background: network image or gradient placeholder
                    if (hasImage && imageUrl.startsWith('http'))
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCardPlaceholder(color, feature),
                      )
                    else if (hasImage)
                      Image.asset(
                        'assets/images/plaza/$imageUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCardPlaceholder(color, feature),
                      )
                    else
                      _buildCardPlaceholder(color, feature),

                    // Subtle dark gradient over image
                    if (hasImage)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),

                    // Icon badge — top left
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: hasImage
                              ? Colors.black.withOpacity(0.35)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // Hours badge — bottom right
                    if ((feature['hours'] ?? '').toString().isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded, color: Colors.white, size: 11),
                              const SizedBox(width: 3),
                              Text(
                                feature['hours'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── BOTTOM: Title + Description ─────────────────────
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        feature['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Divider accent
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Description
                      Text(
                        feature['description'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                          fontSize: 11,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 60 * index))
        .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildCardPlaceholder(Color color, Map<String, dynamic> feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.85),
            color.withOpacity(0.55),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          feature['icon'] as IconData,
          color: Colors.white.withOpacity(0.35),
          size: 52,
        ),
      ),
    );
  }

  void _showFeatureDetails(Map<String, dynamic> feature) {
    showDialog(
      context: context,
      builder: (context) => FeatureDetailDialog(feature: feature),
    );
  }
}

// Feature Detail Dialog
class FeatureDetailDialog extends StatelessWidget {
  final Map<String, dynamic> feature;

  const FeatureDetailDialog({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.scaleWidth(context, 24)),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (isTablet ? 0.7 : 0.85),
          maxWidth: isTablet ? 500 : double.infinity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: ResponsiveUtils.scaleHeight(context, 200),
              ),
              child: Stack(
                children: [
                  // Feature Image
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ResponsiveUtils.scaleWidth(context, 24)),
                        topRight: Radius.circular(ResponsiveUtils.scaleWidth(context, 24)),
                      ),
                      child: (feature['imageUrl'] != null)
                        ? (feature['imageUrl'].toString().startsWith('http')
                          ? Image.network(
                              feature['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(context, feature),
                            )
                          : Image.asset(
                              'assets/images/plaza/${feature['imageUrl']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(context, feature),
                            ))
                        : _buildPlaceholderIcon(context, feature),
                    ),
                  ),
                  
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ResponsiveUtils.scaleWidth(context, 24)),
                          topRight: Radius.circular(ResponsiveUtils.scaleWidth(context, 24)),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Content Overlay
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveUtils.scaleWidth(context, 20),
                      ResponsiveUtils.scaleHeight(context, 40),
                      ResponsiveUtils.scaleWidth(context, 20),
                      ResponsiveUtils.scaleHeight(context, 16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          feature['icon'],
                          color: Colors.white,
                          size: ResponsiveUtils.scaleWidth(context, 32),
                        ),
                        SizedBox(height: ResponsiveUtils.scaleHeight(context, 8)),
                        Text(
                          feature['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.scaleFontSize(context, 24),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.scaleHeight(context, 6)),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: ResponsiveUtils.scaleWidth(context, 14),
                            ),
                            SizedBox(width: ResponsiveUtils.scaleWidth(context, 6)),
                            Text(
                              feature['hours'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.scaleFontSize(context, 13),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Close Icon
                  Positioned(
                    top: ResponsiveUtils.scaleHeight(context, 12),
                    right: ResponsiveUtils.scaleWidth(context, 12),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      localizations.aboutThisFeature,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: ResponsiveUtils.scaleFontSize(context, 18),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.scaleHeight(context, 12)),
                    Text(
                      feature['description'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: ResponsiveUtils.scaleFontSize(context, 14),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Close Button
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 24)),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feature['color'],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.scaleHeight(context, 16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.scaleWidth(context, 16)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    localizations.close,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.scaleFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(BuildContext context, Map<String, dynamic> feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            feature['color'],
            feature['color'].withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          feature['icon'],
          color: Colors.white,
          size: ResponsiveUtils.scaleWidth(context, 60),
        ),
      ),
    );
  }
}
