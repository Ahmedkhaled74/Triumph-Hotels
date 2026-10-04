import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/models/service_model.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/theme_provider.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';

class AllServicesScreen extends StatelessWidget {
  final List<String> services;

  const AllServicesScreen({super.key, required this.services});

  List<ServiceModel> _getFilteredServices() {
    List<ServiceModel> allServices = getAllServices();
    return allServices.where((service) => 
      services.any((hotelService) => 
        service.name.toLowerCase().contains(hotelService.toLowerCase()) ||
        hotelService.toLowerCase().contains(service.name.toLowerCase())
      )
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<ServiceModel> filteredServices = _getFilteredServices();
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Services',
          style: GoogleFonts.greatVibes(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24)),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.getResponsiveColumns(context),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 130, // Consistent height for service cards
          ),
          itemCount: filteredServices.length,
          itemBuilder: (context, index) => _buildServiceCard(context, filteredServices[index], themeProvider.isDarkMode),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service, bool isDarkMode) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                service.icon,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
