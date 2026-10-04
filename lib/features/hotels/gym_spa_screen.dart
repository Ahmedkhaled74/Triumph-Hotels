import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/hotel_model.dart';

class GymSpaScreen extends StatefulWidget {
  final HotelModel hotel;
  
  const GymSpaScreen({super.key, required this.hotel});

  @override
  State<GymSpaScreen> createState() => _GymSpaScreenState();
}

class _GymSpaScreenState extends State<GymSpaScreen> {
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

  // Get gym and spa data based on hotel
  List<Map<String, dynamic>> _getGymSpaData() {
    switch (widget.hotel.id) {
      case '1': // Triumph Plaza - Heliopolis
        return [
          {
            'id': 'gym',
            'title': 'Fitness Center',
            'description': 'State-of-the-art fitness center with modern equipment and personal training services',
            'imageUrl': 'gym.jpg',
            'features': [
              'Cardio Equipment',
              'Weight Training',
              'Personal Training',
              'Group Classes',
              '24/7 Access',
              'Locker Rooms'
            ],
            'hours': '6:00 AM - 10:00 PM',
            'capacity': '50 people',
            'size': '300 m²',
            'icon': Icons.fitness_center,
            'color': AppColors.primary,
          },
          {
            'id': 'spa',
            'title': 'Wellness Spa',
            'description': 'Luxurious spa offering rejuvenating treatments and relaxation therapies',
            'imageUrl': 'spa.jpg',
            'features': [
              'Massage Therapy',
              'Sauna & Steam',
              'Beauty Treatments',
              'Aromatherapy',
              'Private Treatment Rooms',
              'Relaxation Lounge'
            ],
            'hours': '9:00 AM - 8:00 PM',
            'capacity': '30 people',
            'size': '200 m²',
            'icon': Icons.spa,
            'color': AppColors.primary,
          }
        ];
      case '2': // Triumph Luxury - New Capital
        return [
          {
            'id': 'gym',
            'title': 'Premium Fitness Center',
            'description': 'Luxury fitness facility with cutting-edge equipment and expert trainers',
            'imageUrl': 'fitness center.jpg',
            'features': [
              'Advanced Equipment',
              'Personal Training',
              'Yoga Studio',
              'Pilates Classes',
              'Nutrition Counseling',
              'VIP Locker Rooms'
            ],
            'hours': '5:00 AM - 11:00 PM',
            'capacity': '60 people',
            'size': '400 m²',
            'icon': Icons.fitness_center,
            'color': AppColors.primary,
          },
          {
            'id': 'spa',
            'title': 'Luxury Wellness Spa',
            'description': 'Exclusive spa experience with premium treatments and personalized service',
            'imageUrl': 'wellness spa.jpg',
            'features': [
              'VIP Treatment Rooms',
              'Hydrotherapy Pool',
              'Aromatherapy',
              'Hot Stone Massage',
              'Beauty Salon',
              'Meditation Garden'
            ],
            'hours': '8:00 AM - 9:00 PM',
            'capacity': '40 people',
            'size': '350 m²',
            'icon': Icons.spa,
            'color': AppColors.primary,
          }
        ];
      case '3': // Triumph White Sands - North Coast
        return [
          {
            'id': 'gym',
            'title': 'Beach Fitness Center',
            'description': 'Open-air fitness facility with ocean views and beach equipment',
            'imageUrl': 'water sports.jpg',
            'features': [
              'Beach Equipment',
              'Outdoor Training',
              'Water Sports',
              'Yoga Deck',
              'Sunrise Classes',
              'Beach Access'
            ],
            'hours': '6:00 AM - 7:00 PM',
            'capacity': '40 people',
            'size': '250 m²',
            'icon': Icons.fitness_center,
            'color': AppColors.primary,
          },
          {
            'id': 'spa',
            'title': 'Beach Spa',
            'description': 'Coastal spa experience with ocean-inspired treatments and sea views',
            'imageUrl': 'beach spa.jpg',
            'features': [
              'Sea Therapy',
              'Beach Massage',
              'Ocean Views',
              'Outdoor Treatment Areas',
              'Natural Products',
              'Beach Relaxation'
            ],
            'hours': '10:00 AM - 6:00 PM',
            'capacity': '25 people',
            'size': '180 m²',
            'icon': Icons.spa,
            'color': AppColors.primary,
          }
        ];
      default:
        return [
          {
            'id': 'gym',
            'title': 'Fitness Center',
            'description': 'Modern fitness facility with comprehensive equipment',
            'imageUrl': 'gym.jpg',
            'features': [
              'Cardio Equipment',
              'Weight Training',
              'Personal Training',
              'Group Classes'
            ],
            'hours': '6:00 AM - 10:00 PM',
            'capacity': '50 people',
            'size': '300 m²',
            'icon': Icons.fitness_center,
            'color': AppColors.primary,
          },
          {
            'id': 'spa',
            'title': 'Wellness Spa',
            'description': 'Relaxing spa with rejuvenating treatments',
            'imageUrl': 'spa.jpg',
            'features': [
              'Massage Therapy',
              'Sauna & Steam',
              'Beauty Treatments'
            ],
            'hours': '9:00 AM - 8:00 PM',
            'capacity': '30 people',
            'size': '200 m²',
            'icon': Icons.spa,
            'color': AppColors.primary,
          }
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final gymSpaData = _getGymSpaData();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 250,
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
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  localizations.gymAndSpa,
                  style: TextStyle(
                    color: _showTitle 
                        ? (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gym & Spa images for header
                  Builder(
                    builder: (context) {
                      List<String> gymSpaImages = gymSpaData.map((item) => 'assets/images/plaza/${item['imageUrl']}').toList();
                      
                      return PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemCount: gymSpaImages.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            gymSpaImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.grey[400]!, Colors.grey[600]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  ),
                  
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
                    height: 180,
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
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.gymAndSpa,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.rejuvenateYourBodyAndMind,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
          
          // Gym & Spa Cards
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final facility = gymSpaData[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFacilityCard(facility),
                  );
                },
                childCount: gymSpaData.length,
              ),
            ),
          ),
          
          // Bottom Space
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: facility['color'].withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Facility Image (Full Width)
            SizedBox(
              height: 200, // Fixed height for image
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/plaza/${facility['imageUrl']}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[400]!, Colors.grey[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  // Melting Gradient from Image to Card
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
                  // Icon Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: facility['color'],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        facility['icon'],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Facility Details (Below Image)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility['title'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    facility['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Hours and Capacity Row
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: facility['color'],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                facility['hours'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 18,
                              color: facility['color'],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                facility['capacity'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Size and Additional Info Row
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.square_foot,
                              size: 18,
                              color: facility['color'],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                facility['size'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Features
                  Text(
                    localizations.featuresAndAmenities,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (facility['features'] as List<String>).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: facility['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: facility['color'].withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: facility['color'],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }
}
