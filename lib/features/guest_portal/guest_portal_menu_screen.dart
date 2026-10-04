import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GuestPortalMenuScreen extends StatefulWidget {
  final String venueId;
  final String venueName;
  final String venueImage;

  const GuestPortalMenuScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.venueImage,
  });

  static Map<String, List<Map<String, dynamic>>> venueCarts = {};

  static void showCartAndReservation(BuildContext context, ThemeData theme, String venueId, String venueName, VoidCallback onUpdate) {
    final isRoomService = venueName.toLowerCase().contains('room service');

    final dateController = TextEditingController();
    final timeController = TextEditingController();
    int guestCount = 2;
    final specialReqController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cartItems = venueCarts[venueId] ?? [];
            
            // Group items by ID to count quantities
            final Map<String, int> itemQuantities = {};
            final Map<String, Map<String, dynamic>> uniqueItems = {};
            
            for (var item in cartItems) {
              final id = item['id'].toString();
              itemQuantities[id] = (itemQuantities[id] ?? 0) + 1;
              uniqueItems[id] = item;
            }

            double total = 0;
            for (var item in cartItems) {
              final priceStr = (item['price'] as String).replaceAll('\$', '').replaceAll(RegExp(r'EGP\s*', caseSensitive: false), '');
              total += double.tryParse(priceStr) ?? 0;
            }

            final bgColor = theme.scaffoldBackgroundColor;
            final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
            final dividerColor = theme.dividerColor;

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Complete Your Order'.tr(context), style: GoogleFonts.playfairDisplay(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(venueName, style: GoogleFonts.roboto(color: textColor.withOpacity(0.5), fontSize: 16)),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Your Order Box
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: dividerColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Your Order'.tr(context),
                                        style: GoogleFonts.playfairDisplay(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                if (cartItems.isEmpty)
                                  Text('Cart is empty.'.tr(context), style: TextStyle(color: textColor.withOpacity(0.5)))
                                else
                                  ...uniqueItems.values.map((item) {
                                    final id = item['id'].toString();
                                    final qty = itemQuantities[id] ?? 0;
                                    final priceStr = (item['price'] as String).replaceAll('\$', '').replaceAll(RegExp(r'EGP\s*', caseSensitive: false), '');
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item['name'], style: GoogleFonts.roboto(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 4),
                                                Text('EGP $priceStr × 1', style: GoogleFonts.roboto(color: textColor.withOpacity(0.4), fontSize: 14)), // Following design screenshot text
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setModalState(() {
                                                    // Find and remove one instance
                                                    final idx = cartItems.indexWhere((i) => i['id'].toString() == id);
                                                    if (idx != -1) cartItems.removeAt(idx);
                                                  });
                                                  onUpdate();
                                                  if (cartItems.isEmpty) Navigator.pop(context);
                                                },
                                                child: Container(
                                                  width: 36, height: 36,
                                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: textColor.withOpacity(0.2))),
                                                  child: Icon(Icons.remove, color: textColor.withOpacity(0.5), size: 18),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(qty.toString(), style: GoogleFonts.roboto(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 16),
                                              GestureDetector(
                                                onTap: () {
                                                  setModalState(() {
                                                    cartItems.add(item);
                                                  });
                                                  onUpdate();
                                                },
                                                child: Container(
                                                  width: 36, height: 36,
                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                                  child: Icon(Icons.add, color: bgColor, size: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                
                                Divider(color: dividerColor, height: 32),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total:'.tr(context), style: GoogleFonts.playfairDisplay(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text('EGP ${total.toStringAsFixed(2)}', style: GoogleFonts.playfairDisplay(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          Text('Special Instructions'.tr(context), style: GoogleFonts.roboto(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: specialReqController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Any special instructions for your order...'.tr(context),
                                hintStyle: TextStyle(color: textColor.withOpacity(0.2)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              maxLines: 4,
                            ),
                          ),
                          
                          if (!isRoomService) ...[
                            const SizedBox(height: 32),
                            Text('Reservation Details'.tr(context), style: GoogleFonts.roboto(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: dateController,
                              style: TextStyle(color: textColor),
                              readOnly: true,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  dateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Date'.tr(context),
                                labelStyle: TextStyle(color: textColor.withOpacity(0.5)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dividerColor)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dividerColor)),
                                prefixIcon: Icon(Icons.calendar_today, color: textColor.withOpacity(0.5)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: timeController,
                              style: TextStyle(color: textColor),
                              readOnly: true,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  timeController.text = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Time'.tr(context),
                                labelStyle: TextStyle(color: textColor.withOpacity(0.5)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dividerColor)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dividerColor)),
                                prefixIcon: Icon(Icons.access_time, color: textColor.withOpacity(0.5)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: dividerColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.people, color: textColor.withOpacity(0.5)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Number of Guests'.tr(context),
                                            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (guestCount > 1) setModalState(() => guestCount--);
                                        },
                                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                      ),
                                      Text('$guestCount', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        onPressed: () {
                                          if (guestCount < 20) setModalState(() => guestCount++);
                                        },
                                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Confirm Button
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border(top: BorderSide(color: dividerColor)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          setModalState(() => isLoading = true);
                          final provider = context.read<GuestPortalProvider>();
                          
                          // Convert itemQuantities map back to exactly what the web portal sends
                          final orderItems = uniqueItems.values.map((item) {
                            return {
                              'id': item['id'] ?? 'unknown', 
                              'name': item['name'] ?? '',
                              'price': double.tryParse((item['price'] as String).replaceAll('\$', '').replaceAll(RegExp(r'EGP\s*', caseSensitive: false), '')) ?? 0.0,
                              'quantity': itemQuantities[item['id'].toString()] ?? 1, 
                            };
                          }).toList();
                          
                          bool orderSuccess = true;
                          String activeVenueId = venueId;
                          if (activeVenueId.isEmpty || activeVenueId == 'room_service') {
                            final isLookingForRoomService = venueName.toLowerCase().contains('room service');
                            final match = provider.venues.firstWhere((v) {
                              if (isLookingForRoomService) {
                                return v['type'] == 'room_service' || v['venue_type'] == 'room_service' || v['name'].toString().toLowerCase().contains('room service');
                              }
                              return v['name'].toString().toLowerCase().contains(venueName.toLowerCase());
                            }, orElse: () => provider.venues.isNotEmpty ? provider.venues.first : <String, dynamic>{});
                            activeVenueId = match['id']?.toString() ?? '';
                          }

                          // bool orderSuccess = true;`
                          bool resSuccess = true;

                          if (isRoomService) {
                            if (orderItems.isNotEmpty) {
                              orderSuccess = await provider.placeFoodOrder(activeVenueId, orderItems, total, specialReqController.text);
                            }
                          } else {
                            // Always use order-with-reservation endpoint, even if cart is empty
                            resSuccess = await provider.createOrderWithReservation(
                              activeVenueId,
                              dateController.text.isNotEmpty ? dateController.text : 'Today',
                              timeController.text.isNotEmpty ? timeController.text : 'Now',
                              guestCount,
                              specialReqController.text,
                              orderItems,
                              total,
                            );
                          }
                          
                          if (context.mounted) {
                            setModalState(() => isLoading = false);
                            if (orderSuccess && resSuccess) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(isRoomService ? 'Order confirmed! It will be delivered to your room.'.tr(context) : 'Order & Reservation confirmed!'.tr(context)),
                                backgroundColor: Colors.green,
                              ));
                              venueCarts[venueId]?.clear();
                              onUpdate();
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Server Error Details'),
                                  content: SingleChildScrollView(
                                    child: Text(provider.errorMessage ?? 'Unknown error'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDCA74E), 
                          foregroundColor: bgColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF1B2332), strokeWidth: 2))
                          : Text('${'Confirm Order'.tr(context)} - EGP ${total.toStringAsFixed(2)}',
                              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  State<GuestPortalMenuScreen> createState() => _GuestPortalMenuScreenState();
}

class _GuestPortalMenuScreenState extends State<GuestPortalMenuScreen>
    with SingleTickerProviderStateMixin {

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      GuestPortalMenuScreen.venueCarts.putIfAbsent(widget.venueId, () => []);
      GuestPortalMenuScreen.venueCarts[widget.venueId]!.add(item);
    });
  }

  void _showCartAndReservation(BuildContext context, ThemeData theme, String venueId, String venueName, VoidCallback onUpdate) {
    GuestPortalMenuScreen.showCartAndReservation(context, theme, venueId, venueName, onUpdate);
  }

  Map<String, List<Map<String, dynamic>>> get _menuData {
    final provider = context.watch<GuestPortalProvider>();
    // Use venueId as key; fallback to venueName for backward compatibility
    final key = widget.venueId.isNotEmpty ? widget.venueId : widget.venueName.toLowerCase().replaceAll(' ', '_');
    final apiItems = provider.menus[key];

    if (apiItems == null || apiItems.isEmpty) return {};

    // API 10.4 returns flat list of items — group by category_name
    Map<String, List<Map<String, dynamic>>> data = {};
    for (final rawItem in apiItems) {
      final item = rawItem as Map<String, dynamic>;
      final categoryName = item['category_name']?.toString() ?? 'General';

      // Extract first image URL from images array
      String imageUrl = '';
      final imgs = item['images'];
      if (imgs is List && imgs.isNotEmpty) {
        final first = imgs.first;
        imageUrl = (first is Map ? (first['url'] ?? first['path'])?.toString() : first?.toString()) ?? '';
      }

      bool isAvailable = item['is_available'] ?? true;
      final availHours = item['availability_hours'];
      
      if (isAvailable && availHours != null) {
        try {
          String? startStr;
          String? endStr;
          
          if (availHours is Map) {
            if (availHours.containsKey('daily') && availHours['daily'] is Map) {
              final daily = availHours['daily'];
              startStr = daily['open']?.toString();
              endStr = daily['close']?.toString();
            } else {
              startStr = (availHours['start'] ?? availHours['start_time'] ?? availHours['open'])?.toString();
              endStr = (availHours['end'] ?? availHours['end_time'] ?? availHours['close'])?.toString();
            }
          } else if (availHours is String && availHours.contains('-')) {
            final parts = availHours.split('-');
            if (parts.length >= 2) {
              startStr = parts[0].trim();
              endStr = parts[1].trim();
            }
          }
          
          if (startStr != null && endStr != null) {
            final now = DateTime.now();
            final currentMinutes = now.hour * 60 + now.minute;
            
            final startParts = startStr.split(':');
            final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
            
            final endParts = endStr.split(':');
            final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
            
            if (endMinutes < startMinutes) {
              // Overnight (e.g., 22:00 to 06:00)
              isAvailable = (currentMinutes >= startMinutes || currentMinutes <= endMinutes);
            } else {
              // Normal daytime (e.g., 06:00 to 11:00)
              isAvailable = (currentMinutes >= startMinutes && currentMinutes <= endMinutes);
            }
          }
        } catch (_) {}
      }

      final formattedItem = {
        'id': item['id']?.toString() ?? '',
        'name': item['name']?.toString() ?? 'Item',
        'desc': item['description']?.toString() ?? '',
        'price': '${item['price'] ?? '0.00'} EGP',
        'tag': item['is_featured'] == true
            ? 'Chef\'s Pick'
            : ((item['dietary_tags'] as List?)?.isNotEmpty == true
                ? (item['dietary_tags'] as List).first.toString()
                : ''),
        'time': '${item['preparation_time'] ?? 10} min',
        'calories': '',
        'ingredients': List<String>.from(
          (item['ingredients'] as List?)?.map((e) => e.toString()) ?? [],
        ),
        'allergens': List<String>.from(
          (item['allergens'] as List?)?.map((e) => e.toString()) ?? [],
        ),
        'image': imageUrl,
        'isAvailable': isAvailable,
      };

      data.putIfAbsent(categoryName, () => []);
      data[categoryName]!.add(formattedItem);
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GuestPortalProvider>();
      final key = widget.venueId.isNotEmpty ? widget.venueId : widget.venueName.toLowerCase().replaceAll(' ', '_');
      provider.fetchDiningMenu(key);
      if (widget.venueId.isNotEmpty) {
        provider.fetchVenueCategories(widget.venueId);
      }
    });
  }

  void _showItemDetail(BuildContext context, ThemeData theme, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final tag = item['tag'] as String;
        final hasTag = tag.isNotEmpty;
        Color tagColor = AppColors.primary;
        if (tag == 'Vegetarian' || tag == 'Vegan') tagColor = Colors.green;
        if (tag == 'Signature' || tag == 'Chef\'s Pick') tagColor = Colors.amber;
        if (tag == 'Seafood') tagColor = Colors.lightBlue;
        if (tag == 'Healthy') tagColor = Colors.teal;

        final ingredients = item['ingredients'] as List<String>;

        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 14),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'],
                              style: GoogleFonts.roboto(
                                color: AppColors.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['price'],
                            style: GoogleFonts.roboto(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tag + time + calories row
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (hasTag)
                            _chip(tag, tagColor),
                          _chip('⏱ ${item['time']}', Colors.blueGrey),
                          _chip('🔥 ${item['calories']}', Colors.orange),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Divider(color: theme.dividerColor.withOpacity(0.4)),

                      const SizedBox(height: 20),

                      Text(
                        'Description',
                        style: GoogleFonts.roboto(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        item['desc'],
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Ingredients',
                        style: GoogleFonts.roboto(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: ingredients.map((ing) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  ing,
                                  style: GoogleFonts.roboto(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            _addToCart(item);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['name']} ${'added to cart!'.tr(context)}'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                          ),
                          child: Text(
                            'Add to Cart'.tr(context),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    
    final currentMenuData = _menuData;
    final categories = currentMenuData.keys.toList();
    final cartItems = GuestPortalMenuScreen.venueCarts[widget.venueId] ?? [];
    final provider = context.watch<GuestPortalProvider>();

    if (provider.isLoading && currentMenuData.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentMenuData.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent, 
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: AppColors.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'No menu available right now.',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        floatingActionButton: cartItems.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _showCartAndReservation(context, theme, widget.venueId, widget.venueName, () {
                  setState(() {}); // Rebuild to update cart counter or hide FAB
                }),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  '${'View Cart'.tr(context)} (${cartItems.length})',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: theme.cardColor.withOpacity(0.85),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  color: AppColors.primary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 56),
              title: Text(
                widget.venueName,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  (widget.venueImage.startsWith('http') || widget.venueImage.startsWith('/'))
                    ? CachedNetworkImage(
                        imageUrl: widget.venueImage.startsWith('/') ? 'https://ticketx.triumphhotel.com${widget.venueImage}' : widget.venueImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: theme.cardColor),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      )
                    : Image.asset(widget.venueImage, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  labelStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
                  tabs: categories.map((cat) {
                    String translatedName = cat.tr(context);
                    if (provider.venueCategories.containsKey(widget.venueId)) {
                      final cats = provider.venueCategories[widget.venueId]!;
                      for (final c in cats) {
                        if (c['original_name']?.toString().toLowerCase() == cat.toLowerCase() ||
                            c['name']?.toString().toLowerCase() == cat.toLowerCase()) {
                          translatedName = c['name']?.toString() ?? translatedName;
                          break;
                        }
                      }
                    }
                    return Tab(text: translatedName);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          children: categories.map((category) {
            final items = currentMenuData[category]!;
            final horizontalPadding = isSmallScreen
                ? 16.0
                : ResponsiveUtils.getScreenWidth(context) * 0.12;

            return isSmallScreen
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _buildMenuItemCard(context, theme, items[index], index),
                  )
                : GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.isTablet(context) ? 2 : 3,
                      childAspectRatio: ResponsiveUtils.isTablet(context) ? 2.0 : 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _buildMenuItemCard(context, theme, items[index], index),
                  );
          }).toList(),
        ),
      ),
    ),
  );
  }

  Widget _buildMenuItemCard(BuildContext context, ThemeData theme, Map<String, dynamic> item, int index) {
    final tag = item['tag'] as String;
    final hasTag = tag.isNotEmpty;
    final bool isAvailable = item['isAvailable'] == true;

    Color tagColor = AppColors.primary;
    if (tag == 'Vegetarian' || tag == 'Vegan') tagColor = Colors.green;
    if (tag == 'Signature' || tag == 'Chef\'s Pick') tagColor = Colors.amber;
    if (tag == 'Seafood') tagColor = Colors.lightBlue;
    if (tag == 'Healthy') tagColor = Colors.teal;

    return GestureDetector(
      onTap: isAvailable ? () => _showItemDetail(context, theme, item) : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This item is currently not available.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + tag row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: GoogleFonts.roboto(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hasTag) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: tagColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            tag.tr(context),
                            style: GoogleFonts.roboto(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['desc'],
                    style: GoogleFonts.roboto(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Time & Calories row
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        item['time'],
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.local_fire_department_outlined, size: 13, color: Colors.orange.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        item['calories'],
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['price'],
                  style: GoogleFonts.roboto(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: isAvailable ? () {
                    _addToCart(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['name']} ${'added to cart!'.tr(context)}'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This item is currently not available.'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAvailable ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: isAvailable ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.add, color: isAvailable ? AppColors.primary : Colors.grey, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      )).animate().fade(delay: Duration(milliseconds: 100 + (index * 80))).slideY(begin: 0.1),
    );
  }
}
