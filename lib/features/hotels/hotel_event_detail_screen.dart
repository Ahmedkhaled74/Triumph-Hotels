import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/models/event_model.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import '../booking/booking_screen.dart';

class HotelEventDetailScreen extends StatefulWidget {
  final String hotelSlug;
  final EventModel event;

  const HotelEventDetailScreen({
    super.key,
    required this.hotelSlug,
    required this.event,
  });

  @override
  State<HotelEventDetailScreen> createState() => _HotelEventDetailScreenState();
}

class _HotelEventDetailScreenState extends State<HotelEventDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch fresh details if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context, listen: false).fetchEventDetail(widget.hotelSlug, widget.event.id);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final shouldShowTitle = offset > 300;
      if (shouldShowTitle != _showTitle && mounted) {
        setState(() {
          _showTitle = shouldShowTitle;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<HotelProvider>(
        builder: (providerContext, provider, child) {
          final event = provider.getDetailedEvent(widget.event.id) ?? widget.event;
          
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Gallery
              SliverAppBar(
                expandedHeight: ResponsiveUtils.getResponsiveHeight(context, 0.45),
                pinned: true,
                elevation: 0,
                backgroundColor: _showTitle ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _showTitle ? Colors.transparent : Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: _showTitle ? Theme.of(context).iconTheme.color : Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'event_image_${event.id}',
                        child: (event.image.startsWith('http'))
                          ? CachedNetworkImage(
                              imageUrl: event.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildImagePlaceholder(isLoading: true),
                              errorWidget: (context, url, error) => _buildImagePlaceholder(),
                            )
                          : Image.asset(
                              'assets/images/plaza/${event.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            ),
                      ),
                      
                      // Gradient Overlays
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      
                      // Melting Background Gradient
                      Positioned(
                        bottom: -1,
                        left: 0,
                        right: 0,
                        height: ResponsiveUtils.getResponsiveHeight(context, 0.15),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsivePadding(context, smallPadding: 20, mediumPadding: 32, largePadding: 48),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Text(
                        event.name,
                        style: GoogleFonts.greatVibes(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 42, mediumSize: 56, largeSize: 64),
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),

                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.015)),
                      
                      // Venue Info
                      Row(
                        children: [
                          Icon(
                            Icons.location_on, 
                            color: AppColors.primary, 
                            size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 18, mediumSize: 22)
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.venue,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18),
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),

                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),

                      // Quick Info Grid
                      Row(
                        children: [
                          Expanded(child: _buildQuickInfo(context, Icons.calendar_today, "Starts", event.startDate, isDark)),
                          SizedBox(width: ResponsiveUtils.getResponsivePadding(context, smallPadding: 12)),
                          Expanded(child: _buildQuickInfo(context, Icons.event, "Ends", event.endDate, isDark)),
                        ],
                      ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),

                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.04)),

                      // Description Section (Accordion Style)
                      _buildExpansionTile(
                        context,
                        title: localizations.description,
                        initiallyExpanded: true,
                        isDark: isDark,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20)),
                            child: Text(
                              event.description,
                              style: TextStyle(
                                height: 1.7,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17),
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.05)),
                      
                      // Book Event Button
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveHeight(context, 0.05)),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(
                                  bookingType: BookingType.event,
                                  itemName: event.name,
                                  itemDescription: event.shortDescription,
                                  itemImage: event.image,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 18)
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 16)
                              )
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            localizations.bookEvent,
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20), 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(child: SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.08))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickInfo(BuildContext context, IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, {required String title, required List<Widget> children, bool initiallyExpanded = false, required bool isDark}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: initiallyExpanded,
        trailing: Icon(Icons.add, color: isDark ? Colors.white70 : Colors.black54),
        collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
        iconColor: AppColors.primary,
        children: children,
      ),
    );
  }

  Widget _buildImagePlaceholder({bool isLoading = false}) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: isLoading 
          ? const CircularProgressIndicator(color: AppColors.primary)
          : const Icon(Icons.event, size: 64, color: Colors.grey),
      ),
    );
  }
}
