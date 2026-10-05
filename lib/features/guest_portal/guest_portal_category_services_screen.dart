import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_custom_request_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';

class GuestPortalCategoryServicesScreen extends StatelessWidget {
  final String categoryTitle;
  final IconData categoryIcon;
  final Color categoryColor;

  const GuestPortalCategoryServicesScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.categoryColor,
  });

  List<Map<String, String>> _getServices(GuestPortalProvider provider) {
    // 1. Try to fetch from API services
    final apiServices = provider.guestServices
        .where((s) {
          final cat = (s['category'] ?? s['service_category'] ?? '').toString();
          return cat.toLowerCase() == categoryTitle.toLowerCase();
        })
        .toList();

    if (apiServices.isNotEmpty) {
      return apiServices.map((s) => {
        'title': (s['title'] ?? s['name'] ?? '').toString(),
        'desc': (s['description'] ?? s['desc'] ?? 'Select to request this service').toString(),
      }).toList();
    }

    // 2. Fallback to mock services
    switch (categoryTitle) {
      case 'Housekeeping':
        return [
          {'title': 'Extra Towels', 'desc': 'Request additional bath or hand towels.'},
          {'title': 'Room Cleaning', 'desc': 'Schedule a full room makeup.'},
          {'title': 'Refill Amenities', 'desc': 'Shampoo, soap, and other toiletries.'},
          {'title': 'Turn Down Service', 'desc': 'Evening room preparation.'},
        ];
      case 'Room Service':
        return [
          {'title': 'In-Room Breakfast', 'desc': 'Order from our morning menu.'},
          {'title': 'All-Day Dining', 'desc': 'Explore our full menu selection.'},
          {'title': 'Beverages & Wine', 'desc': 'Order drinks directly to your room.'},
          {'title': 'Collect Trays', 'desc': 'Request removal of used dining trays.'},
        ];
      case 'I.T':
        return [
          {'title': 'Wi-Fi Assistance', 'desc': 'Help connecting your devices to the internet.'},
          {'title': 'TV Troubleshooting', 'desc': 'Issues with the television or channels.'},
          {'title': 'Phone Issue', 'desc': 'In-room telephone not working.'},
        ];
      case 'Maintenance':
        return [
          {'title': 'AC Not Working', 'desc': 'Air conditioning adjustment or repair.'},
          {'title': 'Plumbing Issue', 'desc': 'Bathroom or sink related problems.'},
          {'title': 'Light Bulb Replacement', 'desc': 'Replace burnt out lights in the room.'},
        ];
      case 'Laundry':
        return [
          {'title': 'Standard Laundry', 'desc': 'Wash and fold service.'},
          {'title': 'Dry Cleaning', 'desc': 'Professional dry cleaning for delicate items.'},
          {'title': 'Pressing Only', 'desc': 'Ironing and pressing services.'},
          {'title': 'Shoe Shine', 'desc': 'Professional shoe polishing.'},
        ];
      case 'Reception':
        return [
          {'title': 'Late Checkout', 'desc': 'Request to extend your departure time.'},
          {'title': 'Wake-up Call', 'desc': 'Schedule a morning wake-up call.'},
          {'title': 'Transportation', 'desc': 'Book a taxi or airport shuttle.'},
        ];
      case 'Concierge':
        return [
          {'title': 'Luggage Pickup', 'desc': 'Assistance with your baggage.'},
          {'title': 'Tour Booking', 'desc': 'Explore local attractions and tours.'},
          {'title': 'Restaurant Reservations', 'desc': 'Book a table at local dining spots.'},
        ];
      default:
        return [
          {'title': 'General Inquiry', 'desc': 'Ask a question or request general assistance.'},
          {'title': 'Lost & Found', 'desc': 'Inquire about a misplaced item.'},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    
    return Consumer<GuestPortalProvider>(
      builder: (context, provider, child) {
        final services = _getServices(provider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryTitle.tr(context),
          style: GoogleFonts.roboto(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20.0 : ResponsiveUtils.getScreenWidth(context) * 0.15,
          vertical: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: categoryColor.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      categoryIcon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Services'.tr(context),
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a service below to create your request.'.tr(context),
                          style: GoogleFonts.roboto(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
            
            const SizedBox(height: 32),
            
            // Services Grid/List
            isSmallScreen
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildServiceCard(context, theme, services[index], index).animate().fade(delay: Duration(milliseconds: 100 + (index * 100))).slideY(begin: 0.1);
                    },
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(context, theme, services[index], index).animate().fade(delay: Duration(milliseconds: 100 + (index * 100))).slideY(begin: 0.1);
                    },
                  ),
            
            const SizedBox(height: 32),
            
            // Custom Request Section
            _buildCustomRequestCard(context, theme).animate().fade(delay: 500.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 32),
          ],
        ),
    ));
    });
  }

  Widget _buildCustomRequestCard(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestPortalCustomRequestScreen(
              categoryTitle: categoryTitle,
              categoryColor: categoryColor,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_note, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need something else?'.tr(context),
                    style: GoogleFonts.roboto(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Write a custom request for this category.'.tr(context),
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ThemeData theme, Map<String, String> service, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service['title']!.tr(context),
                  style: GoogleFonts.roboto(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  service['desc']!.tr(context),
                  style: GoogleFonts.roboto(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuestPortalCustomRequestScreen(
                    categoryTitle: categoryTitle,
                    categoryColor: categoryColor,
                    initialDescription: '${'Requesting:'.tr(context)} ${service['title']}',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'Request'.tr(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
