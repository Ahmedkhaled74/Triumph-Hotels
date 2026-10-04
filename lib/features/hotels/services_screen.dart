import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';

class ServicesScreen extends StatefulWidget {
  final HotelModel hotel;
  
  const ServicesScreen({super.key, required this.hotel});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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

  // Get services based on hotel
  List<Map<String, dynamic>> _getServices([HotelModel? hotel]) {
    final targetHotel = hotel ?? widget.hotel;
    if (targetHotel.hotelServices != null && targetHotel.hotelServices!.isNotEmpty) {
      return targetHotel.hotelServices!.map((service) {
        return {
          'id': service.id.toString(),
          'title': service.title,
          'description': service.description,
          'icon': _getServiceIcon(service.icon),
          'features': [
            if (service.price != null && service.price!.isNotEmpty) 
              'Price: ${service.price} ${service.priceCurrency ?? ''} ${service.pricingType ?? ''}',
            'Available Now',
            if (service.featured) 'Featured Service',
          ],
          'hours': '24/7', // Default fallback
          'color': AppColors.primary,
          'image': service.image,
        };
      }).toList();
    }

    // Fallback to hardcoded data if API returns nothing
    switch (widget.hotel.id) {
      case '1': // Triumph Plaza - Heliopolis
        return [
          {
            'id': 'airport',
            'title': 'Airport Pick Up',
            'description': 'Comfortable and reliable airport transfer service to and from Cairo International Airport',
            'icon': Icons.flight_land,
            'features': [
              '24/7 Availability',
              'Professional Drivers',
              'Luxury Vehicles',
              'Flight Monitoring',
              'Luggage Assistance',
              'Meet & Greet Service'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'wifi',
            'title': 'Free WiFi',
            'description': 'High-speed wireless internet access throughout the hotel premises',
            'icon': Icons.wifi,
            'features': [
              'High-Speed Connection',
              'All Areas Covered',
              'Free of Charge',
              'Secure Network',
              'Multiple Device Support',
              'Technical Support'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'atm',
            'title': 'ATM Center',
            'description': 'Convenient banking services with on-site ATM machines',
            'icon': Icons.atm,
            'features': [
              '24/7 Access',
              'Multiple Banks',
              'Secure Transactions',
              'Currency Exchange',
              'Credit Card Support',
              'Receipt Available'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'concierge',
            'title': 'Concierge',
            'description': 'Professional assistance for travel arrangements, reservations, and local recommendations',
            'icon': Icons.room_service,
            'features': [
              '24/7 Availability',
              'Travel Arrangements',
              'Restaurant Reservations',
              'Local Tours',
              'Event Planning',
              'Personal Shopping'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'parking',
            'title': 'Parking Space',
            'description': 'Secure and spacious parking facilities for hotel guests',
            'icon': Icons.local_parking,
            'features': [
              '24/7 Security',
              'Valet Service',
              'Covered Parking',
              'EV Charging Stations',
              'CCTV Surveillance',
              'Spacious Layout'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'laundry',
            'title': 'Laundry',
            'description': 'Professional laundry and dry cleaning services with quick turnaround',
            'icon': Icons.local_laundry_service,
            'features': [
              'Same Day Service',
              'Dry Cleaning',
              'Ironing Service',
              'Shoe Shine',
              'Delicate Care',
              'Express Delivery'
            ],
            'hours': '7:00 AM - 10:00 PM',
            'color': AppColors.primary,
          },
          {
            'id': 'room_service',
            'title': 'Room Service',
            'description': 'In-room dining service with extensive menu options available 24/7',
            'icon': Icons.room_service,
            'features': [
              '24/7 Availability',
              'Full Menu',
              'Special Dietary Options',
              'Fast Delivery',
              'Professional Staff',
              'Table Settings'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'limousine',
            'title': 'Limousine Service',
            'description': 'Premium luxury transportation for special occasions and business meetings',
            'icon': Icons.airport_shuttle,
            'features': [
              'Luxury Vehicles',
              'Professional Chauffeurs',
              'Airport Transfers',
              'City Tours',
              'Event Transportation',
              'Corporate Services'
            ],
            'hours': '6:00 AM - 11:00 PM',
            'color': AppColors.primary,
          },
          {
            'id': 'wheelchair',
            'title': 'Wheelchair Friendly',
            'description': 'Full accessibility features and assistance for guests with mobility needs',
            'icon': Icons.accessible,
            'features': [
              'Ramp Access',
              'Elevator Access',
              'Accessible Rooms',
              'Wheelchair Available',
              'Trained Staff',
              'Emergency Support'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'bazaar',
            'title': 'Bazaar',
            'description': 'Traditional shopping experience with authentic Egyptian products and souvenirs',
            'icon': Icons.store,
            'features': [
              'Authentic Products',
              'Traditional Crafts',
              'Souvenirs',
              'Jewelry',
              'Textiles',
              'Gift Wrapping'
            ],
            'hours': '9:00 AM - 10:00 PM',
            'color': AppColors.primary,
          }
        ];
      case '2': // Triumph Luxury - New Capital
        return [
          {
            'id': 'airport',
            'title': 'Airport Pick Up',
            'description': 'Luxury airport transfer with premium vehicles and personalized service',
            'icon': Icons.flight_land,
            'features': [
              'VIP Service',
              'Luxury Vehicles',
              'Personal Butler',
              'Champagne Welcome',
              'Priority Access',
              'Private Transfer'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          },
          {
            'id': 'concierge',
            'title': 'Premium Concierge',
            'description': 'Exclusive concierge services with personalized assistance',
            'icon': Icons.room_service,
            'features': [
              'Personal Butler',
              'VIP Services',
              'Private Chef',
              'Yacht Charter',
              'Helicopter Transfer'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          }
        ];
      case '3': // Triumph White Sands - North Coast
        return [
          {
            'id': 'airport',
            'title': 'Airport Pick Up',
            'description': 'Beach resort airport transfer with coastal views',
            'icon': Icons.flight_land,
            'features': [
              'Scenic Route',
              'Beach Transfer',
              'Luxury Vehicles',
              'Coastal Views',
              'Resort Welcome',
              'Luggage Service'
            ],
            'hours': '6:00 AM - 10:00 PM',
            'color': AppColors.primary,
          },
          {
            'id': 'bazaar',
            'title': 'Beach Bazaar',
            'description': 'Coastal shopping experience with beach products and local crafts',
            'icon': Icons.store,
            'features': [
              'Beach Products',
              'Local Crafts',
              'Souvenirs',
              'Swimwear',
              'Beach Accessories',
              'Gift Items'
            ],
            'hours': '9:00 AM - 8:00 PM',
            'color': AppColors.primary,
          }
        ];
      default:
        return [
          {
            'id': 'concierge',
            'title': 'Concierge Services',
            'description': '24/7 personalized assistance for all your needs',
            'icon': Icons.room_service,
            'features': [
              '24/7 Availability',
              'Travel Arrangements',
              'Restaurant Reservations'
            ],
            'hours': '24/7',
            'color': AppColors.primary,
          }
        ];
    }
  }

  IconData _getServiceIcon(String? iconName) {
    if (iconName == null) return Icons.star;
    
    // Map font awesome or other icon names to Flutter Material Icons
    final name = iconName.toLowerCase();
    if (name.contains('coffee')) return Icons.coffee;
    if (name.contains('wifi')) return Icons.wifi;
    if (name.contains('shuttle') || name.contains('bus')) return Icons.airport_shuttle;
    if (name.contains('pool')) return Icons.pool;
    if (name.contains('gym') || name.contains('fitness')) return Icons.fitness_center;
    if (name.contains('spa')) return Icons.spa;
    if (name.contains('restaurant') || name.contains('food')) return Icons.restaurant;
    if (name.contains('parking')) return Icons.local_parking;
    if (name.contains('laundry')) return Icons.local_laundry_service;
    if (name.contains('concierge')) return Icons.room_service;
    if (name.contains('flight') || name.contains('airport')) return Icons.flight_land;
    if (name.contains('atm') || name.contains('money')) return Icons.atm;
    if (name.contains('store') || name.contains('shop')) return Icons.store;
    if (name.contains('accessibility')) return Icons.accessible;
    
    return Icons.star; // Default
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          final detailedHotel = widget.hotel.slug != null 
              ? provider.getDetailedHotel(widget.hotel.slug!) 
              : null;
          final hotel = detailedHotel ?? widget.hotel;
          final services = _getServices(hotel);
          final banner = hotel.getBanner(['services', 'service', 'features', 'feature']);
          final bannerImage = hotel.getBannerImage(['services', 'service', 'features', 'feature']);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: ResponsiveUtils.scaleHeight(context, 200),
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
                      localizations.services,
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
                      // Top background banner image from API if available, else first service image / default
                      if (bannerImage != null && bannerImage.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: bannerImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildDefaultHeader(),
                          errorWidget: (context, url, error) => _buildDefaultHeader(),
                        )
                      else if (services.isNotEmpty && services[0]['image'] != null)
                        (services[0]['image'].toString().startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: services[0]['image'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildDefaultHeader(),
                              errorWidget: (context, url, error) => _buildDefaultHeader(),
                            )
                          : Image.asset(
                              'assets/images/plaza/img17.jpg', // Default background asset
                              fit: BoxFit.cover,
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
                                  localizations.services,
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
                                      : localizations.exceptionalServicesForYourComfort,
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
              
              // Services List/Grid
              SliverPadding(
                padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 20)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2, // 2 columns on mobile, 4 on tablet
                    mainAxisSpacing: ResponsiveUtils.scaleHeight(context, 16),
                    crossAxisSpacing: ResponsiveUtils.scaleWidth(context, 16),
                    childAspectRatio: 1.0, // Square cards
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final service = services[index];
                      return _buildServiceCard(service, index);
                    },
                    childCount: services.length,
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

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.scaleWidth(context, 8)),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ResponsiveUtils.scaleWidth(context, 8)),
          onTap: () => _showServiceDetails(service),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                (service['image'] != null && service['image'].toString().startsWith('http'))
                    ? Flexible(
                        child: Container(
                          width: ResponsiveUtils.scaleWidth(context, 40),
                          height: ResponsiveUtils.scaleWidth(context, 40),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(service['image']),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : Icon(
                        service['icon'],
                        color: service['color'] ?? AppColors.primary,
                        size: ResponsiveUtils.scaleWidth(context, 32),
                      ),
                
                SizedBox(height: ResponsiveUtils.scaleHeight(context, 12)),
                
                // Title
                Text(
                  service['title'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.scaleFontSize(context, 14),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: (100 * index).ms).slideY(
      begin: 0.2,
      end: 0,
      duration: 300.ms,
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
          Icons.room_service,
          color: Colors.white.withOpacity(0.5),
          size: ResponsiveUtils.scaleWidth(context, 80),
        ),
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => ServiceDetailDialog(service: service),
    );
  }
}

// Custom painter for decorative pattern
class ServicePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i + (size.width / 16);
      final y = size.height * 0.3;
      final radius = 20.0;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    for (int i = 0; i < 6; i++) {
      final x = (size.width / 6) * i + (size.width / 12);
      final y = size.height * 0.7;
      final radius = 15.0;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Service Detail Dialog
class ServiceDetailDialog extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailDialog({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.scaleWidth(context, 20)),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: ResponsiveUtils.scaleHeight(context, 600)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: ResponsiveUtils.scaleHeight(context, 200),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    service['color'],
                    service['color'].withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveUtils.scaleWidth(context, 20)),
                  topRight: Radius.circular(ResponsiveUtils.scaleWidth(context, 20)),
                ),
                image: (service['image'] != null && service['image'].toString().startsWith('http'))
                  ? DecorationImage(
                      image: NetworkImage(service['image']),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: Stack(
                children: [
                  if (service['image'] != null && service['image'].toString().startsWith('http'))
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Close Button
                  Positioned(
                    top: ResponsiveUtils.scaleHeight(context, 12),
                    right: ResponsiveUtils.scaleWidth(context, 12),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 4)),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: ResponsiveUtils.scaleWidth(context, 20),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 24)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (service['image'] == null || !service['image'].toString().startsWith('http'))
                          Icon(
                            service['icon'],
                            color: Colors.white,
                            size: ResponsiveUtils.scaleWidth(context, 48),
                          ),
                        SizedBox(height: ResponsiveUtils.scaleHeight(context, 16)),
                        Text(
                          service['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.scaleFontSize(context, 24),
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(0, 2)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: ResponsiveUtils.scaleHeight(context, 8)),
                        Text(
                          service['hours'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.scaleFontSize(context, 14),
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 24)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: ResponsiveUtils.scaleFontSize(context, 18),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.scaleHeight(context, 8)),
                      Text(
                        service['description'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          fontSize: ResponsiveUtils.scaleFontSize(context, 14),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.scaleHeight(context, 20)),
                      
                      Text(
                        localizations.featuresAndBenefits,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: ResponsiveUtils.scaleFontSize(context, 18),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.scaleHeight(context, 12)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (service['features'] as List<String>).length,
                        itemBuilder: (context, index) {
                          final feature = service['features'][index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: ResponsiveUtils.scaleHeight(context, 8)),
                            child: Row(
                              children: [
                                Container(
                                  width: ResponsiveUtils.scaleWidth(context, 8),
                                  height: ResponsiveUtils.scaleWidth(context, 8),
                                  decoration: BoxDecoration(
                                    color: service['color'],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: ResponsiveUtils.scaleWidth(context, 12)),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: ResponsiveUtils.scaleFontSize(context, 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Close Button
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.scaleWidth(context, 16)),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: service['color'],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.scaleHeight(context, 16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.scaleWidth(context, 12)),
                    ),
                  ),
                  child: Text(
                    localizations.close,
                    style: TextStyle(fontSize: ResponsiveUtils.scaleFontSize(context, 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
