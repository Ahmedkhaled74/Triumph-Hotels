import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/models/room_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'room_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';

class RoomsScreen extends StatefulWidget {
  final HotelModel hotel;
  
  const RoomsScreen({super.key, required this.hotel});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late PageController _pageController;
  late ScrollController _scrollController;
  int _currentImageIndex = 0;
  bool _showTitle = false;
  
  final ApiClient _apiClient = ApiClient();
  List<RoomModel> _rooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _pageController.addListener(_onPageChange);
    _scrollController.addListener(_onScroll);
    _fetchRooms();

    // Fetch detailed hotel info for banners if not available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hotel.slug != null && (widget.hotel.banners == null || widget.hotel.banners!.isEmpty)) {
        Provider.of<HotelProvider>(context, listen: false).fetchHotelDetail(widget.hotel.slug!);
      }
    });
  }

  Future<void> _fetchRooms() async {
    if (widget.hotel.slug == null) {
      setState(() {
        _rooms = _getOfflineRooms();
        _isLoading = false;
      });
      return;
    }

    try {
      final List<dynamic> data = await _apiClient.getHotelRooms(widget.hotel.slug!);
      if (mounted) {
        setState(() {
          _rooms = data.map((json) => RoomModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _rooms = _getOfflineRooms(); // Fallback to offline rooms on error
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChange);
    _pageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onPageChange() {
    if (_pageController.hasClients) {
      final newIndex = _pageController.page?.round() ?? 0;
      if (newIndex != _currentImageIndex) {
        setState(() {
          _currentImageIndex = newIndex;
        });
      }
    }
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

  // Fallback rooms
  List<RoomModel> _getOfflineRooms() {
    switch (widget.hotel.id) {
      case '1': // Triumph Plaza
        return getPlazaRooms();
      default:
        return getPlazaRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<HotelProvider>(
        builder: (context, hotelProvider, child) {
          final detailedHotel = widget.hotel.slug != null 
              ? hotelProvider.getDetailedHotel(widget.hotel.slug!) 
              : null;
          final hotel = detailedHotel ?? widget.hotel;
          final banner = hotel.getBanner(['rooms', 'room']);
          final bannerImage = hotel.getBannerImage(['rooms', 'room']);

          if (_isLoading) {
            return _buildLoadingState();
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: ResponsiveUtils.getResponsiveHeight(context, isSmallScreen ? 0.35 : 0.4),
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
                  child: Text(
                    localizations.roomsAndSuites,
                    style: GoogleFonts.roboto(
                      color: _showTitle 
                          ? (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)
                          : Colors.white,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Top background banner image from API if available, else Room images PageView
                      if (bannerImage != null && bannerImage.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: bannerImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => _buildPlaceholder(isLoading: true),
                          errorWidget: (context, url, error) => _buildPlaceholder(),
                        )
                      else if (_rooms.isNotEmpty)
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentImageIndex = index),
                          itemCount: _rooms.length > 5 ? 5 : _rooms.length,
                          itemBuilder: (context, index) {
                            final imageUrl = _rooms[index].imageUrl;
                            return (imageUrl.startsWith('http'))
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => _buildPlaceholder(isLoading: true),
                                    errorWidget: (context, url, error) => _buildPlaceholder(),
                                  )
                                : Image.asset(
                                    'assets/images/plaza/$imageUrl',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                  );
                          },
                        )
                      else
                        _buildPlaceholder(),
                      
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
                                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                                  Theme.of(context).scaffoldBackgroundColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      if (!_showTitle)
                        Positioned(
                          bottom: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 30),
                          left: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 30),
                          right: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 30),
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.roomsAndSuites,
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 28, mediumSize: 34),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner?.title?.isNotEmpty == true
                                      ? banner!.title!
                                      : localizations.chooseYourPerfectAccommodation,
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18),
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
              
              // Error Message
              if (_errorMessage != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Could not fetch latest rooms. Showing offline data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700], fontSize: 13),
                    ),
                  ),
                ),

              // Rooms Grid
              SliverPadding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveUtils.getResponsiveColumns(context),
                    crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24),
                    mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24),
                    mainAxisExtent: ResponsiveUtils.getResponsiveHeight(context, isSmallScreen ? 0.53 : 0.45),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRoomCard(_rooms[index]),
                    childCount: _rooms.length,
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.1)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
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
          ? const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.hotel, color: Colors.white, size: 48),
      ),
    );
  }

  String _getBookingUrl() {
    final id = widget.hotel.id.toString();
    final slug = widget.hotel.slug?.toLowerCase() ?? '';
    final name = widget.hotel.name.toLowerCase();

    if (id == '2' || slug.contains('luxury') || name.contains('luxury')) {
      return "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=37005&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
    } else if (id == '3' || slug.contains('white-sands') || name.contains('white sands')) {
      return "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=41399&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
    } else {
      return "https://be.synxis.com/?adult=1&arrive=2026-05-13&chain=29071&child=0&currency=USD&depart=2026-05-14&hotel=37004&level=hotel&locale=en-US&productcurrency=USD&rooms=1";
    }
  }

  Widget _buildRoomCard(RoomModel room) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(
              room: room,
              hotelSlug: widget.hotel.slug ?? '',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    (room.imageUrl.startsWith('http'))
                        ? CachedNetworkImage(
                            imageUrl: room.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => _buildPlaceholder(isLoading: true),
                            errorWidget: (context, url, error) => _buildPlaceholder(),
                          )
                        : Image.asset(
                            'assets/images/plaza/${room.imageUrl}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          ),
                    Positioned(
                      bottom: -1,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).cardColor.withOpacity(0),
                              Theme.of(context).cardColor.withOpacity(0.8),
                              Theme.of(context).cardColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (room.isSuit)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.goldLight, width: 1),
                          ),
                          child: Text(
                            'SUITE',
                            style: GoogleFonts.roboto(
                              color: AppColors.goldLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: GoogleFonts.greatVibes(
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 22),
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          _buildSmallMetric(Icons.bed_outlined, room.bedType ?? 'King'),
                          const SizedBox(width: 12),
                          _buildSmallMetric(Icons.visibility_outlined, room.roomViews ?? 'City'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSmallMetric(Icons.people_outline, room.numberOfPersons ?? '${room.maxGuests} Guests'),
                          const SizedBox(width: 12),
                          _buildSmallMetric(Icons.square_foot, '${room.size.toInt()} m²'),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RoomDetailsScreen(
                                  room: room,
                                  hotelSlug: widget.hotel.slug ?? '',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.primary, width: 1),
                            ),
                          ),
                          child: Text(
                            'VIEW DETAILS',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(_getBookingUrl());
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.primary, width: 1),
                            ),
                          ),
                          child: Text(
                            'BOOK NOW',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13),
                              letterSpacing: 1.2,
                            ),
                          ),
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
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSmallMetric(IconData icon, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.7)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13),
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
