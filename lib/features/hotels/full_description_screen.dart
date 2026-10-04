import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/models/hotel_model.dart';

class FullDescriptionScreen extends StatelessWidget {
  final HotelModel hotel;

  const FullDescriptionScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Hotel Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: Text(
                'About Hotel',
                style: GoogleFonts.greatVibes(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHotelImage(
                    hotel.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Dark Overlay for readability & Logo contrast
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
                    height: 120, // Slightly smaller melting for smaller header height
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.6),
                            Colors.white,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enlarged Hotel Logo without background circle
                        _buildHotelImage(
                          hotel.logoUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hotel.name,
                          style: GoogleFonts.greatVibes(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brief Section
                  _buildInfoCard(
                    context,
                    icon: Icons.info_outline,
                    title: 'Brief',
                    content: hotel.brief,
                    color: AppColors.primary,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Full Description Section
                  _buildInfoCard(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Full Description',
                    content: hotel.description,
                    color: AppColors.secondary,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Location Section
                  _buildLocationCard(context),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Info Section
                  _buildQuickInfoSection(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.greatVibes(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.8,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Location',
                  style: GoogleFonts.greatVibes(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.place, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hotel.address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'View on Map',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Info',
                  style: GoogleFonts.greatVibes(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuickInfoItem(context, Icons.star, '5-Star', 'Luxury Hotel'),
                const SizedBox(width: 16),
                _buildQuickInfoItem(context, Icons.wifi, 'Free WiFi', 'Available'),
                const SizedBox(width: 16),
                _buildQuickInfoItem(context, Icons.local_parking, 'Parking', 'Available'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuickInfoItem(context, Icons.pool, 'Pool', 'Available'),
                const SizedBox(width: 16),
                _buildQuickInfoItem(context, Icons.fitness_center, 'Gym', '24/7'),
                const SizedBox(width: 16),
                _buildQuickInfoItem(context, Icons.spa, 'Spa', 'Available'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage(String path, {BoxFit fit = BoxFit.cover, double? height, double? width}) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
      );
    } else {
      return Image.asset(
        path,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
      );
    }
  }
}
