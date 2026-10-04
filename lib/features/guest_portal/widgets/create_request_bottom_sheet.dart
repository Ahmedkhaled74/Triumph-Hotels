import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_category_services_screen.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/utils/guest_service_parser.dart';
import 'package:triumph_hotels/features/guest_portal/widgets/transport_options_bottom_sheet.dart';

class CreateRequestBottomSheet extends StatelessWidget {
  const CreateRequestBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateRequestBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final provider = context.watch<GuestPortalProvider>();

    // Extract unique categories dynamically, grabbing the backend's color and icon
    final uniqueCategories = <String, Map<String, dynamic>>{};
    
    for (final service in provider.guestServices) {
      // First try to check if the backend sent a pre-translated field
      String category = service['category_localized']?.toString() ?? 
                        service['category_ar']?.toString() ??
                        service['category_translated']?.toString() ??
                        service['category']?.toString() ?? '';
      
      if (category.isEmpty) continue;
      
      final iconStr = service['icon']?.toString();
      final colorStr = service['color']?.toString();

      if (!uniqueCategories.containsKey(category)) {
        uniqueCategories[category] = {
          'title': category,
          'iconStr': iconStr,
          'colorStr': colorStr,
        };
      } else {
        if (uniqueCategories[category]!['iconStr'] == null && iconStr != null && iconStr.isNotEmpty) {
          uniqueCategories[category]!['iconStr'] = iconStr;
        }
        if (uniqueCategories[category]!['colorStr'] == null && colorStr != null && colorStr.isNotEmpty) {
          uniqueCategories[category]!['colorStr'] = colorStr;
        }
      }
    }

    final List<Map<String, dynamic>> categories = uniqueCategories.values.map((cat) {
      final title = cat['title'] as String;
      final icon = GuestServiceParser.parseIcon(cat['iconStr'], title);
      final color = GuestServiceParser.parseColor(cat['colorStr'], title);
      
      return {
        'title': title,
        'icon': icon,
        'color': color,
      };
    }).toList();

    // Fallback in case no services/categories were loaded
    if (categories.isEmpty) {
      categories.addAll([
        {'title': 'Housekeeping', 'icon': Icons.cleaning_services_outlined, 'color': Colors.orange},
        {'title': 'Room Service', 'icon': Icons.restaurant_outlined, 'color': Colors.redAccent},
        {'title': 'I.T', 'icon': Icons.wifi_outlined, 'color': Colors.purpleAccent},
        {'title': 'Maintenance', 'icon': Icons.build_outlined, 'color': Colors.lightBlue},
        {'title': 'Laundry', 'icon': Icons.local_laundry_service_outlined, 'color': Colors.blue},
        {'title': 'Reception', 'icon': Icons.support_agent_outlined, 'color': Colors.blueAccent},
        {'title': 'Concierge', 'icon': Icons.luggage_outlined, 'color': Colors.indigoAccent},
        {'title': 'Other', 'icon': Icons.more_horiz, 'color': Colors.blueGrey},
      ]);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          // Header with Drag Handle and Close Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24.0 : ResponsiveUtils.getScreenWidth(context) * 0.15,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'How can we help?'.tr(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: AppColors.primary,
                      fontSize: 26, // Kept slightly smaller based on previous rules
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade().slideY(begin: 0.1),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Let us know what you need, and we\'ll handle the rest.'.tr(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Select a category to get started'.tr(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 3,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(
                        context: context,
                        theme: theme,
                        title: category['title'] as String,
                        icon: category['icon'] as IconData,
                        color: category['color'] as Color,
                      ).animate().fade(delay: Duration(milliseconds: 350 + (index * 50))).slideY(begin: 0.1);
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        if (title.toLowerCase().contains('transport')) {
          Navigator.pop(context); // Close the current bottom sheet
          TransportOptionsBottomSheet.show(context, theme);
          return;
        }
        Navigator.pop(context); // Close the bottom sheet first
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestPortalCategoryServicesScreen(
              categoryTitle: title,
              categoryIcon: icon,
              categoryColor: color,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
