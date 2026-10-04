import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/models/meeting_room_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  final HotelModel hotel;
  
  const EventsScreen({super.key, required this.hotel});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late PageController _pageController;
  late ScrollController _scrollController;
  int _currentImageIndex = 0;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _pageController.addListener(_onPageChange);
    _scrollController.addListener(_onScroll);

    // Fetch meeting rooms & hotel details for banner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hotel.slug != null) {
        Provider.of<HotelProvider>(context, listen: false).fetchHotelMeetingRooms(widget.hotel.slug!);
        if (widget.hotel.banners == null || widget.hotel.banners!.isEmpty) {
          Provider.of<HotelProvider>(context, listen: false).fetchHotelDetail(widget.hotel.slug!);
        }
      }
    });
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
      final shouldShowTitle = offset > 200;
      if (shouldShowTitle != _showTitle) {
        setState(() {
          _showTitle = shouldShowTitle;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          final detailedHotel = widget.hotel.slug != null 
              ? provider.getDetailedHotel(widget.hotel.slug!) 
              : null;
          final hotel = detailedHotel ?? widget.hotel;
          final banner = hotel.getBanner(['meeting', 'meetings', 'meeting_rooms', 'meeting-rooms']);
          final bannerImage = hotel.getBannerImage(['meeting', 'meetings', 'meeting_rooms', 'meeting-rooms']);

          final meetingRooms = widget.hotel.slug != null 
              ? provider.getMeetingRoomsForHotel(widget.hotel.slug!) 
              : null;
          
          if (provider.isLoading && meetingRooms == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (meetingRooms == null || meetingRooms.isEmpty) {
             return _buildEmptyState(context, localizations);
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
                    "Events & Meetings",
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
                      // Top background banner image from API if available, else PageView
                      if (bannerImage != null && bannerImage.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: bannerImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
                          errorWidget: (context, url, error) => _buildImagePlaceholder(),
                        )
                      else
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentImageIndex = index),
                          itemCount: meetingRooms.length,
                          itemBuilder: (context, index) {
                            final room = meetingRooms[index];
                            final imageUrl = room.imageCover;
                            return (imageUrl.startsWith('http'))
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
                                  errorWidget: (context, url, error) => _buildImagePlaceholder(),
                                )
                              : Image.asset(
                                  'assets/images/plaza/$imageUrl',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                                );
                          },
                        ),
                      
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
                                  "Events & Meetings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 28, mediumSize: 34),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner?.title?.isNotEmpty == true
                                      ? banner!.title!
                                      : "Exceptional venues for memorable moments",
                                  style: TextStyle(
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
              
              // Meeting Rooms Grid
              SliverPadding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
                sliver: isSmallScreen 
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
                          child: _buildMeetingRoomCard(meetingRooms[index]),
                        ),
                        childCount: meetingRooms.length,
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtils.getResponsiveColumns(context),
                        crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24),
                        mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24),
                        mainAxisExtent: ResponsiveUtils.getResponsiveHeight(context, 0.55),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMeetingRoomCard(meetingRooms[index]),
                        childCount: meetingRooms.length,
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_seat_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No meeting rooms found',
            style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Go Back', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
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
          : const Icon(Icons.meeting_room_outlined, color: Colors.white, size: 48),
      ),
    );
  }

  Widget _buildMeetingRoomCard(MeetingRoomModel room) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              meetingRoom: room,
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
              color: Colors.black.withOpacity(0.06),
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
                    (room.imageCover.startsWith('http'))
                      ? CachedNetworkImage(
                          imageUrl: room.imageCover,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
                          errorWidget: (context, url, error) => _buildImagePlaceholder(),
                        )
                      : Image.asset(
                          'assets/images/plaza/${room.imageCover}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                        ),
                    Positioned(
                      bottom: -1,
                      left: 0,
                      right: 0,
                      height: 100,
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
                    if (room.canHostWedding)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Weddings",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 22),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(Icons.people_outline, "${room.capacity} Guests"),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.square_foot, "${room.area.toInt()} m²"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      room.description,
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 13, mediumSize: 14),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[800], fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
