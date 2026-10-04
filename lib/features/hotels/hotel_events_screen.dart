import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/models/event_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'hotel_event_detail_screen.dart';

class HotelEventsScreen extends StatefulWidget {
  final HotelModel hotel;
  
  const HotelEventsScreen({super.key, required this.hotel});

  @override
  State<HotelEventsScreen> createState() => _HotelEventsScreenState();
}

class _HotelEventsScreenState extends State<HotelEventsScreen> {
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

    // Fetch events & hotel details for banner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hotel.slug != null) {
        Provider.of<HotelProvider>(context, listen: false).fetchHotelEvents(widget.hotel.slug!);
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
          final banner = hotel.getBanner(['wedding', 'weddings', 'events', 'event']);
          final bannerImage = hotel.getBannerImage(['wedding', 'weddings', 'events', 'event']);

          final events = widget.hotel.slug != null 
              ? provider.getEventsForHotel(widget.hotel.slug!) 
              : null;
          
          if (provider.isLoading && events == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (events == null || events.isEmpty) {
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
                    localizations.events,
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
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            final imageUrl = event.image;
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
                        height: ResponsiveUtils.getResponsiveHeight(context, 0.2),
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
                          bottom: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 30, largePadding: 40),
                          left: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 30, largePadding: 40),
                          right: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 30, largePadding: 40),
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.events,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 28, mediumSize: 34, largeSize: 42),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),
                                Text(
                                  banner?.title?.isNotEmpty == true
                                      ? banner!.title!
                                      : localizations.discoverOurCulinaryDelights,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18, largeSize: 20),
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
              
              // Events Grid
              SliverPadding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24, largePadding: 32)),
                sliver: isSmallScreen 
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
                          child: _buildEventCard(events[index]),
                        ),
                        childCount: events.length,
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtils.getResponsiveColumns(context),
                        crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24, largePadding: 32),
                        mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24, largePadding: 32),
                        mainAxisExtent: ResponsiveUtils.getResponsiveHeight(context, isSmallScreen ? 0.45 : 0.48),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildEventCard(events[index]),
                        childCount: events.length,
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
          Icon(Icons.event_outlined, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 48, mediumSize: 64), color: Colors.grey[400]),
          SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
          Text(
            'No active events found',
            style: TextStyle(
              color: Colors.grey[600], 
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18), 
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsivePadding(context, smallPadding: 24, mediumPadding: 32),
                vertical: ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 16),
              ),
            ),
            child: Text(
              'Go Back', 
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16),
              )
            ),
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
          ? SizedBox(
              width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 24, mediumSize: 30),
              height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 24, mediumSize: 30),
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Icon(Icons.event, color: Colors.white, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 36, mediumSize: 48)),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final cardBorderRadius = ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 16, mediumRadius: 20);
    
    return GestureDetector(
      onTap: () {
        if (widget.hotel.slug != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelEventDetailScreen(
                hotelSlug: widget.hotel.slug!,
                event: event,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: ResponsiveUtils.getResponsiveHeight(context, 0.22),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'event_image_${event.id}',
                      child: (event.image.startsWith('http'))
                        ? CachedNetworkImage(
                            imageUrl: event.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
                            errorWidget: (context, url, error) => _buildImagePlaceholder(),
                          )
                        : Image.asset(
                            'assets/images/plaza/${event.image}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                          ),
                    ),
                    Positioned(
                      bottom: -1,
                      left: 0,
                      right: 0,
                      height: ResponsiveUtils.getResponsiveHeight(context, 0.1),
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
                    Positioned(
                      top: ResponsiveUtils.getResponsivePadding(context, smallPadding: 12),
                      right: ResponsiveUtils.getResponsivePadding(context, smallPadding: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.startDate,
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 10, mediumSize: 11), 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 22, largeSize: 24),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.005)),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined, 
                          size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 14, mediumSize: 16), 
                          color: AppColors.primary
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: TextStyle(
                              color: AppColors.primary, 
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13), 
                              fontWeight: FontWeight.w600
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),
                    Text(
                      event.shortDescription,
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 13, mediumSize: 14, largeSize: 15),
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
}
