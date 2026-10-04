import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_requests_screen.dart';
import 'package:triumph_hotels/features/guest_portal/widgets/create_request_bottom_sheet.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_custom_request_screen.dart';
import 'package:triumph_hotels/core/utils/guest_service_parser.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_chat_screen.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_notifications_screen.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_dining_screen.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_venue_detail_screen.dart';
import 'package:triumph_hotels/features/guest_portal/widgets/transport_options_bottom_sheet.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_laundry_screen.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_discover_screen.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';

class GuestPortalHomeScreen extends StatefulWidget {
  const GuestPortalHomeScreen({super.key});

  @override
  State<GuestPortalHomeScreen> createState() => _GuestPortalHomeScreenState();
}

class _GuestPortalHomeScreenState extends State<GuestPortalHomeScreen> {
  int _currentIndex = 0;

  static const Map<String, String> _languages = {
    'en': '🇺🇸 EN',
    'ar': '🇸🇦 AR',
    'es': '🇪🇸 ES',
    'fr': '🇫🇷 FR',
    'de': '🇩🇪 DE',
    'ru': '🇷🇺 RU',
    'zh': '🇨🇳 ZH',
    'ja': '🇯🇵 JA',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GuestPortalProvider>();
      provider.fetchLocalRecommendations();
      provider.fetchVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDarkMode),
      body: _buildBody(context, theme, isDarkMode, isSmallScreen, isTablet),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 1.0,
            ),
          ),
        ),
        child: Consumer<GuestPortalProvider>(
          builder: (context, provider, child) {
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              selectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
              unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: 'Home'.tr(context),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline),
                  activeIcon: const Icon(Icons.chat_bubble),
                  label: 'Requests'.tr(context),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.restaurant_outlined),
                  activeIcon: const Icon(Icons.restaurant),
                  label: 'Dining'.tr(context),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.local_laundry_service_outlined),
                  activeIcon: const Icon(Icons.local_laundry_service),
                  label: 'Laundry'.tr(context),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.explore_outlined),
                  activeIcon: const Icon(Icons.explore),
                  label: 'Discover'.tr(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDarkMode) {
    if (_currentIndex != 0) {
      String title = '';
      switch (_currentIndex) {
        case 1: title = 'Requests'; break;
        case 2: title = 'Dining & Cafes'; break;
        case 3: title = 'Laundry'; break;
        case 4: title = 'Discover'; break;
      }

      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
          onPressed: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        title: Text(
          title.tr(context),
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
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: AppColors.primary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.logo,
            height: 36, // Appropriate height for the app bar logo
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Text(
            'Home'.tr(context),
            style: GoogleFonts.roboto(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Language Selector
        Consumer<GuestPortalProvider>(
          builder: (context, provider, child) {
            final currentLang = provider.currentLanguage;
            final label = _languages[currentLang] ?? '🇺🇸 EN';

            return PopupMenuButton<String>(
              initialValue: currentLang,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (String code) {
                provider.changeLanguage(code);
              },
              itemBuilder: (BuildContext context) {
                return _languages.entries.map((entry) {
                  return PopupMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: GoogleFonts.roboto(
                        fontWeight: currentLang == entry.key ? FontWeight.bold : FontWeight.normal,
                        color: currentLang == entry.key ? AppColors.primary : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  );
                }).toList();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                  color: theme.cardColor,
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.roboto(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: theme.iconTheme.color, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        // Notification Icon
        Consumer<GuestPortalProvider>(
          builder: (context, provider, child) {
            final count = provider.unreadNotificationsCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GuestPortalNotificationsScreen(),
                      ),
                    );
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: theme.dividerColor.withOpacity(0.5),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, bool isDarkMode, bool isSmallScreen, bool isTablet) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(theme, isDarkMode, isSmallScreen);
      case 1:
        return const GuestPortalRequestsScreen();
      case 2:
        return const GuestPortalDiningScreen(showAppBar: false);
      case 3:
        return const GuestPortalLaundryScreen(showAppBar: false);
      case 4:
        return const GuestPortalDiscoverScreen(showAppBar: false);
      default:
        return Center(
          child: Text(
            'Coming Soon'.tr(context),
            style: GoogleFonts.roboto(
              color: AppColors.primary,
              fontSize: 24,
            ),
          ),
        );
    }
  }

  Widget _buildHomeTab(ThemeData theme, bool isDarkMode, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20.0 : ResponsiveUtils.getScreenWidth(context) * 0.1,
        vertical: isSmallScreen ? 20.0 : 32.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(theme, isDarkMode, isSmallScreen),
          const SizedBox(height: 24),
          _buildActionButtons(theme, isDarkMode),
          const SizedBox(height: 32),
          _buildHelpSection(theme, isDarkMode, isSmallScreen: isSmallScreen),
          const SizedBox(height: 32),
          _buildDiningSection(theme, isDarkMode),
          const SizedBox(height: 32),
          _buildDiscoverSection(theme, isDarkMode),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, bool isDarkMode, bool isSmallScreen) {
    final guest = context.watch<GuestPortalProvider>();

    // Dynamic greeting based on time of day
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning,'
        : hour < 17
            ? 'Good Afternoon,'
            : 'Good Evening,';

    // Format check-in/out dates from ISO string to readable format
    String formatDate(String iso) {
      try {
        final dt = DateTime.parse(iso);
        return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
      } catch (_) {
        return iso.isNotEmpty ? iso : '—';
      }
    }

    final guestName = guest.guestName.isNotEmpty ? guest.guestName.toUpperCase() : 'WELCOME'.tr(context);
    final roomLabel = guest.roomNumber.isNotEmpty ? '${'Room'.tr(context)} ${guest.roomNumber}' : 'Guest'.tr(context);
    final checkIn = formatDate(guest.checkIn);
    final checkOut = formatDate(guest.checkOut);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                greeting.tr(context),
                style: GoogleFonts.roboto(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Text(
                roomLabel,
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          guestName,
          style: GoogleFonts.roboto(
            color: AppColors.primary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ).animate().fade().slideY(begin: 0.2),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildDateCard(theme, 'Check-in'.tr(context), checkIn),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateCard(theme, 'Check-out'.tr(context), checkOut),
            ),
          ],
        ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildDateCard(ThemeData theme, String label, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(16),
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
          Text(
            label,
            style: GoogleFonts.roboto(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: GoogleFonts.roboto(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              CreateRequestBottomSheet.show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
            child: Column(
              children: [
                const Icon(Icons.add, size: 24),
                const SizedBox(height: 8),
                Text(
                  'Create Request'.tr(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GuestPortalChatScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: theme.cardColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Consumer<GuestPortalProvider>(
                  builder: (context, provider, child) {
                    final count = provider.unreadChatCount;
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 24),
                        if (count > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Guest Services Chat'.tr(context),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fade(delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildHelpSection(ThemeData theme, bool isDarkMode, {bool isSmallScreen = true}) {
    final fallbackItems = [
      {'icon': Icons.luggage_outlined,               'title': 'Luggage Down',       'category': 'Concierge',    'categoryColor': Colors.indigoAccent},
      {'icon': Icons.ac_unit_outlined,               'title': 'AC Usage Support',   'category': 'Maintenance',  'categoryColor': Colors.lightBlue},
      {'icon': Icons.room_service_outlined,          'title': 'Coffee Tray',        'category': 'Room Service', 'categoryColor': Colors.redAccent},
      {'icon': Icons.ac_unit,                        'title': 'A/C On',             'category': 'Maintenance',  'categoryColor': Colors.lightBlue},
      {'icon': Icons.dry_cleaning_outlined,          'title': 'Extra Towels',       'category': 'Housekeeping', 'categoryColor': Colors.orange},
      {'icon': Icons.cleaning_services_outlined,     'title': 'Make Up Room',       'category': 'Housekeeping', 'categoryColor': Colors.orange},
      {'icon': Icons.restaurant_outlined,            'title': 'Collect Plates',     'category': 'Room Service', 'categoryColor': Colors.redAccent},
      {'icon': Icons.wifi_outlined,                  'title': 'WiFi Help',          'category': 'I.T',          'categoryColor': Colors.purpleAccent},
    ];

    return Consumer<GuestPortalProvider>(
      builder: (context, provider, child) {
        final hasDynamic = provider.requestTemplates.isNotEmpty;
        final itemsCount = hasDynamic ? provider.requestTemplates.length : fallbackItems.length;

        if (provider.isLoadingTemplates && !hasDynamic) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }

        final cardWidth = isSmallScreen ? 124.0 : 138.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How Can We Help?'.tr(context),
                  style: GoogleFonts.roboto(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 144,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                itemCount: itemsCount,
                itemBuilder: (context, index) {
                  final String title;
                  final String category;
                  final IconData icon;
                  final Color categoryColor;

                  if (hasDynamic) {
                    final template = provider.requestTemplates[index];
                    title = template.title.replaceAll('\n', ' ').trim();
                    category = template.category;
                    icon = GuestServiceParser.parseIcon(template.iconStr, template.category);
                    categoryColor = GuestServiceParser.parseColor(template.colorStr, template.category);
                  } else {
                    final item = fallbackItems[index];
                    final raw = (item['title'] as String).tr(context);
                    title = raw.replaceAll('\n', ' ').trim();
                    category = item['category'] as String;
                    icon = item['icon'] as IconData;
                    categoryColor = item['categoryColor'] as Color;
                  }

                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 12, top: 2, bottom: 6),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : theme.dividerColor.withOpacity(0.15),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.25)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () {
                          if (category.toLowerCase().contains('transport') || title.toLowerCase().contains('transport')) {
                            TransportOptionsBottomSheet.show(context, theme);
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuestPortalCustomRequestScreen(
                                categoryTitle: category,
                                categoryColor: categoryColor,
                                initialDescription: '${'Requesting:'.tr(context)} $title',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(isDarkMode ? 0.20 : 0.10),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: categoryColor.withOpacity(isDarkMode ? 0.35 : 0.22),
                                    width: 1.0,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: categoryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ).animate().fade(delay: 400.ms).slideY(begin: 0.2);
      },
    );
  }


  Widget _buildDiningSection(ThemeData theme, bool isDarkMode) {
    final provider = context.watch<GuestPortalProvider>();
    final venues = provider.venues;
    
    // Default mock items just in case the backend venues fail to load
    List<Map<String, dynamic>> diningItems = [
      {
        'id': '',
        'title': 'Room Service'.tr(context),
        'subtitle': 'a hotel amenity that working 24/7 allowing...'.tr(context),
        'image': AppImages.placeholderHotel2,
        'isAvailable': true,
      },
    ];

    if (venues.isNotEmpty) {
      diningItems = venues.take(2).map((v) {
        final title = v['title']?.toString() ?? 'Venue'.tr(context);
        final subtitle = v['subtitle']?.toString().trim() ?? '';
        final imageUrl = v['image']?.toString();
        
        return {
          'id': v['id']?.toString() ?? '',
          'title': title.isNotEmpty ? title : 'Venue'.tr(context),
          'subtitle': subtitle.isNotEmpty ? subtitle : 'Enjoy our finest dining experience.'.tr(context),
          'image': (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : AppImages.placeholderHotel1,
          'isAvailable': v['isAvailable'] as bool? ?? true,
        };
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Dining Experiences'.tr(context),
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuestPortalDiningScreen(),
                  ),
                );
              },
              child: Text(
                'View All'.tr(context),
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.isSmallScreen(context) ? 2 : ResponsiveUtils.isTablet(context) ? 3 : 4,
            childAspectRatio: ResponsiveUtils.isSmallScreen(context) ? 0.85 : 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: diningItems.length,
          itemBuilder: (context, index) {
            final item = diningItems[index];
            return _buildDiningCard(
              id: item['id'] as String,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              image: item['image'] as String,
              isAvailable: item['isAvailable'] as bool,
            );
          },
        ),
      ],
    ).animate().fade(delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildDiningCard({required String id, required String title, required String subtitle, required String image, required bool isAvailable}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: (image.startsWith('http') || image.startsWith('/')) 
              ? NetworkImage(image.startsWith('/') ? 'https://ticketx.triumphhotel.com$image' : image) as ImageProvider
              : AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.85),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: AppColors.goldLight, // Using goldLight on dark background
                fontSize: 16, // Reduced slightly to accommodate 2 lines gracefully
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuestPortalVenueDetailScreen(
                      venueId: id,
                      title: title,
                      subtitle: subtitle,
                      image: image,
                      isOpen: isAvailable,
                      hours: '12:00 PM - 11:30 PM', // Fallback hours
                      tags: const ['Dining', 'Experience'], // Fallback tags
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: Text(
                  'View Details'.tr(context),
                  style: GoogleFonts.roboto(
                    color: AppColors.goldLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverSection(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Discover'.tr(context),
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuestPortalDiscoverScreen(),
                  ),
                );
              },
              child: Text(
                'View All'.tr(context),
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<GuestPortalProvider>(
          builder: (context, provider, child) {
            final recs = provider.localRecommendations;
            if (recs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No local recommendations available.'.tr(context),
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  ),
                ),
              );
            }

            // Limit to 4 items on the home screen
            final displayItems = recs.take(4).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return _buildDiscoverCard(
                  item: item as Map<String, dynamic>,
                  theme: theme,
                  isSmallScreen: ResponsiveUtils.isSmallScreen(context),
                );
              },
            );
          },
        ),
      ],
    ).animate().fade(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildDiscoverCard({required Map<String, dynamic> item, required ThemeData theme, required bool isSmallScreen}) {
    final title = (item['title'] ?? item['name'] ?? 'Unknown Place'.tr(context)).toString();
    final category = (item['category'] ?? '').toString();
    final distance = (item['distance'] ?? item['distanceKm']?.toString() ?? '').toString();
    // place_photos is a list of relative paths; take the first one
    final photos = item['place_photos'];
    String imageUrl = '';
    if (photos is List && photos.isNotEmpty) {
      imageUrl = photos.first.toString();
    } else {
      imageUrl = (item['image'] ?? '').toString();
    }
    final bool isNetworkUrl = imageUrl.startsWith('http') || imageUrl.startsWith('/');

    return Container(
      height: isSmallScreen ? 280 : 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        color: theme.cardColor,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: isNetworkUrl 
              ? (imageUrl.startsWith('/') 
                  ? Image.network('https://ticketx.triumphhotel.com$imageUrl', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)) 
                  : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)))
              : (imageUrl.isNotEmpty ? Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)) : const Icon(Icons.broken_image)),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.roboto(
                          color: AppColors.goldLight,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (distance.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  category.isNotEmpty ? '${category[0].toUpperCase()}${category.substring(1)}'.tr(context) : '',
                  style: GoogleFonts.roboto(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      GuestPortalDiscoverScreen.showPlaceDetails(context, theme, item);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                    child: Text('View Details'.tr(context), style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
