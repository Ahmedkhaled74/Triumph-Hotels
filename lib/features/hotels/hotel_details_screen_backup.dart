// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:triumph_hotels/core/constants/app_strings.dart';
// import 'package:triumph_hotels/core/constants/app_colors.dart';
// import 'package:triumph_hotels/core/widgets/section_title.dart';
// import 'package:triumph_hotels/models/hotel_model.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:triumph_hotels/core/widgets/auto_scroll_list_view.dart';
// import 'package:triumph_hotels/models/room_model.dart';
// import 'package:triumph_hotels/models/restaurant_model.dart';
// import 'package:provider/provider.dart';
// import 'package:triumph_hotels/core/providers/theme_provider.dart';
// import 'full_description_screen.dart';
// import 'package:triumph_hotels/features/hotels/gallery_screen.dart';
// import 'package:triumph_hotels/features/hotels/room_details_screen.dart';
// import 'package:triumph_hotels/features/hotels/restaurant_detail_screen.dart';
//
// import '../services/all_services_screen.dart';
//
// class HotelDetailsScreen extends StatefulWidget {
//   final HotelModel hotel;
//
//   const HotelDetailsScreen({super.key, required this.hotel});
//
//   @override
//   State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
// }
//
// class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
//   late PageController _pageController;
//   bool _showLogo = false;
//   int _currentImageIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _pageController.addListener(_onPageChange);
//   }
//
//   @override
//   void dispose() {
//     _pageController.removeListener(_onPageChange);
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _onPageChange() {
//     if (_pageController.hasClients) {
//       final newIndex = _pageController.page?.round() ?? 0;
//       if (newIndex != _currentImageIndex) {
//         setState(() => _currentImageIndex = newIndex);
//         // Show logo when user scrolls to any image beyond the first one
//         setState(() => _showLogo = newIndex > 0);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Full Screen Image Gallery
//           PageView.builder(
//             controller: _pageController,
//             scrollDirection: Axis.horizontal,
//             itemCount: widget.hotel.gallery.length + 1, // +1 for main image
//             itemBuilder: (context, index) {
//               String imagePath = index == 0
//                   ? widget.hotel.imageUrl
//                   : widget.hotel.gallery[index - 1];
//
//               return Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.asset(
//                     imagePath,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
//                   ),
//
//                   // Gradient Overlay for readability and elegance
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.2),
//                           Colors.black.withOpacity(0.8),
//                         ],
//                         stops: const [0.5, 0.7, 1.0],
//                       ),
//                     ),
//                   ),
//
//                   // Hotel Logo (Large, in header)
//                   Positioned(
//                     top: 50,
//                     right: 20,
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           // Professional main shadow
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.25),
//                             blurRadius: 15,
//                             offset: const Offset(0, 6),
//                             spreadRadius: 0,
//                           ),
//                           // Subtle depth shadow
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.12),
//                             blurRadius: 8,
//                             offset: const Offset(0, 3),
//                             spreadRadius: 0,
//                           ),
//                           // Soft ambient shadow
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.08),
//                             blurRadius: 20,
//                             offset: const Offset(0, 2),
//                             spreadRadius: -5,
//                           ),
//                         ],
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.8),
//                           width: 1,
//                         ),
//                       ),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: RadialGradient(
//                             center: Alignment(-0.3, -0.3),
//                             radius: 0.8,
//                             colors: [
//                               Colors.white.withOpacity(0.9),
//                               Colors.white.withOpacity(0.3),
//                             ],
//                           ),
//                         ),
//                         child: Image.asset(
//                           widget.hotel.logoUrl,
//                           width: 50,
//                           height: 50,
//                           fit: BoxFit.contain,
//                         ),
//                       ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
//                     ),
//
//                     // Content Overlay (Name & Location)
//                     Positioned(
//                       bottom: 30,
//                       left: 20,
//                       right: 20,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Logo Badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(color: Colors.white.withOpacity(0.3)),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                   const Icon(Icons.star, color: AppColors.primary, size: 16),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     '5-Star Luxury Hotel',
//                                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                                       color: Colors.white,
//                                       letterSpacing: 1,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ).animate().fade().slideX(),
//
//                           const SizedBox(height: 12),
//
//                           // Hotel Name
//                           Text(
//                             widget.hotel.name,
//                             style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                               color: Colors.white,
//                               fontFamily: 'Great Vibes',
//                               fontSize: 42, // Larger and more elegant
//                               height: 1.1,
//                             ),
//                           ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
//
//                           const SizedBox(height: 8),
//
//                           // Location Row
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on, color: AppColors.primary, size: 18),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   widget.hotel.address.split(',').last.trim(), // Just show city/country for brevity in header
//                                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                     color: Colors.white70,
//                                     fontWeight: FontWeight.w300,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ).animate().fade(delay: 400.ms),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Floating Image Pagination Indicator
//                   Positioned(
//                     bottom: 20,
//                     right: 20,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.2),
//                           width: 0.5,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.collections_outlined,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             '${_currentImageIndex + 1}/${widget.hotel.gallery.length + 1}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//
//           // Custom App Bar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: kToolbarHeight + MediaQuery.of(context).padding.top,
//               padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.7),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                   const Spacer(),
//                   AnimatedOpacity(
//                     duration: const Duration(milliseconds: 300),
//                     opacity: _showLogo ? 1.0 : 0.0,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       child: Image.asset(
//                         widget.hotel.logoUrl,
//                         height: 40,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   const SizedBox(width: 48), // Balance the back button
//                 ],
//               ),
//             ),
//           ),
//
//           // Scrollable Content Below
//           Positioned(
//             bottom: 100, // Above the booking bar
//             left: 0,
//             right: 0,
//             top: MediaQuery.of(context).size.height - 200, // Start from bottom
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).scaffoldBackgroundColor,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(24),
//                   topRight: Radius.circular(24),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                        // 1. Overview Card
//                       _buildSectionCard(
//                         context,
//                         title: AppStrings.description,
//                         icon: Icons.description_outlined,
//                         delay: 100,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Brief description
//                             Text(
//                               widget.hotel.brief,
//                               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                 height: 1.6,
//                                 color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//
//                             // See More button
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => FullDescriptionScreen(hotel: widget.hotel),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       AppColors.primary,
//                                       AppColors.primary.withOpacity(0.8),
//                                     ],
//                                     begin: Alignment.centerLeft,
//                                     end: Alignment.centerRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(25),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: AppColors.primary.withOpacity(0.3),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       'Raed More',
//                                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     const Icon(
//                                       Icons.arrow_forward,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             const Divider(),
//                             const SizedBox(height: 20),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.primary.withOpacity(0.1),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(Icons.place, color: AppColors.primary, size: 20),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     widget.hotel.address,
//                                     style: Theme.of(context).textTheme.bodyLarge,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Add other sections here as needed...
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, -2),
//             ),
//           ],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//           child: Row(
//             children: [
//               // Price Section
//               Expanded(
//                 flex: 2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'From',
//                       style: GoogleFonts.roboto(
//                         color: AppColors.textSecondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     Text(
//                       '\$299',
//                       style: GoogleFonts.roboto(
//                         color: AppColors.primary,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       '/night',
//                       style: GoogleFonts.roboto(
//                         color: AppColors.textSecondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Date & Guests Section
//               // Expanded(
//               //   flex: 3,
//               //   child: Row(
//               //     children: [
//               //       // Check-in/Check-out
//               //       Expanded(
//               //         child: Container(
//               //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               //           decoration: BoxDecoration(
//               //             color: AppColors.primary.withOpacity(0.05),
//               //             borderRadius: BorderRadius.circular(12),
//               //             border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//               //           ),
//               //           child: Column(
//               //             mainAxisSize: MainAxisSize.min,
//               //             children: [
//               //               Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
//               //               const SizedBox(height: 2),
//               //               Text(
//               //                 'Dates',
//               //                 style: GoogleFonts.roboto(
//               //                   color: AppColors.primary,
//               //                   fontSize: 10,
//               //                   fontWeight: FontWeight.w600,
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //         ),
//               //       ),
//               //
//               //       const SizedBox(width: 8),
//               //
//               //       // Guests
//               //       Expanded(
//               //         child: Container(
//               //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               //           decoration: BoxDecoration(
//               //             color: AppColors.primary.withOpacity(0.05),
//               //             borderRadius: BorderRadius.circular(12),
//               //             border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//               //           ),
//               //           child: Column(
//               //             mainAxisSize: MainAxisSize.min,
//               //             children: [
//               //               Icon(Icons.people, color: AppColors.primary, size: 16),
//               //               const SizedBox(height: 2),
//               //               Text(
//               //                 'Guests',
//               //                 style: GoogleFonts.roboto(
//               //                   color: AppColors.primary,
//               //                   fontSize: 10,
//               //                   fontWeight: FontWeight.w600,
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//
//               // Book Now Button
//               Expanded(
//                 flex: 2,
//                 child: Container(
//                   height: 56,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.primary.withOpacity(0.9),
//                         AppColors.primary,
//                         AppColors.secondary,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       stops: const [0.0, 0.5, 1.0],
//                     ),
//                     borderRadius: BorderRadius.circular(28),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.primary.withOpacity(0.3),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                       BoxShadow(
//                         color: AppColors.primary.withOpacity(0.2),
//                         blurRadius: 40,
//                         offset: const Offset(0, 16),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(28),
//                       onTap: () {
//                         // Handle booking
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.calendar_today,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               'Book Now',
//                               style: GoogleFonts.roboto(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w700,
//                                 letterSpacing: 1.2,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ).animate().scale(delay: 200.ms, duration: 600.ms).then().shimmer(
//                     delay: 800.ms,
//                     duration: 2000.ms,
//                     color: Colors.white.withOpacity(0.3),
//                   ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _buildRoomCard(BuildContext context, RoomModel room) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RoomDetailsScreen(room: room),
//           ),
//         );
//       },
//       child: Container(
//         width: 320,
//         margin: const EdgeInsets.only(right: 16, bottom: 5, top: 5),
//         height: 280,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: Theme.of(context).dividerColor.withOpacity(0.2),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Enhanced Image Section
//             Expanded(
//               flex: 3,
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                 child: PhysicalModel(
//                   elevation: 8,
//                   color: Colors.transparent,
//                   shadowColor: Colors.black.withOpacity(0.2),
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   shape: BoxShape.rectangle,
//                   child: Stack(
//                     children: [
//                     // Room Image
//                     Image.asset(
//                       'assets/images/plaza/${room.imageUrl}',
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 AppColors.primary.withOpacity(0.3),
//                                 AppColors.secondary.withOpacity(0.3),
//                               ],
//                             ),
//                           ),
//                           child: const Center(
//                             child: Icon(Icons.bed, color: Colors.white70, size: 40),
//                           ),
//                         );
//                       },
//                     ),
//
//                     // Room Type Badge
//                     Positioned(
//                       top: 12,
//                       left: 12,
//                       child: PhysicalModel(
//                         elevation: 4,
//                         color: Colors.transparent,
//                         shadowColor: Colors.black.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(20),
//                         shape: BoxShape.rectangle,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             room.name.contains('Suite') ? 'Suite' : 'Room',
//                             style: GoogleFonts.roboto(
//                               color: AppColors.primary,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // View Type Badge
//                     Positioned(
//                       top: 12,
//                       right: 12,
//                       child: PhysicalModel(
//                         elevation: 4,
//                         color: Colors.transparent,
//                         shadowColor: Colors.black.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(12),
//                         shape: BoxShape.rectangle,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(Icons.visibility, color: Colors.white, size: 12),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'City View',
//                                 style: GoogleFonts.roboto(
//                                   color: Colors.white,
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // 360° Tour Button
//                     Positioned(
//                       bottom: 12,
//                       right: 12,
//                       child: PhysicalModel(
//                         elevation: 4,
//                         color: Colors.transparent,
//                         shadowColor: Colors.black.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(20),
//                         shape: BoxShape.rectangle,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Icon(Icons.view_in_ar, color: AppColors.primary, size: 16),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 ),
//               ),
//             ),
//
//             // Enhanced Content Section
//             Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Room Name and Size
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           room.name,
//                           style: GoogleFonts.greatVibes(
//                             color: Theme.of(context).textTheme.titleLarge?.color,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(Icons.square_foot, color: AppColors.textSecondary, size: 14),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${room.size}m²',
//                               style: GoogleFonts.roboto(
//                                 color: AppColors.textSecondary,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Icon(Icons.people, color: AppColors.textSecondary, size: 14),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${room.maxGuests} Guests',
//                               style: GoogleFonts.roboto(
//                                 color: AppColors.textSecondary,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//
//                     // Bed Configuration
//                     // PhysicalModel(
//                     //   elevation: 2,
//                     //   color: Colors.transparent,
//                     //   shadowColor: Colors.black.withOpacity(0.2),
//                     //   borderRadius: BorderRadius.circular(8),
//                     //   shape: BoxShape.rectangle,
//                     //   child: Container(
//                     //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     //     decoration: BoxDecoration(
//                     //       color: AppColors.primary.withOpacity(0.05),
//                     //       borderRadius: BorderRadius.circular(8),
//                     //       border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//                     //     ),
//                     //     child: Row(
//                     //       mainAxisSize: MainAxisSize.min,
//                     //       children: [
//                     //         Icon(Icons.king_bed, color: AppColors.primary, size: 14),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                     //
//                     // Price and Availability
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '\$${room.price}',
//                               style: GoogleFonts.roboto(
//                                 color: AppColors.primary,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             Text(
//                               '/night',
//                               style: GoogleFonts.roboto(
//                                 color: AppColors.textSecondary,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         // Availability Status
//                         PhysicalModel(
//                           elevation: 2,
//                           color: Colors.transparent,
//                           shadowColor: Colors.black.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                           shape: BoxShape.rectangle,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.green.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.green.withOpacity(0.3)),
//                             ),
//                             child: Text(
//                               'Available',
//                               style: GoogleFonts.roboto(
//                                 color: Colors.green,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
//   }
//
//   Widget _buildRestaurantCard(BuildContext context, RestaurantModel restaurant) {
//       final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//
//       return GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
//             ),
//           );
//         },
//         child: Container(
//           width: 285,
//           margin: const EdgeInsets.only(right: 16, bottom: 5, top: 5),
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Enhanced Image Section
//               Expanded(
//                 flex: 3,
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   child: PhysicalModel(
//                     elevation: 8,
//                     color: Colors.transparent,
//                     shadowColor: Colors.black.withOpacity(0.2),
//                     borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                     shape: BoxShape.rectangle,
//                     child: Stack(
//                       children: [
//                         // Restaurant Image
//                         Hero(
//                           tag: 'restaurant_image_${restaurant.id}',
//                           child: Image.asset(
//                             'assets/images/plaza/${restaurant.imageUrl}',
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: double.infinity,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                     colors: [
//                                       AppColors.primary.withOpacity(0.3),
//                                       AppColors.secondary.withOpacity(0.3),
//                                     ],
//                                   ),
//                                 ),
//                                 child: const Center(
//                                   child: Icon(Icons.restaurant, color: Colors.white70, size: 40),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//
//                         // Cuisine Type Badge
//                         Positioned(
//                           top: 12,
//                           left: 12,
//                           child: PhysicalModel(
//                             elevation: 4,
//                             color: Colors.transparent,
//                             shadowColor: Colors.black.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(20),
//                             shape: BoxShape.rectangle,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 restaurant.cuisine,
//                                 style: GoogleFonts.roboto(
//                                   color: AppColors.primary,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         // Rating Badge
//                         Positioned(
//                           top: 12,
//                           right: 12,
//                           child: PhysicalModel(
//                             elevation: 4,
//                             color: Colors.transparent,
//                             shadowColor: Colors.black.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(12),
//                             shape: BoxShape.rectangle,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.amber.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(Icons.star, color: Colors.white, size: 12),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     '4.5',
//                                     style: GoogleFonts.roboto(
//                                       color: Colors.white,
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Enhanced Content Section
//               Expanded(
//                 flex: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Restaurant Name and Details
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             restaurant.name,
//                             style: GoogleFonts.greatVibes(
//                               color: Theme.of(context).textTheme.titleLarge?.color,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'Open Now',
//                                 style: GoogleFonts.roboto(
//                                   color: AppColors.textSecondary,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'Ground Floor',
//                                 style: GoogleFonts.roboto(
//                                   color: AppColors.textSecondary,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//
//                       // Price Range and Action
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Price Range
//                           // PhysicalModel(
//                           //   elevation: 2,
//                           //   color: Colors.transparent,
//                           //   shadowColor: Colors.black.withOpacity(0.2),
//                           //   borderRadius: BorderRadius.circular(8),
//                           //   shape: BoxShape.rectangle,
//                           //   child: Container(
//                           //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           //     decoration: BoxDecoration(
//                           //       color: AppColors.primary.withOpacity(0.05),
//                           //       borderRadius: BorderRadius.circular(8),
//                           //       border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//                           //     ),
//                           //     child: Text(
//                           //       '\$\$\$',
//                           //       style: GoogleFonts.roboto(
//                           //         color: AppColors.primary,
//                           //         fontSize: 10,
//                           //         fontWeight: FontWeight.w600,
//                           //       ),
//                           //     ),
//                           //   ),
//                           // ),
//
//                           // Reserve Button
//                           PhysicalModel(
//                             elevation: 2,
//                             color: Colors.transparent,
//                             shadowColor: Colors.black.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(8),
//                             shape: BoxShape.rectangle,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 'Reserve',
//                                 style: GoogleFonts.roboto(
//                                   color: Colors.white,
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
//       );
//   }
//
//   Widget _buildServiceCard(BuildContext context, String service) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//     IconData icon = _getServiceIcon(service);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: AppColors.primary,
//               size: 20,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: Text(
//               service,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 fontWeight: FontWeight.w500,
//                 color: Theme.of(context).textTheme.bodyLarge?.color,
//                 fontSize: 11,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
//   }
//
//   IconData _getServiceIcon(String service) {
//     if (service.contains('Wifi')) return Icons.wifi;
//     else if (service.contains('Airport')) return Icons.flight_land;
//     else if (service.contains('ATM')) return Icons.atm;
//     else if (service.contains('Concierge')) return Icons.room_service;
//     else if (service.contains('Parking')) return Icons.local_parking;
//     else if (service.contains('Laundry')) return Icons.local_laundry_service;
//     else if (service.contains('Pool')) return Icons.pool;
//     else if (service.contains('Gym')) return Icons.fitness_center;
//     else if (service.contains('Spa')) return Icons.spa;
//     else if (service.contains('Restaurant')) return Icons.restaurant;
//     else if (service.contains('Bar')) return Icons.local_bar;
//     else if (service.contains('Pet')) return Icons.pets;
//     else return Icons.star;
//   }
//
//   Widget _buildSectionCard(BuildContext context, {
//     required String title,
//     required IconData icon,
//     required Widget child,
//     required int delay,
//     bool isFullWidth = false,
//     Widget? trailing,
//   }) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 24),
//       padding: const EdgeInsets.symmetric(vertical: 24),
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.04),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(icon, color: AppColors.primary, size: 28),
//                     const SizedBox(width: 12),
//                     Text(
//                       title,
//                       style: GoogleFonts.greatVibes(
//                         color: AppColors.primary,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (trailing != null) trailing,
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           isFullWidth ? child : Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: child,
//           ),
//         ],
//       ),
//     ).animate().fade(duration: 600.ms, delay: delay.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
//   }
//
//   Widget _buildEventItem(BuildContext context, String title, String subtitle, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
//           child: Icon(icon, color: AppColors.primary, size: 24),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
//               Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
//             ],
//           ),
//         ),
//         const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
//       ],
//     );
//   }
//
//   Widget _buildContactButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           PhysicalModel(
//             elevation: 4,
//             color: Colors.transparent,
//             shadowColor: Colors.black.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(16),
//             shape: BoxShape.rectangle,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//               ),
//               child: Icon(icon, color: AppColors.primary, size: 28),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: GoogleFonts.roboto(
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSocialButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           PhysicalModel(
//             elevation: 4,
//             color: Colors.transparent,
//             shadowColor: Colors.black.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(16),
//             shape: BoxShape.rectangle,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     AppColors.primary.withOpacity(0.15),
//                     AppColors.secondary.withOpacity(0.15),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//               ),
//               child: Icon(icon, color: AppColors.primary, size: 24),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: GoogleFonts.roboto(
//               fontWeight: FontWeight.w600,
//               color: Theme.of(context).textTheme.bodyMedium?.color,
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMeetingRoomCard(BuildContext context, RoomModel room) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RoomDetailsScreen(room: room),
//           ),
//         );
//       },
//       child: Container(
//         width: 320,
//         margin: const EdgeInsets.only(right: 16, bottom: 5, top: 5),
//         height: 280,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: Theme.of(context).dividerColor.withOpacity(0.2),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image Section
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                 child: PhysicalModel(
//                   elevation: 8,
//                   color: Colors.transparent,
//                   shadowColor: Colors.black.withOpacity(0.2),
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   shape: BoxShape.rectangle,
//                   child: Stack(
//                     children: [
//                       // Room Image
//                       Image.asset(
//                         'assets/images/plaza/${room.imageUrl}',
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   AppColors.primary.withOpacity(0.3),
//                                   AppColors.secondary.withOpacity(0.3),
//                                 ],
//                               ),
//                             ),
//                             child: const Center(
//                               child: Icon(Icons.bed, color: Colors.white70, size: 40),
//                             ),
//                           );
//                         },
//                       ),
//
//                       // Meeting Room Type Badge
//                       Positioned(
//                         top: 12,
//                         left: 12,
//                         child: PhysicalModel(
//                           elevation: 4,
//                           color: Colors.transparent,
//                           shadowColor: Colors.black.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(20),
//                           shape: BoxShape.rectangle,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.9),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               'Meeting Room',
//                               style: GoogleFonts.roboto(
//                                 color: AppColors.primary,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       // Capacity Badge
//                       Positioned(
//                         top: 12,
//                         right: 12,
//                         child: PhysicalModel(
//                           elevation: 4,
//                           color: Colors.transparent,
//                           shadowColor: Colors.black.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(12),
//                           shape: BoxShape.rectangle,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: AppColors.primary.withOpacity(0.9),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(Icons.groups, color: Colors.white, size: 12),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   '${room.maxGuests} People',
//                                   style: GoogleFonts.roboto(
//                                     color: Colors.white,
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Content Section directly under image (no gap)
//             Container(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Room Name and Size
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         room.name,
//                         style: GoogleFonts.greatVibes(
//                           color: Theme.of(context).textTheme.titleLarge?.color,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(Icons.square_foot, color: AppColors.textSecondary, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${room.size}m²',
//                             style: GoogleFonts.roboto(
//                               color: AppColors.textSecondary,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Icon(Icons.people, color: AppColors.textSecondary, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${room.maxGuests} Guests',
//                             style: GoogleFonts.roboto(
//                               color: AppColors.textSecondary,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 28),
//
//                   // Price and Availability
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '\$${room.price}',
//                             style: GoogleFonts.roboto(
//                               color: AppColors.primary,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           Text(
//                             '/night',
//                             style: GoogleFonts.roboto(
//                               color: AppColors.textSecondary,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       // Availability Status
//                       PhysicalModel(
//                         elevation: 2,
//                         color: Colors.transparent,
//                         shadowColor: Colors.black.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                         shape: BoxShape.rectangle,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.green.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.green.withOpacity(0.3)),
//                           ),
//                           child: Text(
//                             'Available',
//                             style: GoogleFonts.roboto(
//                               color: Colors.green,
//                               fontSize: 9,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
//   }
// }
