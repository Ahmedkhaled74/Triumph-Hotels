import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:triumph_hotels/core/widgets/custom_drawer.dart';
import 'package:triumph_hotels/data/mock_hotels.dart';
import 'package:triumph_hotels/features/home/widgets/hotel_card.dart';
import 'package:triumph_hotels/features/profile/profile_screen.dart';
import 'package:triumph_hotels/models/hotel_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final TextEditingController _searchController = TextEditingController();
  List<HotelModel> _filteredHotels = [];
  List<HotelModel> _allHotels = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _allHotels = mockHotels;
    _filteredHotels = mockHotels;
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final threshold = 100;
      if (_scrollController.offset > threshold && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= threshold && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    }
  }

  void _filterHotels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHotels = _allHotels;
      } else {
        _filteredHotels = _allHotels.where((hotel) {
          return hotel.name.toLowerCase().contains(query.toLowerCase()) ||
                 hotel.address.toLowerCase().contains(query.toLowerCase()) ||
                 hotel.brief.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          AppImages.logo1,
          height: 35,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.hotel, color: AppColors.primary, size: 35);
          },
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: IconThemeData(color: AppColors.primary),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: AppColors.primary, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Professional Header Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.waving_hand, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: GoogleFonts.roboto(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Discover Your Perfect Stay',
                              style: GoogleFonts.roboto(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fade().slideX(begin: -0.2),

                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterHotels,
                      decoration: InputDecoration(
                        hintText: 'Search hotels, destinations...',
                        hintStyle: GoogleFonts.roboto(
                          color: Theme.of(context).hintColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor, size: 20),
                        suffixIcon: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune, color: AppColors.primary, size: 16),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  // Stats Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.hotel,
                          title: '3',
                          subtitle: 'Hotels',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.location_city,
                          title: '2',
                          subtitle: 'Cities',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          title: '4.8',
                          subtitle: 'Rating',
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),

          // Hotels Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Hotels',
                    style: GoogleFonts.greatVibes(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ],
              ).animate().fade(delay: 600.ms).slideX(begin: -0.1),
            ),
          ),

          // Hotels List or No Results
          if (_filteredHotels.isEmpty)
            SliverToBoxAdapter(
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
                            'No Hotels Found',
                            style: GoogleFonts.roboto(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: GoogleFonts.roboto(
                              color: Theme.of(context).hintColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _filterHotels('');
                              },
                              child: Text(
                                'Clear Search',
                                style: GoogleFonts.roboto(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final hotel = _filteredHotels[index];
                    return HotelCard(hotel: hotel, index: index);
                  },
                  childCount: _filteredHotels.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: true,
                onTap: () {},
              ),
              _buildBottomNavItem(
                icon: Icons.person,
                label: 'Profile',
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.roboto(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.roboto(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
