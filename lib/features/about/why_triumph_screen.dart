import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';

class WhyTriumphScreen extends StatefulWidget {
  const WhyTriumphScreen({super.key});

  @override
  State<WhyTriumphScreen> createState() => _WhyTriumphScreenState();
}

class _WhyTriumphScreenState extends State<WhyTriumphScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isAppBarCollapsed = false;
  bool _isPromiseExpanded = false;
  
  // Independent expansion states for properties
  final Map<int, bool> _propertyDescExpanded = {};
  final Map<int, bool> _propertyLocsExpanded = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.hasClients) {
      final isCollapsed = _scrollController.offset > 150;
      if (isCollapsed != _isAppBarCollapsed) {
        setState(() {
          _isAppBarCollapsed = isCollapsed;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    
    // Design Tokens matching the HTML mockup
    final Color gold = const Color(0xFFD4AF37); // Classic Gold
    final Color goldDeep = const Color(0xFFB8941F);
    final Color goldLight = const Color(0xFFF4E4BC);
    
    final Color backgroundTertiary = isDark ? const Color(0xFF121212) : const Color(0xFFF0F0F0);
    final Color backgroundPrimary = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color backgroundSecondary = isDark ? const Color(0xFF252525) : const Color(0xFFF8F8F8);
    final Color borderTertiary = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1A1206);
    final Color textSecondary = isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF4A3728);

    return Scaffold(
      backgroundColor: backgroundTertiary,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero Section (SliverAppBar) ──
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveHeight(context, 0.3),
            pinned: true,
            elevation: 0,
            backgroundColor: _isAppBarCollapsed ? const Color(0xFF1A1208) : Colors.transparent,
            leading: const BackButton(color: Colors.white),
            centerTitle: true,
            title: _isAppBarCollapsed
                ? Text(
                    localizations.whyTriumph,
                    style: GoogleFonts.roboto(
                      color: goldLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Base Gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1208), Color(0xFF3D2B0C), Color(0xFF1A1208)],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  
                  // Texture Overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: TexturePainter(color: gold),
                      ),
                    ),
                  ),
                  
                  // Subtle Radial Glow
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.4, 0.2),
                        radius: 1.2,
                        colors: [gold.withOpacity(0.18), Colors.transparent],
                      ),
                    ),
                  ),
                  
                  
                  // Hero Content
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, ResponsiveUtils.getResponsiveHeight(context, 0.03)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: gold.withOpacity(0.5), width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.rotate(
                                  angle: 0.785, // 45 degrees
                                  child: Container(width: 6, height: 6, color: gold),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "TRIUMPH HOTELS",
                                  style: GoogleFonts.roboto(
                                    color: goldLight,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 9, mediumSize: 10, largeSize: 11),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Transform.rotate(
                                  angle: 0.785,
                                  child: Container(width: 6, height: 6, color: gold),
                                ),
                              ],
                            ),
                          ).animate().fade(duration: 400.ms).slideX(begin: -0.1, end: 0),
                          
                          const SizedBox(height: 10),
                          
                          Text(
                            localizations.whyTriumph,
                            style: GoogleFonts.greatVibes(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 32, mediumSize: 38, largeSize: 44),
                              height: 1.1,
                              shadows: [const Shadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 2))],
                            ),
                          ).animate().fade(delay: 100.ms, duration: 500.ms),
                          
                          const SizedBox(height: 6),
                          
                          Text(
                            localizations.discoverExcellenceInHospitality.toUpperCase(),
                            style: GoogleFonts.roboto(
                              color: goldLight.withOpacity(0.8),
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 10, mediumSize: 11, largeSize: 12),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.5,
                            ),
                          ).animate().fade(delay: 200.ms, duration: 500.ms),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content Sections ──
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildOurPromiseSection(context, isDark, gold, goldDeep, goldLight, backgroundPrimary, backgroundSecondary, borderTertiary, textPrimary, textSecondary),
                _buildOurPropertiesSection(context, isDark, gold, goldDeep, goldLight, backgroundPrimary, backgroundSecondary, borderTertiary, textPrimary, textSecondary),
                _buildCTASection(context, isDark, gold, goldDeep, backgroundPrimary, textPrimary, textSecondary),
                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String pillText, String titleText, Color gold, Color goldLight, Color textPrimary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF252525) : const Color(0xFFF8F8F8),
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color(0xFFB8941F), gold, goldLight]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pillText.toUpperCase(),
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titleText,
            textAlign: TextAlign.center,
            style: GoogleFonts.greatVibes(color: textPrimary, fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 26, mediumSize: 28, largeSize: 32), height: 1.1),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 1, width: 36, color: gold.withOpacity(0.5)),
              const SizedBox(width: 8),
              Transform.rotate(angle: 0.785, child: Container(width: 8, height: 8, color: const Color(0xFFB8941F))),
              const SizedBox(width: 8),
              Container(height: 1, width: 36, color: gold.withOpacity(0.5)),
              const SizedBox(width: 8),
              Container(width: 4, height: 4, decoration: BoxDecoration(color: gold.withOpacity(0.4), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Container(height: 1, width: 36, color: gold.withOpacity(0.5)),
              const SizedBox(width: 8),
              Transform.rotate(angle: 0.785, child: Container(width: 8, height: 8, color: const Color(0xFFB8941F))),
              const SizedBox(width: 8),
              Container(height: 1, width: 36, color: gold.withOpacity(0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOurPromiseSection(BuildContext context, bool isDark, Color gold, Color goldDeep, Color goldLight, Color backgroundPrimary, Color backgroundSecondary, Color borderTertiary, Color textPrimary, Color textSecondary) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderTertiary, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSectionHeader(context, localizations.ourPromise, "Where Luxury Meets Comfortability", gold, goldLight, textPrimary),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "\u201C",
                  style: GoogleFonts.playfairDisplay(color: gold.withOpacity(0.4), fontSize: 56, height: 0.6),
                ),
                const SizedBox(height: 6),
                Text(
                  _isPromiseExpanded ? localizations.ourPromiseFullDescription : localizations.ourPromiseShortDescription,
                  style: GoogleFonts.playfairDisplay(
                    color: textSecondary,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13, largeSize: 14),
                    fontStyle: FontStyle.italic,
                    height: 1.75,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(() => _isPromiseExpanded = !_isPromiseExpanded),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isPromiseExpanded ? localizations.readLess : localizations.readMore,
                        style: GoogleFonts.roboto(color: const Color(0xFFB8941F), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isPromiseExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFFB8941F),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildPillarItem(context, isDark, gold, goldDeep, goldLight, Icons.support_agent, "Exceptional\nService", textSecondary),
                const SizedBox(width: 10),
                _buildPillarItem(context, isDark, gold, goldDeep, goldLight, Icons.restaurant, "World-Class\nDining", textSecondary),
                const SizedBox(width: 10),
                _buildPillarItem(context, isDark, gold, goldDeep, goldLight, Icons.auto_awesome, "Unforgettable\nExperience", textSecondary),
              ],
            ),
          ),
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, gold, goldLight, gold, Colors.transparent]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarItem(BuildContext context, bool isDark, Color gold, Color goldDeep, Color goldLight, IconData icon, String label, Color textSecondary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252525) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [goldDeep, gold, goldLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: textSecondary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOurPropertiesSection(BuildContext context, bool isDark, Color gold, Color goldDeep, Color goldLight, Color backgroundPrimary, Color backgroundSecondary, Color borderTertiary, Color textPrimary, Color textSecondary) {
    final localizations = AppLocalizations.of(context)!;
    final hotels = [
      {
        'name': localizations.triumphLuxuryHotel,
        'description': localizations.triumphLuxuryHotelDescription,
        'icon': Icons.location_on_rounded,
        'locations': [
          localizations.minutesFrom5AShoppingPlaza,
          localizations.minutesFromCairoFestivalCityMall,
        ],
        'extra_desc': " Our rooftop infinity pool, award-winning spa, and curated art collection make every stay a cultural immersion.",
        'extra_locs': [localizations.minutesFromCairoInternationalAirport, localizations.minutesFromDowntownDistrict],
      },
      {
        'name': localizations.triumphPlazaHotel,
        'description': localizations.triumphPlazaHotelDescription,
        'icon': Icons.home_work_rounded,
        'locations': [
          localizations.minutesFromCityStarsMall,
          localizations.minutesFromCairoIntlAirportPlaza,
        ],
        'extra_desc': " The hotel's signature restaurant, overseen by a Michelin-trained chef, offers a culinary journey through Mediterranean and Egyptian flavors.",
        'extra_locs': [localizations.minutesFromCICC, localizations.minutesFromDowntownCairo],
      },
      {
        'name': localizations.triumphWhiteSands,
        'description': localizations.triumphWhiteSandsDescription,
        'icon': Icons.beach_access_rounded,
        'locations': [
          localizations.directAccessToElGharamBeach,
          localizations.minuteFromElCornicheRoad,
        ],
        'extra_desc': " Our private beach pavilions, sunset cocktail lounge, and water sports center promise a coastal holiday like no other.",
        'extra_locs': [localizations.minutesFromMarsaMatrouh, localizations.minutesFromCleopatraBeach],
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderTertiary, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSectionHeader(context, localizations.ourProperties, "Our Signature Properties", gold, goldLight, textPrimary),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                _buildRopeSegment(18, gold, goldLight),
                ...List.generate(hotels.length, (index) {
                  final hotel = hotels[index];
                  return Column(
                    children: [
                      _buildRopeKnot(gold, goldLight),
                      _buildBookPageCard(context, hotel, index, isDark, gold, goldDeep, goldLight, backgroundPrimary, backgroundSecondary, borderTertiary, textPrimary, textSecondary),
                      if (index < hotels.length - 1) _buildRopeSegment(36, gold, goldLight),
                    ],
                  );
                }),
                _buildRopeSegment(18, gold, goldLight),
              ],
            ),
          ),
          
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, gold, goldLight, gold, Colors.transparent]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRopeSegment(double height, Color gold, Color goldLight) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFF3D2B1F), gold, goldLight, gold, const Color(0xFF3D2B1F)],
        ),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2, offset: const Offset(1, 0))],
      ),
    );
  }

  Widget _buildRopeKnot(Color gold, Color goldLight) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(center: const Alignment(-0.2, -0.3), colors: [goldLight, gold, const Color(0xFF8B6914)]),
        border: Border.all(color: goldLight.withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEAD89C).withOpacity(0.6),
            border: Border.all(color: gold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBookPageCard(BuildContext context, Map<String, dynamic> hotel, int index, bool isDark, Color gold, Color goldDeep, Color goldLight, Color backgroundPrimary, Color backgroundSecondary, Color borderTertiary, Color textPrimary, Color textSecondary) {
    final double rotation = (index % 3 == 0) ? -0.012 : (index % 3 == 1) ? 0.010 : -0.008;
    final bool descExpanded = _propertyDescExpanded[index] ?? false;
    final bool locsExpanded = _propertyLocsExpanded[index] ?? false;
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundPrimary,
          border: Border.all(color: gold.withOpacity(0.4), width: 0.5),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(2, 4))],
        ),
        child: Column(
          children: [
            // Binding
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: backgroundSecondary,
                border: Border(bottom: BorderSide(color: gold.withOpacity(0.3), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBindingHole(gold, backgroundPrimary),
                  const SizedBox(width: 14),
                  Row(children: List.generate(6, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 1.5), width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: gold.withOpacity(0.35))))),
                  const SizedBox(width: 14),
                  _buildBindingHole(gold, backgroundPrimary),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: gold.withOpacity(0.4), width: 0.5),
                        ),
                        child: Icon(hotel['icon'] as IconData, color: gold, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel['name'] as String,
                              style: GoogleFonts.caveat(color: textPrimary, fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 22, mediumSize: 24, largeSize: 26), fontWeight: FontWeight.w700, height: 1.1),
                            ),
                            Container(
                              height: 2, width: double.infinity, margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [gold, gold.withOpacity(0.15), Colors.transparent]),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Ruled description
                  Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: RuledPainter(color: gold.withOpacity(0.15)))),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          descExpanded ? ((hotel['description'] as String) + (hotel['extra_desc'] as String)) : (hotel['description'] as String),
                          style: GoogleFonts.caveat(color: textSecondary, fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 15, mediumSize: 16, largeSize: 17), fontWeight: FontWeight.w500, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                  
                  GestureDetector(
                    onTap: () => setState(() => _propertyDescExpanded[index] = !descExpanded),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.08),
                        border: Border.all(color: gold.withOpacity(0.3), width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(descExpanded ? "Show less" : "Show more", style: GoogleFonts.caveat(color: gold, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          Icon(descExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: gold, size: 13),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, gold.withOpacity(0.4), gold.withOpacity(0.4), Colors.transparent]))),
                  const SizedBox(height: 12),
                  
                  // Locations
                  Row(
                    children: [
                      Icon(Icons.location_on, color: gold, size: 14),
                      const SizedBox(width: 6),
                      Text("Prime Locations", style: GoogleFonts.caveat(color: gold, fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  ...((locsExpanded ? [...(hotel['locations'] as List), ...(hotel['extra_locs'] as List)] : (hotel['locations'] as List)).map((loc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(margin: const EdgeInsets.only(top: 7), width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: gold)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(loc.toString(), style: GoogleFonts.caveat(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500, height: 1.3))),
                      ],
                    ),
                  ))),
                  
                  GestureDetector(
                    onTap: () => setState(() => _propertyLocsExpanded[index] = !locsExpanded),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.08),
                        border: Border.all(color: gold.withOpacity(0.3), width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(locsExpanded ? "Show less" : "Show more", style: GoogleFonts.caveat(color: gold, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          Icon(locsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: gold, size: 13),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: gold.withOpacity(0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text("\u2014 ${index + 1} \u2014", style: GoogleFonts.caveat(color: textPrimary.withOpacity(0.3), fontSize: 14, fontStyle: FontStyle.italic)),
                      ),
                      Expanded(child: Container(height: 1, color: gold.withOpacity(0.2))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBindingHole(Color gold, Color background) {
    return Container(
      width: 13, height: 13,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background, border: Border.all(color: const Color(0xFFB8941F), width: 2)),
      child: Center(
        child: Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3D2B1F).withOpacity(0.5))),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, bool isDark, Color gold, Color goldDeep, Color backgroundPrimary, Color textPrimary, Color textSecondary) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: gold, size: 40),
          const SizedBox(height: 16),
          Text(
            localizations.readyToExperienceExcellence,
            textAlign: TextAlign.center,
            style: GoogleFonts.greatVibes(color: textPrimary, fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 28, mediumSize: 32, largeSize: 36), height: 1.1),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.callToActionDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: textSecondary, fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 13, largeSize: 14), fontWeight: FontWeight.w300, height: 1.5),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Text(
                localizations.exploreOurHotels,
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TexturePainter extends CustomPainter {
  final Color color;
  TexturePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.15)..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i + 10, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RuledPainter extends CustomPainter {
  final Color color;
  RuledPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    double y = 14;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += 22;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
