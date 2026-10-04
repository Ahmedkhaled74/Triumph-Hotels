import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/models/restaurant_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'restaurant_detail_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  final HotelModel hotel;
  
  const RestaurantsScreen({super.key, required this.hotel});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
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

    // Fetch restaurants & hotel details for banner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hotel.slug != null) {
        Provider.of<HotelProvider>(context, listen: false).fetchHotelRestaurants(widget.hotel.slug!);
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
          final banner = hotel.getBanner(['dining', 'restaurant', 'restaurants']);
          final bannerImage = hotel.getBannerImage(['dining', 'restaurant', 'restaurants']);

          final restaurants = widget.hotel.slug != null 
              ? provider.getRestaurantsForHotel(widget.hotel.slug!) 
              : null;
          
          if (provider.isLoading && restaurants == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (restaurants == null || restaurants.isEmpty) {
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
                    localizations.restaurants,
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
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            final imageUrl = restaurant.imageCover;
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
                                  localizations.restaurants,
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
                                      : localizations.discoverOurCulinaryDelights,
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
              
              // Restaurants Grid/List
              SliverPadding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
                sliver: isSmallScreen 
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildRestaurantCard(restaurants[index]),
                        ),
                        childCount: restaurants.length,
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtils.getResponsiveColumns(context),
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        mainAxisExtent: 380,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildRestaurantCard(restaurants[index]),
                        childCount: restaurants.length,
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
          Icon(Icons.restaurant_menu_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No restaurants found',
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
          : const Icon(Icons.restaurant, color: Colors.white, size: 48),
      ),
    );
  }

  Widget _buildRestaurantCard(RestaurantModel restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              restaurant: restaurant,
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
                    (restaurant.imageCover.startsWith('http'))
                      ? CachedNetworkImage(
                          imageUrl: restaurant.imageCover,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
                          errorWidget: (context, url, error) => _buildImagePlaceholder(),
                        )
                      : Image.asset(
                          'assets/images/plaza/${restaurant.imageCover}',
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
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          restaurant.cuisine,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 22),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                      ],
                    ),
                    if (restaurant.slogan != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        restaurant.slogan!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          restaurant.openingHours,
                          style: TextStyle(
                            color: Colors.grey[600], 
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16)
                          ),
                        ),
                      ],
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
