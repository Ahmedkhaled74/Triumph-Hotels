import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_transport_detail_screen.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';

class TransportOptionsBottomSheet {
  static void show(BuildContext context, ThemeData theme, {Map<String, dynamic>? place}) {
    // If no place is provided, we use an empty title so the next screen knows to ask for it.
    final safePlace = place ?? {'title': '', 'distance': '0.0'};
    final displayTitle = safePlace['title']?.toString().isNotEmpty == true ? safePlace['title'].toString() : (safePlace['name']?.toString() ?? '');
    final toText = displayTitle.isEmpty ? 'Custom Destination'.tr(context, listen: false) : displayTitle.replaceAll('\n', ' ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final provider = ctx.read<GuestPortalProvider>();
        return FutureBuilder<List<dynamic>>(
          future: Future.microtask(() => provider.fetchTransportCars(silent: true))
              .then((_) => provider.transportCars),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final transports = snapshot.data ?? [];
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Available Transports'.tr(context),
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${'To'.tr(context)}: $toText',
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (transports.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No transportation options available at the moment.'.tr(context),
                          style: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color),
                        ),
                      ),
                    )
                  else
                    ...transports.asMap().entries.map((entry) =>
                        _buildTransportOption(ctx, theme, entry.value, safePlace, index: entry.key)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildTransportOption(
    BuildContext context,
    ThemeData theme,
    dynamic transport,
    Map<String, dynamic> place, {
    int index = 0,
  }) {
    final name = transport['name']?.toString() ?? 'Hotel Car'.tr(context);
    final nameLower = name.toLowerCase();

    // Max passengers:
    // First (index 0) and third choice (index 2, Toyota Corolla) up to 4
    // Second choice (index 1, Toyota Bus) up to 14
    int capacity;
    if (index == 0 || index == 2 || nameLower.contains('corolla') || nameLower.contains('sedan')) {
      capacity = 4;
    } else if (index == 1 || nameLower.contains('bus')) {
      capacity = 14;
    } else {
      capacity = int.tryParse(transport['capacity']?.toString() ?? '') ?? 4;
    }
    
    // Set some visuals based on capacity
    final isVan = capacity > 4;
    final icon = isVan ? Icons.airport_shuttle : Icons.directions_car;
    final isHighlighted = index == 0; // Highlight the default sedan
    
    final desc = transport['description']?.toString();
    final rawDescription = (desc != null && desc.isNotEmpty)
        ? desc.replaceAll(RegExp(r'up to \d+\s*(pax|passengers)', caseSensitive: false), 'up to {n} pax'.trWith(context, {'n': capacity}))
        : (isVan
            ? 'Spacious vehicle, up to {n} pax'.trWith(context, {'n': capacity})
            : 'Premium car, up to {n} pax'.trWith(context, {'n': capacity}));

    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        
        final standardizedTransport = {
          'id': transport['id'],
          'name': name,
          'image': transport['image'],
          'icon': icon,
          'description': rawDescription,
          'capacity': capacity,
          'isHighlighted': isHighlighted,
          'index': index,
        };
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GuestPortalTransportDetailScreen(
              transport: standardizedTransport,
              destination: place,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted ? AppColors.primary.withOpacity(0.5) : theme.dividerColor.withOpacity(0.2),
            width: isHighlighted ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHighlighted ? AppColors.primary.withOpacity(0.15) : theme.dividerColor.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: isHighlighted ? AppColors.primary : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.roboto(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isHighlighted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Recommended'.tr(context),
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rawDescription,
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
