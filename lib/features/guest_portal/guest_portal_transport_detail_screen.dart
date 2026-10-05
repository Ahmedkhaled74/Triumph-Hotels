import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';

class GuestPortalTransportDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transport;
  final Map<String, dynamic> destination;

  const GuestPortalTransportDetailScreen({
    super.key,
    required this.transport,
    required this.destination,
  });

  @override
  State<GuestPortalTransportDetailScreen> createState() =>
      _GuestPortalTransportDetailScreenState();
}

class _GuestPortalTransportDetailScreenState
    extends State<GuestPortalTransportDetailScreen> {
  int _passengerCount = 1;
  String _selectedPickupTime = 'Now';
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }
  final List<String> _pickupTimes = [
    'Now',
    'In 15 min',
    'In 30 min',
    'In 1 hour',
    'Schedule',
  ];
  bool _confirmed = false;

  String _getIsoPickupTime(String selection) {
    final now = DateTime.now();
    switch (selection) {
      case 'Now':
        return now.toIso8601String();
      case 'In 15 min':
        return now.add(const Duration(minutes: 15)).toIso8601String();
      case 'In 30 min':
        return now.add(const Duration(minutes: 30)).toIso8601String();
      case 'In 1 hour':
        return now.add(const Duration(hours: 1)).toIso8601String();
      case 'Schedule':
        return now.add(const Duration(hours: 2)).toIso8601String();
      default:
        return selection;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final transport = widget.transport;
    final destination = widget.destination;
    final isHighlighted = transport['isHighlighted'] == true;
    final maxPax = _getMaxPassengers(transport);
    
    final List<String> pickupTimes = [
      'Now'.tr(context),
      'In 15 min'.tr(context),
      'In 30 min'.tr(context),
      'In 1 hour'.tr(context),
      'Schedule'.tr(context),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Hero Header
          SizedBox(
            height: isSmall ? 260 : 300,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background
                Container(
                  color: isHighlighted ? AppColors.primary : const Color(0xFF1A1A2E),
                ),
                
                // Image
                if (transport['image'] != null && transport['image'].toString().isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: transport['image'].toString().startsWith('http')
                        ? transport['image']
                        : 'https://ticketx.triumphhotel.com${transport['image']}',
                    fit: BoxFit.cover,
                  ),
                  
                // Dark Overlay
                Container(
                  color: Colors.black.withOpacity(isHighlighted ? 0.2 : 0.4),
                ),
                
                // Back Button Layer
                SafeArea(
                  child: Stack(
                    children: [
                  // Back Button
                  Positioned(
                    top: 12,
                    left: 16,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 20 : 40,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  _buildSectionLabel(theme, Icons.info_outline, 'Description'.tr(context)),
                  const SizedBox(height: 10),
                  Text(
                    transport['name'],
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(delay: 50.ms).slideY(begin: 0.1),
                  const SizedBox(height: 4),
                  Text(
                    (transport['description']?.toString() ?? '').replaceAll(
                      RegExp(r'up to \d+\s*(pax|passengers)', caseSensitive: false),
                      'up to {n} pax'.trWith(context, {'n': maxPax}),
                    ),
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                  
                  // Destination Card
                  _buildSectionLabel(theme, Icons.location_on_outlined, 'Destination'.tr(context)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_city, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ((destination['title']?.toString() ?? '').isEmpty && (destination['name']?.toString() ?? '').isEmpty)
                              ? TextField(
                                  controller: _destinationController,
                                  style: GoogleFonts.roboto(color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your destination'.tr(context),
                                    hintStyle: GoogleFonts.roboto(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4), fontWeight: FontWeight.normal),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      destination['title'] ?? destination['name'] ?? 'Destination'.tr(context),
                                      style: GoogleFonts.roboto(
                                        color: theme.textTheme.bodyLarge?.color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      destination['subtitle'] ?? 'Fixed rate transfer'.tr(context),
                                      style: GoogleFonts.roboto(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 150.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Passenger Count
                  _buildSectionLabel(theme, Icons.people_outline, 'Passengers'.tr(context)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                          'Number of passengers'.tr(context),
                          style: GoogleFonts.roboto(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: _passengerCount > 1
                                  ? AppColors.primary
                                  : theme.dividerColor,
                              onPressed: () {
                                if (_passengerCount > 1) {
                                  setState(() => _passengerCount--);
                                }
                              },
                            ),
                            Text(
                              '$_passengerCount',
                              style: GoogleFonts.roboto(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: _passengerCount < maxPax
                                  ? AppColors.primary
                                  : theme.dividerColor,
                              onPressed: () {
                                if (_passengerCount < maxPax) {
                                  setState(() => _passengerCount++);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Max capacity: {n} passengers'.trWith(context, {'n': maxPax}),
                      style: GoogleFonts.roboto(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pickup Time
                  _buildSectionLabel(theme, Icons.schedule_outlined, 'Pickup Time'.tr(context)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pickupTimes.length,
                      itemBuilder: (context, index) {
                        final time = pickupTimes[index];
                        final isSelected = _selectedPickupTime == _pickupTimes[index] || 
                            (_pickupTimes[index] == 'Schedule' && !_pickupTimes.contains(_selectedPickupTime));
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(_pickupTimes[index] == 'Schedule' && isSelected && _selectedPickupTime != 'Schedule' 
                                ? 'Scheduled'.tr(context)
                                : time),
                            selected: isSelected,
                            onSelected: (_) async {
                              if (_pickupTimes[index] == 'Schedule') {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                  builder: (c, child) => Theme(
                                    data: theme.copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: theme.brightness)),
                                    child: child!,
                                  ),
                                );
                                if (date != null && context.mounted) {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (c, child) => Theme(
                                      data: theme.copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: theme.brightness)),
                                      child: child!,
                                    ),
                                  );
                                  if (t != null) {
                                    final dt = DateTime(date.year, date.month, date.day, t.hour, t.minute);
                                    setState(() => _selectedPickupTime = dt.toIso8601String());
                                  }
                                }
                              } else {
                                setState(() => _selectedPickupTime = _pickupTimes[index]);
                              }
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : theme.dividerColor.withOpacity(0.3),
                              ),
                            ),
                            labelStyle: GoogleFonts.roboto(
                              color: isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().fade(delay: 250.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  // Features List
                  _buildSectionLabel(theme, Icons.star_outline, 'Included'.tr(context)),
                  const SizedBox(height: 10),
                  ..._getFeatures(transport['name'], context).map(
                    (f) => _buildFeatureRow(theme, f),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Confirm Button
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                  top: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmed
                    ? null
                    : () async {
                        setState(() => _confirmed = true);
                        try {
                          String destinationName = widget.destination['title'] ?? widget.destination['name'] ?? '';
                          if (destinationName.isEmpty) {
                            destinationName = _destinationController.text.trim();
                          }
                          
                          // Extract map URL or coordinates to send to backend as locationLink
                          final mapUrl = widget.destination['location_link'] ?? widget.destination['google_maps_url'] ?? widget.destination['map_url'] ?? widget.destination['mapUrl'] ?? widget.destination['location_url'] ?? '';
                          final lat = widget.destination['latitude'] ?? widget.destination['lat'] ?? '';
                          final lng = widget.destination['longitude'] ?? widget.destination['lng'] ?? '';
                          
                          String? locationLink;
                          if (mapUrl.toString().isNotEmpty) {
                            locationLink = mapUrl.toString();
                          } else if (lat.toString().isNotEmpty && lng.toString().isNotEmpty) {
                            locationLink = 'https://maps.google.com/?q=$lat,$lng';
                          }
                          
                          if (destinationName.isEmpty) {
                            setState(() => _confirmed = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a destination.'.tr(context))));
                            return;
                          }
                          
                          await context.read<GuestPortalProvider>().requestTransportation(
                            vehicleId: transport['id'].toString(),
                            destination: destinationName.toString(),
                            pickupTime: _getIsoPickupTime(_selectedPickupTime),
                            passengers: _passengerCount,
                            locationLink: locationLink,
                          );

                          if (!context.mounted) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              backgroundColor: theme.scaffoldBackgroundColor,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                    child: Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 48),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Chauffeur Requested!'.tr(context),
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Your {name} is on the way. Please wait at the hotel lobby.'.trWith(context, {'name': transport['name'].toString()}),
                                    style: GoogleFonts.roboto(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.7),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                      ),
                                      child: Text(
                                        'Done'.tr(context),
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${'Error'.tr(context)}: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                            );
                            setState(() => _confirmed = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _confirmed
                      ? theme.dividerColor
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _confirmed ? 'Request Sent ✓'.tr(context) : 'Confirm & Request Chauffeur'.tr(context),
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
          label,
          style: GoogleFonts.roboto(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        )),
      ],
    );
  }

  Widget _buildFeatureRow(ThemeData theme, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(Icons.check, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
            feature,
            style: GoogleFonts.roboto(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              fontSize: 14,
            ),
          )),
        ],
      ),
    );
  }

  int _getMaxPassengers(dynamic transport) {
    if (transport is Map) {
      final index = transport['index'];
      if (index == 0 || index == 2) return 4;
      if (index == 1) return 14;

      final name = transport['name']?.toString() ?? '';
      final nameLower = name.toLowerCase();
      if (nameLower.contains('corolla') || nameLower.contains('sedan')) {
        return 4;
      }
      if (nameLower.contains('bus')) {
        return 14;
      }

      final cap = int.tryParse(transport['capacity']?.toString() ?? '');
      if (cap != null && cap > 0) return cap;

      return 4;
    } else if (transport is String) {
      final nameLower = transport.toLowerCase();
      if (nameLower.contains('corolla') || nameLower.contains('sedan')) {
        return 4;
      }
      if (nameLower.contains('bus')) {
        return 14;
      }
      return 4;
    }
    return 4;
  }

  List<String> _getFeatures(String name, BuildContext context) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('bus')) {
      return [
        'Professional hotel driver'.tr(context),
        'Spacious air-conditioned Toyota bus'.tr(context),
        'Luggage storage available'.tr(context),
        'Up to 14 passengers capacity'.tr(context),
        'Ideal for large groups & families'.tr(context),
        'Real-time GPS tracking'.tr(context),
      ];
    } else if (nameLower.contains('corolla')) {
      return [
        'Professional hotel chauffeur'.tr(context),
        'Air-conditioned Toyota Corolla'.tr(context),
        'Complimentary water bottles'.tr(context),
        'Meet & greet at hotel lobby'.tr(context),
        'Real-time GPS tracking'.tr(context),
      ];
    } else if (name.contains('Hotel Sedan')) {
      return [
        'Professional hotel chauffeur'.tr(context),
        'Air-conditioned luxury sedan'.tr(context),
        'Complimentary water bottles'.tr(context),
        'Meet & greet at hotel lobby'.tr(context),
        'Real-time GPS tracking'.tr(context),
      ];
    } else if (name.contains('Van')) {
      return [
        'Professional hotel driver'.tr(context),
        'Spacious air-conditioned van'.tr(context),
        'Luggage storage available'.tr(context),
        'Ideal for groups & families'.tr(context),
        'Real-time GPS tracking'.tr(context),
      ];
    } else if (name.contains('Taxi')) {
      return [
        'Licensed local driver'.tr(context),
        'Air-conditioned vehicle'.tr(context),
        'Metered fare'.tr(context),
        'Direct hotel booking'.tr(context),
      ];
    } else {
      return [
        'Shared shuttle service'.tr(context),
        'Air-conditioned vehicle'.tr(context),
        'Budget-friendly option'.tr(context),
        'Pickup from hotel entrance'.tr(context),
      ];
    }
  }
}
