import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/features/guest_portal/widgets/transport_options_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GuestPortalDiscoverScreen extends StatefulWidget {
  final bool showAppBar;
  const GuestPortalDiscoverScreen({super.key, this.showAppBar = true});

  static void showPlaceDetails(BuildContext context, ThemeData theme, Map<String, dynamic> place) {
    final title = (place['title'] ?? place['name'] ?? 'Unknown Place').toString();
    final category = (place['category'] ?? '').toString();
    final distance = (place['distance'] ?? (place['distanceKm'] != null ? '${place['distanceKm']} km' : '')).toString();
    final description = (place['description'] ?? place['subtitle'] ?? '').toString();
    final rating = (place['rating']?.toString() ?? '');
    final locationLink = (place['location_link'] ?? '').toString();
    final hasReservation = place['reservation_available'] == true;
    // pick first photo from place_photos list, fall back to image field
    final photos = place['place_photos'];
    String imageUrl = '';
    if (photos is List && photos.isNotEmpty) {
      imageUrl = photos.first.toString();
    } else {
      imageUrl = (place['image'] ?? '').toString();
    }
    final bool isNetworkUrl = imageUrl.startsWith('http') || imageUrl.startsWith('/');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Top Image Area
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          child: isNetworkUrl 
                            ? (imageUrl.startsWith('/') 
                                ? Image.network('https://ticketx.triumphhotel.com$imageUrl', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)) 
                                : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)))
                            : (imageUrl.isNotEmpty ? Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)) : const Icon(Icons.broken_image)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                theme.scaffoldBackgroundColor,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close Button
                  Positioned(
                    top: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  // Rating Badge (Now Distance)
                  if (distance.isNotEmpty)
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              distance,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Details Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Category + subcategory badges
                      Wrap(
                        spacing: 8,
                        children: [
                          if (category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                category.isNotEmpty ? '${category[0].toUpperCase()}${category.substring(1)}'.tr(context) : '',
                                style: GoogleFonts.roboto(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          if (distance.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(distance, style: GoogleFonts.roboto(color: AppColors.primary, fontSize: 13)),
                                ],
                              ),
                            ),
                          if (rating.isNotEmpty && rating != '0' && rating != '0.0')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 14),
                                  const SizedBox(width: 4),
                                  Text(rating, style: GoogleFonts.roboto(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: GoogleFonts.roboto(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (locationLink.isNotEmpty)
                      _buildActionButton(context, Icons.near_me_outlined, 'Map', theme, onTap: () async {
                        final url = Uri.tryParse(locationLink);
                        if (url != null && await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open map link')),
                            );
                          }
                        }
                      }),
                    if (hasReservation) ...[
                      const SizedBox(width: 16),
                      _buildActionButton(context, Icons.calendar_today, 'Reserve', theme, onTap: () => _showReservationSheet(context, theme, place)),
                    ],
                    const SizedBox(width: 16),
                    _buildActionButton(context, Icons.directions_car_outlined, 'Ride', theme, onTap: () => TransportOptionsBottomSheet.show(context, theme, place: place)),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionButton(BuildContext context, IconData icon, String label, ThemeData theme, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.goldLight.withOpacity(0.6)),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.goldLight, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.roboto(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showReservationSheet(BuildContext context, ThemeData theme, Map<String, dynamic> place) {
    final title = (place['title'] ?? place['name'] ?? 'Unknown Place').toString().replaceAll('\n', ' ');
    int partySize = 2;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 19, minute: 0);
    final phoneController = TextEditingController();
    final requestsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Reserve a Spot'.tr(context),
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Party Size + Date Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Party Size'.tr(context), style: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$partySize', style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () => setSheetState(() => partySize++),
                                            child: Icon(Icons.keyboard_arrow_up, size: 20, color: AppColors.primary),
                                          ),
                                          GestureDetector(
                                            onTap: () => setSheetState(() { if (partySize > 1) partySize--; }),
                                            child: Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date'.tr(context), style: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: ctx,
                                      initialDate: selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                      builder: (c, child) => Theme(
                                        data: theme.copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: theme.brightness)),
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) setSheetState(() => selectedDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${selectedDate.month.toString().padLeft(2, '0')} / ${selectedDate.day.toString().padLeft(2, '0')} / ${selectedDate.year}',
                                          style: GoogleFonts.roboto(fontSize: 12, color: theme.textTheme.bodyLarge?.color),
                                        ),
                                        Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Preferred Time
                      Text('Preferred Time'.tr(context), style: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                            builder: (c, child) => Theme(
                              data: theme.copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: theme.brightness)),
                              child: child!,
                            ),
                          );
                          if (picked != null) setSheetState(() => selectedTime = picked);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            selectedTime.format(ctx),
                            style: GoogleFonts.roboto(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Contact Phone
                      Text('Contact Phone'.tr(context), style: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.roboto(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Your phone number'.tr(context),
                          hintStyle: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Special Requests
                      Text('Special Requests'.tr(context), style: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: requestsController,
                        maxLines: 3,
                        style: GoogleFonts.roboto(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Any special requests or dietary requirements...'.tr(context),
                          hintStyle: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final placeId = place['id']?.toString() ?? '';
                            if (placeId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid place ID.')));
                              return;
                            }
                            final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                            final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                            try {
                              showDialog(
                                context: ctx,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator()),
                              );
                              await context.read<GuestPortalProvider>().reserveLocalRecommendation(
                                placeId: placeId,
                                date: dateStr,
                                time: timeStr,
                                partySize: partySize,
                                contactPhone: phoneController.text,
                                specialRequests: requestsController.text,
                              );
                              if (context.mounted) {
                                Navigator.pop(ctx); // pop loading
                                Navigator.pop(ctx); // pop sheet
                                Navigator.pop(context); // pop modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reservation confirmed for $title!'),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(ctx); // pop loading
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to make reservation. Please try again.'.tr(context)),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text('Confirm Reservation'.tr(context), style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
);
      },
    );
  }

  @override
  State<GuestPortalDiscoverScreen> createState() => _GuestPortalDiscoverScreenState();
}

class _GuestPortalDiscoverScreenState extends State<GuestPortalDiscoverScreen> {
  String _selectedMainCategory = 'All';
  String _selectedSubCategory = 'All';
  String _searchQuery = '';

  List<String> _mainCategories = ['All'];
  // Maps display name -> original English name for API calls
  final Map<String, String> _categoryOriginalNames = {};
  final Map<String, String> _subCategoryOriginalNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestPortalProvider>().fetchLocalRecommendations(silent: true);
    });
  }

  List<Map<String, dynamic>> _buildFilteredPlaces(List<dynamic> recs, List<dynamic> apiCategories) {
    if (apiCategories.isNotEmpty) {
      final cats = apiCategories.map((c) {
        String displayName = '';
        String originalName = '';
        if (c is String) {
          displayName = c;
          originalName = c;
        } else if (c is Map) {
          displayName = (c['name'] ?? c['title'] ?? c['category'] ?? c['label'] ?? c['name_ar'] ?? c['name_en'] ?? '').toString();
          originalName = (c['original_name'] ?? c['original_title'] ?? c['category_en'] ?? c['name_en'] ?? displayName).toString();
          if (displayName.isEmpty) {
            for (final v in c.values) {
              if (v is String && v.isNotEmpty && !RegExp(r'^[0-9a-fA-F\-]+$').hasMatch(v)) {
                displayName = v;
                originalName = v;
                break;
              }
            }
          }
        }
        _categoryOriginalNames[displayName] = originalName;
        return displayName;
      }).where((c) => c.isNotEmpty).toList();
      _mainCategories = ['All', ...cats];
    } else {
      // Fallback: extract from place data
      final cats = recs.map((r) => r['category']?.toString() ?? 'Other').toSet().toList();
      for (final c in cats) { _categoryOriginalNames[c] = c; }
      _mainCategories = ['All', ...cats];
    }

    return recs.where((place) {
      final cat = place['category']?.toString() ?? '';
      final subCat = place['subcategory']?.toString() ?? '';
      final name = (place['title'] ?? place['name'] ?? '').toString();
      final desc = (place['description'] ?? '').toString();
      // Always compare against original English category name from the data
      final originalSelected = _categoryOriginalNames[_selectedMainCategory] ?? _selectedMainCategory;
      final originalSubSelected = _subCategoryOriginalNames[_selectedSubCategory] ?? _selectedSubCategory;
      
      final matchesMain = _selectedMainCategory == 'All' || cat.toLowerCase() == originalSelected.toLowerCase();
      final matchesSub = _selectedSubCategory == 'All' || subCat.toLowerCase() == originalSubSelected.toLowerCase();
      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            desc.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesMain && matchesSub && matchesSearch;
    }).map((r) => r as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final horizontalPadding = isSmallScreen ? 16.0 : ResponsiveUtils.getScreenWidth(context) * 0.12;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: AppColors.primary,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Discover',
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: theme.dividerColor.withOpacity(0.5), height: 1.0),
              ),
            )
          : null,
      body: Consumer<GuestPortalProvider>(
        builder: (context, provider, child) {
          final filteredPlaces = _buildFilteredPlaces(provider.localRecommendations, provider.placeCategories);

          return Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Categories (derived from API)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        itemCount: _mainCategories.length,
                        itemBuilder: (context, index) {
                          final category = _mainCategories[index];
                          final isSelected = _selectedMainCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(category.isNotEmpty ? '${category[0].toUpperCase()}${category.substring(1)}'.tr(context) : ''),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedMainCategory = category;
                                    _selectedSubCategory = 'All';
                                  });
                                  if (category != 'All') {
                                    // Always send original English name to API
                                    final originalName = _categoryOriginalNames[category] ?? category;
                                    context.read<GuestPortalProvider>().fetchPlaceSubCategories(originalName);
                                  }
                                }
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : theme.dividerColor,
                                ),
                              ),
                              labelStyle: GoogleFonts.roboto(
                                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedMainCategory != 'All') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: Builder(
                          builder: (context) {
                            final originalMain = _categoryOriginalNames[_selectedMainCategory] ?? _selectedMainCategory;
                            final rawSubCats = provider.placeSubCategories[originalMain] ?? [];
                            final subCats = ['All', ...rawSubCats.map((c) {
                              if (c is String) {
                                _subCategoryOriginalNames[c] = c;
                                return c;
                              }
                              if (c is Map) {
                                final name = (c['name'] ?? c['title'] ?? c['subcategory'] ?? c['label'] ?? c['name_ar'] ?? c['name_en'] ?? '').toString();
                                final origName = (c['original_name'] ?? c['original_title'] ?? c['name_en'] ?? c['category_en'] ?? name).toString();
                                if (name.isNotEmpty) {
                                  _subCategoryOriginalNames[name] = origName;
                                  return name;
                                }
                                for (final v in c.values) {
                                  if (v is String && v.isNotEmpty && !RegExp(r'^[0-9a-fA-F\-]+$').hasMatch(v)) {
                                    _subCategoryOriginalNames[v] = v;
                                    return v;
                                  }
                                }
                              }
                              return '';
                            }).where((c) => c.isNotEmpty)];

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              itemCount: subCats.length,
                              itemBuilder: (context, index) {
                                final subCategory = subCats[index];
                                final isSelected = _selectedSubCategory == subCategory;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(subCategory.isNotEmpty ? '${subCategory[0].toUpperCase()}${subCategory.substring(1)}'.tr(context) : '', style: const TextStyle(fontSize: 13)),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedSubCategory = subCategory;
                                        });
                                      }
                                    },
                                    selectedColor: AppColors.primary.withOpacity(0.15),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : theme.dividerColor.withOpacity(0.5),
                                      ),
                                    ),
                                    labelStyle: GoogleFonts.roboto(
                                      color: isSelected ? AppColors.primary : theme.textTheme.bodyMedium?.color,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search places...'.tr(context),
                          hintStyle: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.search, color: AppColors.primary),
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results List
              Expanded(
                child: filteredPlaces.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: theme.dividerColor),
                            const SizedBox(height: 16),
                            Text(
                              'No places found'.tr(context),
                              style: GoogleFonts.roboto(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                        itemCount: filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = filteredPlaces[index];
                          return _buildPlaceCard(theme, place, index);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(ThemeData theme, Map<String, dynamic> place, int index) {
    final title = (place['title'] ?? place['name'] ?? 'Unknown Place').toString();
    final subtitle = (place['description'] ?? '').toString();
    final category = (place['category'] ?? '').toString();
    final distance = (place['distance'] ?? (place['distanceKm'] != null ? '${place['distanceKm']} km' : '')).toString();
    final rating = (place['rating']?.toString() ?? '');
    // pick first photo from place_photos list, fall back to image field
    final photos = place['place_photos'];
    String imageUrl = '';
    if (photos is List && photos.isNotEmpty) {
      imageUrl = photos.first.toString();
    } else {
      imageUrl = (place['image'] ?? '').toString();
    }
    final bool isNetworkUrl = imageUrl.startsWith('http') || imageUrl.startsWith('/');

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            isNetworkUrl
              ? (imageUrl.startsWith('/')
                  ? Image.network('https://ticketx.triumphhotel.com$imageUrl', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.location_on, size: 64, color: Colors.white30)))
                  : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.location_on, size: 64, color: Colors.white30))))
              : Container(color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.location_on, size: 64, color: Colors.white30)),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.roboto(
                            color: AppColors.goldLight,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (distance.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                          ),
                          child: Text(
                            distance,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (rating.isNotEmpty && rating != '0' && rating != '0.0') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                rating,
                                style: GoogleFonts.roboto(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (category.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      category,
                      style: GoogleFonts.roboto(
                        color: AppColors.primary.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => GuestPortalDiscoverScreen.showPlaceDetails(context, theme, place),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.goldLight),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Discover',
                            style: GoogleFonts.roboto(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: AppColors.goldLight, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: Duration(milliseconds: 100 + (index * 100))).slideY(begin: 0.1);
  }

}
