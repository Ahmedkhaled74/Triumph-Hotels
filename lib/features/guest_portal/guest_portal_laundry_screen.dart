import 'package:flutter/material.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GuestPortalLaundryScreen extends StatefulWidget {
  final bool showAppBar;
  const GuestPortalLaundryScreen({super.key, this.showAppBar = true});

  @override
  State<GuestPortalLaundryScreen> createState() => _GuestPortalLaundryScreenState();
}

class _GuestPortalLaundryScreenState extends State<GuestPortalLaundryScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  final TextEditingController _instructionsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestPortalProvider>().fetchLaundryData();
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cartItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to your laundry bag.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_cartItems.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final Map<String, int> quantities = {};
    for (var item in _cartItems) {
      final id = item['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        quantities[id] = (quantities[id] ?? 0) + 1;
      }
    }

    final itemsPayload = quantities.entries.map((e) => {
      'serviceId': e.key,
      'quantity': e.value,
      'notes': ''
    }).toList();

    final success = await context.read<GuestPortalProvider>().placeLaundryOrder(
      itemsPayload,
      _instructionsController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pop(context); // close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laundry pickup requested! Staff will arrive shortly.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _cartItems.clear();
          _instructionsController.clear();
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<GuestPortalProvider>().errorMessage ?? 'Failed to place order.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Laundry Bag',
                    style: GoogleFonts.roboto(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _cartItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 64, color: Theme.of(context).dividerColor),
                                const SizedBox(height: 16),
                                Text(
                                  'Your bag is empty.',
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(item['icon']?.toString() ?? '👕', style: const TextStyle(fontSize: 20)),
                                ),
                                title: Text(item['name'] ?? '', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                                subtitle: Text('EGP ${item['price']}', style: GoogleFonts.roboto(color: AppColors.primary)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setModalState(() {
                                      _cartItems.removeAt(index);
                                    });
                                    setState(() {});
                                    if (_cartItems.isEmpty) Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  if (_cartItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estimated Base Total',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  double total = 0;
                                  for (var item in _cartItems) {
                                    final price = item['price'];
                                    if (price is num) {
                                      total += price;
                                    } else if (price is String) {
                                      total += double.tryParse(price) ?? 0.0;
                                    }
                                  }
                                  return Text(
                                    'EGP ${total.toStringAsFixed(2)}',
                                    style: GoogleFonts.roboto(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _instructionsController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Specific Instructions (Optional)',
                              hintText: 'e.g. Use gentle detergent, fold shirts',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : () async {
                                setModalState(() => _isSubmitting = true);
                                await _submitOrder();
                                setModalState(() => _isSubmitting = false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSubmitting 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'REQUEST PICKUP'.tr(context), 
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final horizontalPadding = isSmallScreen ? 16.0 : ResponsiveUtils.getScreenWidth(context) * 0.12;

    return Consumer<GuestPortalProvider>(
      builder: (context, provider, child) {
        final categories = provider.laundryCategories;
        final services = provider.laundryServices;
        final isLoading = provider.isLoading;

        // Derive categories from services as fallback if the categories API is empty.
        // This handles the case where /laundry/categories returns [] but /laundry/services
        // returns items with a 'category' field.
        final resolvedCategories = categories.isNotEmpty
            ? categories
            : services
                .map((s) => s['category']?.toString() ?? '')
                .where((c) => c.isNotEmpty)
                .toSet()
                .map((c) => {'name': c, 'id': c})
                .toList();

        Widget bodyContent;

        if (isLoading && resolvedCategories.isEmpty && services.isEmpty) {
          bodyContent = const Center(child: CircularProgressIndicator());
        } else if (resolvedCategories.isEmpty && services.isEmpty) {
          bodyContent = const Center(child: Text('No laundry services available.'));
        } else {
          // If no categories but services exist, show all services in a single list.
          if (resolvedCategories.isEmpty) {
            bodyContent = isSmallScreen
                ? ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) => _buildServiceCard(theme, services[index] as Map<String, dynamic>, index),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.isTablet(context) ? 2 : 3,
                      childAspectRatio: ResponsiveUtils.isTablet(context) ? 2.2 : 2.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) => _buildServiceCard(theme, services[index] as Map<String, dynamic>, index),
                  );
          } else {
          bodyContent = DefaultTabController(
            length: resolvedCategories.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  labelStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: resolvedCategories.map((cat) {
                    final name = cat['name']?.toString() ?? 'Unknown';
                    // Capitalize the tab label
                    final label = name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : name;
                    return Tab(text: label);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: resolvedCategories.map((cat) {
                      final categoryName = cat['name']?.toString() ?? '';
                      // Case-insensitive match: service 'category: standard' vs tab 'Standard'
                      final filteredServices = services.where((s) =>
                        (s['category']?.toString() ?? '').toLowerCase() == categoryName.toLowerCase()
                      ).toList();

                      if (filteredServices.isEmpty) {
                        return const Center(child: Text('No services in this category.'));
                      }

                      return isSmallScreen
                          ? ListView.builder(
                              itemCount: filteredServices.length,
                              itemBuilder: (context, index) => _buildServiceCard(theme, filteredServices[index] as Map<String, dynamic>, index),
                            )
                          : GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveUtils.isTablet(context) ? 2 : 3,
                                childAspectRatio: ResponsiveUtils.isTablet(context) ? 2.2 : 2.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: filteredServices.length,
                              itemBuilder: (context, index) => _buildServiceCard(theme, filteredServices[index] as Map<String, dynamic>, index),
                            );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
          } // end else (resolvedCategories not empty)
        }

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
                    'Laundry & Pressing',
                    style: GoogleFonts.roboto(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.receipt_long),
                      color: AppColors.primary,
                      onPressed: () {
                        context.read<GuestPortalProvider>().fetchLaundryOrders();
                        _showOrdersSheet();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1.0),
                    child: Container(color: theme.dividerColor.withOpacity(0.5), height: 1.0),
                  ),
                )
              : null,
          floatingActionButton: _cartItems.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _showCheckoutSheet,
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.shopping_bag, color: Colors.white),
                  label: Text(
                    'View Bag (${_cartItems.length})',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverPadding(
                  padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 24, bottom: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Impeccable Care for Your Wardrobe',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Leave your laundry to us and step out in style.',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.dry_cleaning, color: Colors.white, size: 48),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Services',
                            style: GoogleFonts.roboto(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.receipt_long),
                            color: AppColors.primary,
                            tooltip: 'My Orders',
                            onPressed: () {
                              context.read<GuestPortalProvider>().fetchLaundryOrders();
                              _showOrdersSheet();
                            },
                          ),
                        ],
                      ).animate().fade(delay: 200.ms).slideX(begin: 0.05),
                    ]),
                  ),
                ),
              ];
            },
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: bodyContent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(ThemeData theme, Map<String, dynamic> service, int index) {
    return GestureDetector(
      onTap: () => _showServiceDetail(service),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(service['icon']?.toString() ?? '👕', style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] ?? '',
                  style: GoogleFonts.roboto(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  service['description'] ?? '',
                  style: GoogleFonts.roboto(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      '${service['estimatedTimeHours']} Hours',
                      style: GoogleFonts.roboto(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EGP ${service['price']}',
                      style: GoogleFonts.roboto(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => _addToCart(service),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Add to Bag',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    )],
      ),
    ));
  }

  void _showServiceDetail(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(service['icon']?.toString() ?? '👕', style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] ?? '',
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EGP ${service['price']}',
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Description',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (service['description']?.toString() ?? '').isNotEmpty 
                    ? service['description'] 
                    : 'No detailed description available.',
                style: GoogleFonts.roboto(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated Time: ${service['estimatedTimeHours']} Hours',
                    style: GoogleFonts.roboto(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addToCart(service);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Add to Bag'.tr(context),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showOrdersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 14),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'My Laundry Orders',
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<GuestPortalProvider>(
                  builder: (context, provider, child) {
                    final orders = provider.laundryOrders;
                    if (orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).dividerColor),
                            const SizedBox(height: 16),
                            Text(
                              'No past laundry orders.'.tr(context),
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final status = order['status']?.toString().toUpperCase() ?? 'PENDING';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Order #${order['orderNumber'] ?? 'Unknown'}',
                                      style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8), // Add a little spacing between text and badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: status == 'COMPLETED' ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: GoogleFonts.roboto(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: status == 'COMPLETED' ? Colors.green : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Total: EGP ${order['totalAmount']}',
                                style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
