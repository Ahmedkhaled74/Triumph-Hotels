import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/models/hotel_model.dart';

class GalleryScreen extends StatelessWidget {
  final HotelModel hotel;

  const GalleryScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          '${hotel.getLocalizedName(context)} ${localizations.gallery}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: hotel.gallery.length,
        itemBuilder: (context, index) {
          final imageUrl = hotel.gallery[index];
          return GestureDetector(
            onTap: () {
              _showFullScreenImage(context, imageUrl);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: Container(
            color: theme.colorScheme.surface,
            child: Center(
              child: InteractiveViewer(
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations.imageNotAvailable,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
