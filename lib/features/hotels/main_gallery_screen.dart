import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'full_screen_image_viewer.dart';

class MainGalleryScreen extends StatefulWidget {
  final HotelModel hotel;
  final int? initialTabIndex; // Add optional initial tab index
  
  const MainGalleryScreen({super.key, required this.hotel, this.initialTabIndex});

  @override
  State<MainGalleryScreen> createState() => _MainGalleryScreenState();
}

class _MainGalleryScreenState extends State<MainGalleryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _getServices(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // 1. Initialize categories with empty image lists
    final List<Map<String, dynamic>> services = [
      {
        'name': localizations.galleryAll,
        'icon': Icons.photo_library,
        'images': <String>[],
      },
      {
        'name': localizations.galleryHotelView,
        'icon': Icons.hotel,
        'images': <String>[],
      },
      {
        'name': localizations.galleryFeatures,
        'icon': Icons.star,
        'images': <String>[],
      },
      {
        'name': localizations.galleryGuestRooms,
        'icon': Icons.bed,
        'images': <String>[],
      },
      {
        'name': localizations.gallerySuites,
        'icon': Icons.king_bed,
        'images': <String>[],
      },
      {
        'name': localizations.gallerySports,
        'icon': Icons.sports_soccer,
        'images': <String>[],
      },
      {
        'name': localizations.gallerySpa,
        'icon': Icons.spa,
        'images': <String>[],
      },
      {
        'name': localizations.galleryWeddings,
        'icon': Icons.favorite,
        'images': <String>[],
      },
      {
        'name': localizations.galleryDining,
        'icon': Icons.restaurant,
        'images': <String>[],
      },
      {
        'name': localizations.galleryEvents,
        'icon': Icons.event,
        'images': <String>[],
      },
    ];

    // 2. Add server gallery images and filter
    final List<String> serverImages = [];

    // Add Gallery Items sorted by category choice from dashboard
    if (widget.hotel.galleryItems != null) {
      for (var item in widget.hotel.galleryItems!) {
        if (item.image != null && 
            item.image!.isNotEmpty && 
            !item.image!.contains('offer_images/offer_images') && 
            !item.image!.contains('offer_cards/offer_cards') &&
            !item.image!.contains('truimph')) {
          
          final imgUrl = item.image!;
          serverImages.add(imgUrl);
          
          // Map to appropriate categories matching dashboard Choices
          if (item.category != null) {
            switch (item.category) {
              case 'hotel_view':
                services[1]['images'].add(imgUrl);
                break;
              case 'features':
                services[2]['images'].add(imgUrl);
                break;
              case 'rooms':
              case 'guest_rooms':
                services[3]['images'].add(imgUrl);
                break;
              case 'suites':
                services[4]['images'].add(imgUrl);
                break;
              case 'sports':
                services[5]['images'].add(imgUrl);
                break;
              case 'spa':
                services[6]['images'].add(imgUrl);
                break;
              case 'weddings':
                services[7]['images'].add(imgUrl);
                break;
              case 'dining':
                services[8]['images'].add(imgUrl);
                break;
              case 'events':
                services[9]['images'].add(imgUrl);
                break;
            }
          }
        }
      }
    }

    // Set "All" tab (index 0)
    services[0]['images'] = serverImages;
    
    // Clean and remove duplicates for all categories
    for (int i = 0; i < services.length; i++) {
      services[i]['images'] = (services[i]['images'] as List<String>).toSet().toList();
    }
    
    return services;
  }

  @override
  void initState() {
    super.initState();
    // Initialize with a temporary length, will be finalized in build with context
    _tabController = TabController(length: 10, vsync: this);
    
    // Initial tab index will be handled after the first frame or in build
    if (widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.initialTabIndex! < _tabController.length) {
          _tabController.animateTo(widget.initialTabIndex!);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final services = _getServices(context);
    
    // Update tab controller length if needed
    if (_tabController.length != services.length) {
      _tabController.dispose();
      _tabController = TabController(length: services.length, vsync: this);
      
      // Set initial tab index if provided
      if (widget.initialTabIndex != null && widget.initialTabIndex! < services.length) {
        _tabController.animateTo(
          widget.initialTabIndex!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations.gallery,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              padding: const EdgeInsets.symmetric(vertical: 8),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              tabs: services.map((service) {
                return Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          service['icon'] as IconData, 
                          size: 16,
                          color: _tabController.index == services.indexOf(service) 
                              ? Colors.white 
                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(service['name'] as String),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: services.map((service) {
                return _buildServiceGallery(service);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGallery(Map<String, dynamic> service) {
    final images = service['images'] as List<String>;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Get all images and titles for the current service
              final allImages = service['images'] as List<String>;
              final allTitles = List.generate(
                allImages.length,
                (i) => '${service['name']} ${i + 1}',
              );
              
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FullScreenImageViewer(
                    imagePath: allImages[index],
                    title: '${service['name']} ${index + 1}',
                    currentIndex: index,
                    allImages: allImages,
                    allTitles: allTitles,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (images[index].startsWith('http'))
                        ? Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: theme.colorScheme.surface,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.imageNotAvailable,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: theme.colorScheme.surface,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.imageNotAvailable,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ).animate().scale(delay: (index * 100).ms, duration: 300.ms),
          );
        },
      ),
    );
  }
}
