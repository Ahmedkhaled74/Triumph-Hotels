import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/widgets/custom_drawer.dart';
import 'package:triumph_hotels/features/home/widgets/hotel_card.dart';
import 'package:triumph_hotels/features/profile/profile_screen.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/features/auth/guest_portal_login_screen.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/providers/global_notification_provider.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_home_screen.dart';
import 'package:triumph_hotels/features/notifications/global_notifications_screen.dart';
import 'package:triumph_hotels/services/popup_api_service.dart';
import 'package:triumph_hotels/features/home/widgets/popup_offer_dialog.dart';
import 'package:triumph_hotels/services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    
    // Fetch hotels from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context, listen: false).fetchHotels();
      Provider.of<GlobalNotificationProvider>(context, listen: false).fetchNotifications(silent: true);
      _checkAndShowPopup();
      
      // Initialize global push notifications (registers token with backend)
      FCMService().initializeGlobalPush();
    });
  }

  void _checkAndShowPopup() async {
    final offer = await PopupApiService().getActivePopup();
    if (offer != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PopupOfferDialog(offer: offer),
      );
    }
  }

  List<HotelModel> _getFilteredHotels(List<HotelModel> allHotels) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return allHotels;
    
    return allHotels.where((hotel) {
      return hotel.name.toLowerCase().contains(query) == true ||
          hotel.address.toLowerCase().contains(query) == true ||
          hotel.brief.toLowerCase().contains(query) == true;
    }).toList();
  }

  void _filterHotels(String query) {
    setState(() {}); // Just trigger rebuild to apply filter in _getFilteredHotels
  }

  @override
  void dispose() {

    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 5 : 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              size: isSmallScreen ? 18 : isTablet ? 22 : 24,
            ),
            SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: isSmallScreen ? 10 : isTablet ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          AppImages.logo1,
          height: isSmallScreen ? 45 : isTablet ? 55 : 65,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.hotel, color: AppColors.primary, size: isSmallScreen ? 45 : isTablet ? 55 : 65);
          },
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: IconThemeData(color: AppColors.primary),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ),
        actions: [
          Consumer<GlobalNotificationProvider>(
            builder: (context, provider, child) {
              final count = provider.unreadCount;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GlobalNotificationsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      if (count > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: CustomScrollView(
        controller: _scrollController,
        cacheExtent: 300,
        slivers: [
          // Professional Header Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24, 
                vertical: isSmallScreen ? 24 : 32
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                        ),
                        child: Icon(Icons.waving_hand, color: AppColors.primary, size: isSmallScreen ? 20 : isTablet ? 28 : 32),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.welcome,
                              style: GoogleFonts.roboto(
                                color: AppColors.textSecondary,
                                fontSize: isSmallScreen ? 12 : isTablet ? 16 : 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              localizations.discoverYourPerfectStay,
                              style: GoogleFonts.roboto(
                                color: AppColors.primary,
                                fontSize: isSmallScreen ? 18 : isTablet ? 28 : 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fade().slideX(begin: -0.2),

                  SizedBox(height: isSmallScreen ? 16 : 24),



                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16, 
                      vertical: isSmallScreen ? 8 : 12
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: isSmallScreen ? 6 : 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterHotels,
                      decoration: InputDecoration(
                        hintText: localizations.search,
                        hintStyle: GoogleFonts.roboto(
                          color: Theme.of(context).hintColor,
                          fontSize: isSmallScreen ? 12 : isTablet ? 16 : 18,
                        ),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor, size: isSmallScreen ? 14 : isTablet ? 20 : 24),
                        suffixIcon: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                          margin: EdgeInsets.all(isSmallScreen ? 2 : 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
                          ),
                          child: Icon(Icons.tune, color: AppColors.primary, size: isSmallScreen ? 10 : isTablet ? 16 : 20),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                      ),
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),


                ],
              ),
            ),
          ),

          // Hotels Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24, 
                vertical: isSmallScreen ? 16 : 24
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.featuredHotels,
                    style: GoogleFonts.greatVibes(
                      color: AppColors.primary,
                      fontSize: isSmallScreen ? 24 : isTablet ? 32 : 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: isSmallScreen ? 12 : 16,
                  //     vertical: isSmallScreen ? 6 : 8
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primary.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       // Text(
                  //       //   'View All',
                  //       //   style: GoogleFonts.roboto(
                  //       //     color: AppColors.primary,
                  //       //     fontSize: isSmallScreen ? 12 : isTablet ? 16 : 18,
                  //       //     fontWeight: FontWeight.w600,
                  //       //   ),
                  //       // ),
                  //       SizedBox(width: isSmallScreen ? 3 : 4),
                  //       Icon(Icons.arrow_forward, color: AppColors.primary, size: isSmallScreen ? 12 : isTablet ? 16 : 20),
                  //     ],
                  //   ),
                  // ),
                ],
              ).animate().fade(delay: 600.ms).slideX(begin: -0.1),
            ),
          ),

          // Hotels List or No Results
          Consumer<HotelProvider>(
            builder: (context, hotelProvider, child) {
              if (hotelProvider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (hotelProvider.errorMessage != null) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off_outlined, size: 64, color: Colors.redAccent),
                            const SizedBox(height: 16),
                            Text(
                              localizations.error,
                              style: GoogleFonts.roboto(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hotelProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () => hotelProvider.fetchHotels(),
                                icon: const Icon(Icons.refresh),
                                label: Text(localizations.retry),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              final filteredHotels = _getFilteredHotels(hotelProvider.hotels);

              if (filteredHotels.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context).hintColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations.noHotelsFound,
                                style: GoogleFonts.roboto(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.tryAdjustingSearch,
                                style: GoogleFonts.roboto(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _filterHotels('');
                                },
                                child: Text(
                                  localizations.clearSearch,
                                  style: GoogleFonts.roboto(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                    decorationThickness: 2,
                                  ),
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

              return SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsivePadding(context,
                        smallPadding: 16, mediumPadding: 24, largePadding: 32),
                    vertical: 0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 1 : isTablet ? 2 : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: isSmallScreen ? 380 : 420,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final hotel = filteredHotels[index];
                      return HotelCard(hotel: hotel, index: index);
                    },
                    childCount: filteredHotels.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: isSmallScreen ? 58 : isTablet ? 76 : 88,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSmallScreen ? 20 : 30),
            topRight: Radius.circular(isSmallScreen ? 20 : 30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isSmallScreen ? 12 : 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: isSmallScreen ? 5 : 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.home,
                label: localizations.home,
                isSelected: true,
                onTap: () {},
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              _buildBottomNavItem(
                icon: Icons.explore_outlined,
                label: localizations.experience,
                isSelected: false,
                onTap: () {
                  final guestProvider = context.read<GuestPortalProvider>();
                  if (guestProvider.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuestPortalHomeScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuestPortalLoginScreen()),
                    );
                  }
                },
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              _buildBottomNavItem(
                icon: Icons.person,
                label: localizations.profile,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}