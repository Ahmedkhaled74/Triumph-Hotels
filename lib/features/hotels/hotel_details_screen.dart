import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'full_screen_image_viewer.dart';
import 'main_gallery_screen.dart';
import 'widgets/hotel_offers_section.dart';
import 'widgets/hotel_explore_section.dart';

class HotelDetailsScreen extends StatefulWidget {
  final HotelModel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  bool _isExpanded = false;
  GoogleMapController? _mapController;
  LatLng? _currentMapCoordinates;
  late ScrollController _scrollController;
  bool _isAppBarCollapsed = false;
  // Deferred map loading: keeps the navigation transition silky smooth
  // by preventing the heavy Google Maps SDK from initializing until after
  // the screen slide animation has fully completed.
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChange);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Fetch detailed hotel info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hotel.slug != null) {
        Provider.of<HotelProvider>(context, listen: false).fetchHotelDetail(widget.hotel.slug!);
        Provider.of<HotelProvider>(context, listen: false).fetchHotelOffers(widget.hotel.slug!);
      }
    });

    // Defer map initialization by 400ms for smooth page transition
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _mapReady = true);
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChange);
    _pageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Listen to scroll events to detect app bar collapse
  // Uses a flag to avoid calling setState more than once per direction change
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isCollapsed = _scrollController.offset > 200;
    if (isCollapsed != _isAppBarCollapsed) {
      _isAppBarCollapsed = isCollapsed;
      // Use addPostFrameCallback to avoid triggering setState mid-frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  // Get coordinates for hotel addresses
  LatLng _getHotelCoordinates(HotelModel hotel) {
    final (lat, lng) = hotel.coordinates;
    return LatLng(lat, lng);
  }

  // Launch URL in external browser
  Future<void> _launchURL(String url) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final uri = Uri.parse(url.trim());
      bool launched = false;
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.couldNotLaunchUrl),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.couldNotLaunchUrl),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Image Helper Widget
  Widget _buildHotelImage(String path, {BoxFit fit = BoxFit.cover, double? height, double? width, Alignment alignment = Alignment.center}) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        fit: fit,
        height: height,
        width: width,
        alignment: alignment,
        // Cache decoded image at display size to save GPU memory and avoid re-decoding
        cacheWidth: width != null ? (width * 2).toInt() : null,
        cacheHeight: height != null ? (height * 2).toInt() : null,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.hotel_outlined,
              color: AppColors.primary.withOpacity(0.4),
              size: 48,
            ),
          ),
        ),
      );
    } else {
      return Image.asset(
        path,
        fit: fit,
        height: height,
        width: width,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.hotel_outlined,
              color: AppColors.primary.withOpacity(0.4),
              size: 48,
            ),
          ),
        ),
      );
    }
  }

  // Platform icon fallback helper
  IconData _getPlatformIcon(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('facebook') || p.contains('fb')) return Icons.facebook;
    if (p.contains('instagram') || p.contains('insta')) return FontAwesomeIcons.instagram;
    if (p.contains('twitter') || p.contains('x')) return Icons.alternate_email;
    if (p.contains('linkedin')) return FontAwesomeIcons.linkedinIn;
    if (p.contains('youtube')) return Icons.play_circle_fill;
    if (p.contains('tiktok')) return FontAwesomeIcons.tiktok;
    if (p.contains('snapchat')) return Icons.camera;
    if (p.contains('whatsapp') || p.contains('whats')) return Icons.chat;
    if (p.contains('tripadvisor')) return Icons.rate_review;
    if (p.contains('telegram')) return Icons.send;
    if (p.contains('pinterest')) return Icons.push_pin;
    return Icons.public;
  }

  // Contact Icon Widget that fetches and displays the contact/social logo if it exists
  Widget _buildContactIcon({
    required String url,
    String? logoUrl,
    String? assetLogo,
    required IconData fallbackIcon,
    double? size,
    String? tooltip,
  }) {
    final defaultSize = size ?? ResponsiveUtils.getResponsiveIconSize(context, smallSize: 50, mediumSize: 55, largeSize: 60, extraLargeSize: 65);
    final innerPadding = defaultSize * 0.22;
    final innerSize = defaultSize - (innerPadding * 2);

    Widget content;

    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      final trimmed = logoUrl.trim();
      final cleanUrl = trimmed.startsWith('http')
          ? trimmed
          : 'https://www.triumphhotel.com${trimmed.startsWith('/') ? '' : '/'}$trimmed';

      final isSvg = cleanUrl.toLowerCase().split('?').first.endsWith('.svg');

      if (isSvg) {
        content = SvgPicture.network(
          cleanUrl,
          width: innerSize,
          height: innerSize,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => Icon(
            fallbackIcon,
            color: AppColors.primary,
            size: defaultSize * 0.47,
          ),
        );
      } else {
        content = Image.network(
          cleanUrl,
          width: innerSize,
          height: innerSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            fallbackIcon,
            color: AppColors.primary,
            size: defaultSize * 0.47,
          ),
        );
      }
    } else if (assetLogo != null && assetLogo.trim().isNotEmpty) {
      content = Image.asset(
        assetLogo,
        width: innerSize,
        height: innerSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          fallbackIcon,
          color: AppColors.primary,
          size: defaultSize * 0.47,
        ),
      );
    } else {
      content = Icon(
        fallbackIcon,
        color: AppColors.primary,
        size: defaultSize * 0.47,
      );
    }

    final button = GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        width: defaultSize,
        height: defaultSize,
        padding: EdgeInsets.all(innerPadding),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(defaultSize * 0.27),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: content,
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip.isNotEmpty) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  // Launch Google Maps for directions
  Future<void> _launchDirections(LatLng coordinates) async {
    final localizations = AppLocalizations.of(context)!;
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${coordinates.latitude},${coordinates.longitude}'
    );
    
    bool launched = false;
    try {
      if (await canLaunchUrl(url)) {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    if (!launched) {
      try {
        launched = await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.couldNotLaunchDirections),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Launch Google Maps to view location
  Future<void> _openMaps(LatLng coordinates) async {
    final localizations = AppLocalizations.of(context)!;
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${coordinates.latitude},${coordinates.longitude}'
    );
    
    bool launched = false;
    try {
      if (await canLaunchUrl(url)) {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    if (!launched) {
      try {
        launched = await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.couldNotOpenMaps),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onPageChange() {
    if (_pageController.hasClients) {
      final newIndex = _pageController.page?.round() ?? 0;
      if (newIndex != _currentImageIndex) {
        setState(() => _currentImageIndex = newIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          final detailedHotel = widget.hotel.slug != null 
              ? provider.getDetailedHotel(widget.hotel.slug!) 
              : null;
          
          final hotel = detailedHotel ?? widget.hotel;
          final coordinates = _getHotelCoordinates(hotel);

          // If the map controller is active and coordinates updated (e.g. after detail fetch),
          // animate the camera smoothly to the accurate hotel coordinates.
          if (_mapController != null && _currentMapCoordinates != null && _currentMapCoordinates != coordinates) {
            _currentMapCoordinates = coordinates;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: coordinates, zoom: 15),
                ),
              );
            });
          }
          
          if (provider.isLoading && detailedHotel == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar Sliver
              SliverAppBar(
                expandedHeight: screenHeight - ResponsiveUtils.getResponsiveHeight(context, 0.15),
                pinned: true,
                floating: false,
                backgroundColor: _isAppBarCollapsed 
                    ? Theme.of(context).scaffoldBackgroundColor 
                    : Colors.transparent,
                elevation: 0,
                shadowColor: Colors.black.withOpacity(0.1),
                // Show title only when collapsed — use plain Opacity (no animation) to avoid
                // triggering layout during scroll
                title: Opacity(
                  opacity: _isAppBarCollapsed ? 1.0 : 0.0,
                  child: _buildHotelImage(
                    hotel.logoUrl,
                    height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 30, mediumSize: 35, largeSize: 40, extraLargeSize: 45),
                    fit: BoxFit.contain,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // PageView for main hotel image
                      PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              if (details.primaryDelta != null) {
                                final double delta = details.primaryDelta! * 2;
                                _pageController.jumpTo(_pageController.offset - delta);
                              }
                            },
                            onHorizontalDragEnd: (details) {
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                            },
                            onTap: () {
                              final allImages = hotel.hotelImages?.map((e) => e.image).toList() ?? [hotel.imageUrl];
                              final allTitles = hotel.hotelImages?.map((e) => e.caption ?? hotel.name).toList() ?? [hotel.name];
                              
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => FullScreenImageViewer(
                                    imagePath: hotel.imageUrl,
                                    title: hotel.name,
                                    currentIndex: 0,
                                    allImages: allImages,
                                    allTitles: allTitles,
                                  ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildHotelImage(
                                  hotel.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                                
                                // Dark Overlay for readability
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.4),
                                        Colors.black.withOpacity(0.8),
                                      ],
                                      stops: const [0.2, 0.55, 1.0],
                                    ),
                                  ),
                                ),
    
                                // Melting Gradient
                                Positioned(
                                  bottom: -1,
                                  left: 0,
                                  right: 0,
                                  height: 350,
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
                              ],
                            ),
                          );
                        },
                      ),
                      
                      // Hotel Name and Location
                      Positioned(
                        bottom: ResponsiveUtils.getResponsiveHeight(context, 0.04),
                        left: ResponsiveUtils.getResponsiveWidth(context, 0.05),
                        right: ResponsiveUtils.getResponsiveWidth(context, 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: ResponsiveUtils.getResponsiveWidth(context, 0.6),
                              height: ResponsiveUtils.getResponsiveHeight(context, 0.1),
                              child: _buildHotelImage(
                                hotel.logoUrl,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomLeft,
                              ),
                            ).animate().fade(delay: 150.ms).scale(duration: 600.ms, curve: Curves.easeOutBack),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              hotel.slogan ?? 'where luxury meets comfortability',
                              style: GoogleFonts.greatVibes(
                                color: AppColors.primary,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                                fontWeight: FontWeight.w400,
                              ),
                            ).animate().fade(delay: 250.ms).slideY(begin: 0.2, end: 0, duration: 600.ms),
                            
                            const SizedBox(height: 8),
                            
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on, 
                                  color: AppColors.primary, 
                                  size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 18, largeSize: 20, extraLargeSize: 22)
                                ),
                                SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.01)),
                                Expanded(
                                  child: Text(
                                    hotel.getLocalizedAddress(context).split(',').last.trim(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w300,
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 
                                        smallSize: 14, 
                                        mediumSize: 16, 
                                        largeSize: 18, 
                                        extraLargeSize: 20
                                      ),
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ).animate().fade(delay: 400.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Stack(
                  children: [
                    // Rounded container (visible when expanded)
                    Opacity(
                      opacity: _isAppBarCollapsed ? 0.0 : 1.0,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: ResponsiveUtils.getResponsiveWidth(context, 0.02),
                          top: ResponsiveUtils.getResponsiveHeight(context, 0.01)
                        ),
                        width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 35, mediumSize: 40, largeSize: 40, extraLargeSize: 45),
                        height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 35, mediumSize: 40, largeSize: 40, extraLargeSize: 45),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 10, mediumRadius: 12, largeRadius: 12, extraLargeRadius: 14)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 4, mediumRadius: 6, largeRadius: 6, extraLargeRadius: 8),
                              offset: Offset(0, ResponsiveUtils.getResponsiveHeight(context, 0.003)),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 10, extraLargeRadius: 12),
                              offset: Offset(0, -ResponsiveUtils.getResponsiveHeight(context, 0.003)),
                              spreadRadius: -3,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black87, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 18, largeSize: 18, extraLargeSize: 20)),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 35, mediumSize: 40, largeSize: 40, extraLargeSize: 45),
                            minHeight: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 35, mediumSize: 40, largeSize: 40, extraLargeSize: 45),
                          ),
                        ),
                      ),
                    ),
                    // Simple icon (visible when collapsed)
                    Opacity(
                      opacity: _isAppBarCollapsed ? 1.0 : 0.0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 22, mediumSize: 24, largeSize: 24, extraLargeSize: 26)),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 6, mediumPadding: 8, largePadding: 8, extraLargePadding: 10)),
                        constraints: BoxConstraints(
                          minWidth: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 35, mediumSize: 40, largeSize: 40, extraLargeSize: 45),
                          minHeight: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 35, mediumSize: 40, largeSize: 40, extraLargeSize: 45),
                        ),
                      ),
                    ),
                  ],
                ),

              ),
              
              // Description Section
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    ResponsiveUtils.getResponsiveWidth(context, 0.05), 
                    ResponsiveUtils.getResponsivePadding(context, smallPadding: 32, mediumPadding: 40, largePadding: 48),
                    ResponsiveUtils.getResponsiveWidth(context, 0.05),
                    ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 24)
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
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 20, extraLargePadding: 24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 8, mediumPadding: 8, largePadding: 8, extraLargePadding: 10)),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 8, largeRadius: 8, extraLargeRadius: 10)),
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                color: AppColors.primary,
                                size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 20, largeSize: 20, extraLargeSize: 24),
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.02)),
                            Text(
                              localizations.aboutThisHotel,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                        
                        // Hotel Description
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isExpanded 
                                ? hotel.getLocalizedDescription(context)
                                : (hotel.getLocalizedDescription(context).length > 150 
                                    ? '${hotel.getLocalizedDescription(context).substring(0, 150)}...' 
                                    : hotel.getLocalizedDescription(context)),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 15, largeSize: 16, extraLargeSize: 18),
                              ),
                            ),
                            if (hotel.getLocalizedDescription(context).length > 150) ...[
                              SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.getResponsiveWidth(context, 0.03),
                                    vertical: ResponsiveUtils.getResponsiveHeight(context, 0.008),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 15, mediumRadius: 18, largeRadius: 18, extraLargeRadius: 20)),
                                  ),
                                  child: Text(
                                    _isExpanded ? localizations.readLess : localizations.readMore,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13, largeSize: 13, extraLargeSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Explore Section
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: HotelExploreSection(hotel: hotel),
                ),
              ),
              
              // Gallery Section
              SliverToBoxAdapter(
                child: Container(
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
                              child: Icon(
                                Icons.photo_library_outlined,
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
                                    localizations.gallery,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    localizations.exploreHotelThroughImages,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // View All Button
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MainGalleryScreen(
                                      hotel: hotel,
                                      initialTabIndex: 0,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      localizations.viewAll,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.primary,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Gallery Horizontal List
                      Builder(
                        builder: (context) {
                          List<String> displayImages = [];
                          if (hotel.galleryItems != null && hotel.galleryItems!.isNotEmpty) {
                            displayImages = hotel.galleryItems!
                                .where((item) => item.image != null && item.image!.isNotEmpty)
                                .map((item) => item.image!)
                                .toList();
                          } else if (hotel.gallery.isNotEmpty) {
                            displayImages = List.from(hotel.gallery);
                          }
                          
                          // Shuffle and take up to 8 images
                          displayImages.shuffle();
                          final imagesToShow = displayImages.take(8).toList();

                          if (imagesToShow.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imagesToShow.length,
                                itemBuilder: (context, index) {
                                  final imageUrl = imagesToShow[index];
                                  
                                  return Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MainGalleryScreen(
                                              hotel: hotel,
                                              initialTabIndex: 0, // Keep categories inside MainGalleryScreen
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: (imageUrl.startsWith('http'))
                                              ? Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: Colors.grey.withOpacity(0.2),
                                                    child: const Center(
                                                      child: Icon(Icons.image, color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
              // Offers Section
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: HotelOffersSection(
                    offers: provider.getOffersForHotel(hotel.slug ?? ''), 
                    hotel: hotel
                  ),
                ),
              ),

              // Location Section
              SliverToBoxAdapter(
                child: Container(
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
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 20, extraLargePadding: 24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 8, mediumPadding: 8, largePadding: 8, extraLargePadding: 10)),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 8, largeRadius: 8, extraLargeRadius: 10)),
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                                size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 18, mediumSize: 20, largeSize: 20, extraLargeSize: 24),
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
                            Text(
                              localizations.location,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                        
                        // Address Card
                        Container(
                          padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 16, largePadding: 16, extraLargePadding: 20)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.05),
                                AppColors.primary.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 12, largeRadius: 12, extraLargeRadius: 16)),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 8, mediumPadding: 8, largePadding: 8, extraLargePadding: 10)),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 8, largeRadius: 8, extraLargeRadius: 10)),
                                    ),
                                    child: Icon(
                                      Icons.place,
                                      color: AppColors.primary,
                                      size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 14, mediumSize: 16, largeSize: 16, extraLargeSize: 18),
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.hotelAddress,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13, largeSize: 13, extraLargeSize: 14),
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.008)),
                                        Text(
                                          hotel.getLocalizedAddress(context),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            height: 1.5,
                                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 15, largeSize: 15, extraLargeSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                        
                        // Real Google Maps View
                        Container(
                          height: ResponsiveUtils.getResponsiveHeight(context, 0.25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 12, largeRadius: 12, extraLargeRadius: 16)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 12, largeRadius: 12, extraLargeRadius: 16)),
                            child: !_mapReady
                                ? Container(
                                    color: Theme.of(context).cardColor,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: AppColors.primary.withOpacity(0.6),
                                            size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 28, mediumSize: 32, largeSize: 32, extraLargeSize: 36),
                                          ),
                                          const SizedBox(height: 8),
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: coordinates,
                                      zoom: 15,
                                    ),
                                    onMapCreated: (GoogleMapController controller) {
                                      _mapController = controller;
                                      _currentMapCoordinates = coordinates;
                                      controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(target: coordinates, zoom: 15),
                                        ),
                                      );
                                    },
                                    markers: {
                                      Marker(
                                        markerId: MarkerId('hotel_location_${hotel.id}'),
                                        position: coordinates,
                                        icon: BitmapDescriptor.defaultMarkerWithHue(
                                          BitmapDescriptor.hueAzure,
                                        ),
                                        infoWindow: InfoWindow(
                                          title: hotel.getLocalizedName(context),
                                          snippet: hotel.getLocalizedAddress(context),
                                        ),
                                      ),
                                    },
                                    mapType: MapType.normal,
                                    zoomControlsEnabled: true,
                                    scrollGesturesEnabled: true,
                                    rotateGesturesEnabled: false,
                                    tiltGesturesEnabled: false,
                                  ),
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                        
                        // Location Features
                        Row(
                          children: [
                            Expanded(
                              child: _buildLocationFeature(
                                context,
                                Icons.directions_car,
                                localizations.parkingAvailable,
                                localizations.freeParkingForGuests,
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
                            Expanded(
                              child: _buildLocationFeature(
                                context,
                                Icons.train,
                                localizations.nearTransit,
                                localizations.fiveMinWalkToStation,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.015)),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildLocationFeature(
                                context,
                                Icons.restaurant,
                                localizations.diningNearby,
                                localizations.restaurantsWithin200m,
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
                            Expanded(
                              child: _buildLocationFeature(
                                context,
                                Icons.shopping_bag,
                                localizations.shopping,
                                localizations.mall10MinAway,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                        
                        // Action Buttons Row
                        Column(
                          children: [
                            // Get Directions Button
                            GestureDetector(
                              onTap: () => _launchDirections(coordinates),
                              child: SizedBox(
                                width: double.infinity,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 16, largePadding: 16, extraLargePadding: 20),
                                    vertical: ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 12, largePadding: 12, extraLargePadding: 14),
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withOpacity(0.8),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 20, mediumRadius: 25, largeRadius: 25, extraLargeRadius: 30)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 6, mediumRadius: 8, largeRadius: 8, extraLargeRadius: 10),
                                        offset: Offset(0, ResponsiveUtils.getResponsiveHeight(context, 0.01)),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions,
                                        color: Colors.white,
                                        size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 18, largeSize: 18, extraLargeSize: 20),
                                      ),
                                      SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.02)),
                                      Text(
                                        localizations.getDirections,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 15, largeSize: 15, extraLargeSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),
                            
                            // Open in Maps Button
                            GestureDetector(
                              onTap: () => _openMaps(coordinates),
                              child: SizedBox(
                                width: double.infinity,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 16, largePadding: 16, extraLargePadding: 20),
                                    vertical: ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 12, largePadding: 12, extraLargePadding: 14),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 20, mediumRadius: 25, largeRadius: 25, extraLargeRadius: 30)),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.map,
                                        color: AppColors.primary,
                                        size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 18, largeSize: 18, extraLargeSize: 20),
                                      ),
                                      SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.02)),
                                      Text(
                                        localizations.openMaps,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 15, largeSize: 15, extraLargeSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
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
              
              // Contacts Section
              SliverToBoxAdapter(
                child: Container(
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
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 20, extraLargePadding: 24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 40, mediumSize: 48, largeSize: 48, extraLargeSize: 56),
                              height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 40, mediumSize: 48, largeSize: 48, extraLargeSize: 56),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.15),
                                    AppColors.primary.withOpacity(0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 10, mediumRadius: 12, largeRadius: 12, extraLargeRadius: 14)),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.contact_page_outlined,
                                color: AppColors.primary,
                                size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 18, mediumSize: 22, largeSize: 22, extraLargeSize: 26),
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.contactUs,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.008)),
                                  Text(
                                    localizations.connectWithUs,
                                    style: GoogleFonts.roboto(
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 11, mediumSize: 13, largeSize: 13, extraLargeSize: 15),
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 24)),
                        
                        // Contact Options - Centered Responsive Layout
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: ResponsiveUtils.getResponsiveWidth(context, 0.85),
                            ),
                            padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 20, extraLargePadding: 24)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 16, mediumRadius: 20, largeRadius: 20, extraLargeRadius: 24)),
                              border: Border.all(
                                color: Theme.of(context).dividerColor.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 16, mediumRadius: 20, largeRadius: 20, extraLargeRadius: 24),
                                  offset: Offset(0, ResponsiveUtils.getResponsiveHeight(context, 0.02)),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.008)),
                                Text(
                                  localizations.followUsOnSocialMedia,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 11, mediumSize: 12, largeSize: 12, extraLargeSize: 13),
                                  ),
                                ),
                                
                                SizedBox(height: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 24)),
                                
                                // Responsive Icon Row
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final containerWidth = constraints.maxWidth;
                                    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
                                    
                                    final responsiveIconSize = ResponsiveUtils.getResponsiveIconSize(context, smallSize: 45, mediumSize: 50, largeSize: 55, extraLargeSize: 60);
                                    final iconSize = isSmallScreen 
                                        ? (responsiveIconSize < containerWidth / 4.5 ? responsiveIconSize : containerWidth / 4.5)
                                        : ResponsiveUtils.getResponsiveIconSize(context, smallSize: 50, mediumSize: 55, largeSize: 60, extraLargeSize: 65);
                                    
                                    return Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: ResponsiveUtils.getResponsiveWidth(context, 0.03),
                                      runSpacing: ResponsiveUtils.getResponsiveHeight(context, 0.02),
                                      children: [
                                        if (hotel.socialLinks != null)
                                          ...hotel.socialLinks!.map((link) {
                                            return _buildContactIcon(
                                              url: link.url,
                                              logoUrl: link.cleanIconUrl,
                                              fallbackIcon: _getPlatformIcon(link.platform),
                                              size: iconSize,
                                              tooltip: link.platform,
                                            );
                                          }),
                                        
                                        if (hotel.phone != null && hotel.phone!.trim().isNotEmpty)
                                          _buildContactIcon(
                                            url: 'tel:${hotel.phone!.trim()}',
                                            fallbackIcon: Icons.phone,
                                            size: iconSize,
                                            tooltip: hotel.phone,
                                          ),
                                        
                                        if (hotel.whats != null && hotel.whats!.trim().isNotEmpty)
                                          _buildContactIcon(
                                            url: 'https://wa.me/${hotel.whats!.trim()}',
                                            fallbackIcon: Icons.chat,
                                            size: iconSize,
                                            tooltip: 'WhatsApp: ${hotel.whats}',
                                          ),
                                          
                                        if (hotel.email != null && hotel.email!.trim().isNotEmpty)
                                          _buildContactIcon(
                                            url: 'mailto:${hotel.email!.trim()}',
                                            fallbackIcon: Icons.email_outlined,
                                            size: iconSize,
                                            tooltip: hotel.email,
                                          ),
                                          
                                        _buildContactIcon(
                                          url: 'https://triumphhotel.com/',
                                          logoUrl: hotel.logoUrl.trim().isNotEmpty ? hotel.logoUrl.trim() : null,
                                          assetLogo: 'assets/icons/logo.png',
                                          fallbackIcon: Icons.public,
                                          size: iconSize,
                                          tooltip: 'Triumph Hotels',
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Extra space at bottom
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'From',
                      style: GoogleFonts.roboto(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.hotel.name.toLowerCase().contains('luxury') 
                          ? '\$140'
                          : widget.hotel.name.toLowerCase().contains('plaza') 
                              ? '\$50' 
                              : '\$42',
                      style: GoogleFonts.roboto(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/night',
                      style: GoogleFonts.roboto(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        String bookingUrl = "";
                        final name = widget.hotel.name.toLowerCase();
                        
                        if (name.contains('luxury')) {
                          bookingUrl = "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=37005&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
                        } else if (name.contains('plaza')) {
                          bookingUrl = "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=37004&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
                        } else if (name.contains('white sands')) {
                          bookingUrl = "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=41399&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
                        } else {
                          bookingUrl = "https://triumphhotel.com/"; // Fallback
                        }
                        
                        _launchURL(bookingUrl);
                      },
                      child: Center(
                        child: Text(
                          localizations.bookNow,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFeature(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
