import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Booking types enum
enum BookingType { event, restaurant }

class BookingScreen extends StatefulWidget {
  final BookingType bookingType;
  final String? itemName;
  final String? itemDescription;
  final String? itemImage;

  const BookingScreen({
    super.key,
    required this.bookingType,
    this.itemName,
    this.itemDescription,
    this.itemImage,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  
  // Booking details
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guests = 1;
  String _selectedEventType = 'Corporate Event';
  String _selectedOccasion = 'Regular Booking';
  
  // Event types
  final List<String> _eventTypes = [
    'Corporate Event',
    'Wedding',
    'Birthday Party',
    'Conference',
    'Workshop',
    'Private Party',
    'Other',
  ];
  
  // Occasion types for restaurants
  final List<String> _occasionTypes = [
    'Regular Booking',
    'Birthday',
    'Anniversary',
    'Business Dinner',
    'Date Night',
    'Family Gathering',
    'Special Celebration',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.bookingType == BookingType.event ? localizations.eventBookingRequest : localizations.restaurantReservationRequest,
          style: GoogleFonts.roboto(
            color: AppColors.primary,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 22, extraLargePadding: 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Information Section
            if (widget.itemName != null) ...[
              _buildItemInfoSection().animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0),
              SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),
            ],
            
            // Booking Details Section
            _buildSectionCard(
              title: localizations.bookingDetails,
              icon: Icons.calendar_month,
              child: _buildBookingDetails(),
            ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),
            
            // Personal Information Section
            _buildSectionCard(
              title: localizations.personalInformation,
              icon: Icons.person,
              child: _buildPersonalInformation(),
            ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.03)),
            
            // Special Requests Section
            _buildSectionCard(
              title: localizations.specialRequests,
              icon: Icons.note_add,
              child: _buildSpecialRequests(),
            ).animate().fade(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.05)),
            
            // Submit Request Button
            _buildSubmitButton().animate().fade(delay: 800.ms, duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfoSection() {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 22, extraLargePadding: 24)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 16, mediumRadius: 18, largeRadius: 20, extraLargeRadius: 22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 16, largeRadius: 20, extraLargeRadius: 24),
            offset: Offset(0, ResponsiveUtils.getResponsiveHeight(context, 0.02)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 8, mediumPadding: 10, largePadding: 12, extraLargePadding: 14)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
                ),
                child: Icon(
                  widget.bookingType == BookingType.event ? Icons.event : Icons.restaurant,
                  color: AppColors.primary,
                  size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookingType == BookingType.event ? localizations.eventDetails : localizations.restaurantDetails,
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18, largeSize: 19, extraLargeSize: 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.itemName != null) ...[
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.01)),
                      Text(
                        widget.itemName!,
                        style: GoogleFonts.roboto(
                          color: AppColors.primary,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (widget.itemDescription != null) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
            Text(
              widget.itemDescription!,
              style: GoogleFonts.roboto(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 14, largeSize: 15, extraLargeSize: 16),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 22, extraLargePadding: 24)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 16, mediumRadius: 18, largeRadius: 20, extraLargeRadius: 22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 16, largeRadius: 20, extraLargeRadius: 24),
            offset: Offset(0, ResponsiveUtils.getResponsiveHeight(context, 0.02)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 8, mediumPadding: 10, largePadding: 12, extraLargePadding: 14)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18, largeSize: 19, extraLargeSize: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
          child,
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Column(
      children: [
        // Date Selection
        _buildDateField(),
        
        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
        
        // Time Selection
        _buildTimeField(),
        
        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
        
        // Number of Guests
        _buildGuestsField(),
        
        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
        
        // Event Type or Occasion
        widget.bookingType == BookingType.event 
            ? _buildEventTypeField() 
            : _buildOccasionField(),
      ],
    );
  }

  Widget _buildDateField() {
    final localizations = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 14, largePadding: 16, extraLargePadding: 18)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24)),
            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
            Expanded(
              child: Text(
                _selectedDate != null 
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : localizations.selectDate,
                style: GoogleFonts.roboto(
                  color: _selectedDate != null 
                      ? (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)
                      : Colors.grey.shade600,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    final localizations = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 14, largePadding: 16, extraLargePadding: 18)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primary, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24)),
            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.03)),
            Expanded(
              child: Text(
                _selectedTime != null 
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : localizations.selectTime,
                style: GoogleFonts.roboto(
                  color: _selectedTime != null 
                      ? (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)
                      : Colors.grey.shade600,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestsField() {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 14, largePadding: 16, extraLargePadding: 18)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: AppColors.primary, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24)),
          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.02)),
          Expanded(
            child: Text(
              '${localizations.numberOf} ${widget.bookingType == BookingType.event ? localizations.guests : localizations.people}',
              style: GoogleFonts.roboto(
                color: Colors.grey.shade600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.02)),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_guests > 1) {
                    setState(() {
                      _guests--;
                    });
                  }
                },
                child: Container(
                  width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 32, mediumSize: 36, largeSize: 40, extraLargeSize: 44),
                  height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 32, mediumSize: 36, largeSize: 40, extraLargeSize: 44),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 6, mediumRadius: 8, largeRadius: 10, extraLargeRadius: 12)),
                  ),
                  child: Icon(Icons.remove, color: AppColors.primary, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 18, largeSize: 20, extraLargeSize: 22)),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.04)),
              Text(
                '$_guests',
                style: GoogleFonts.roboto(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18, largeSize: 20, extraLargeSize: 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.04)),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _guests++;
                  });
                },
                child: Container(
                  width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 32, mediumSize: 36, largeSize: 40, extraLargeSize: 44),
                  height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 32, mediumSize: 36, largeSize: 40, extraLargeSize: 44),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 6, mediumRadius: 8, largeRadius: 10, extraLargeRadius: 12)),
                  ),
                  child: Icon(Icons.add, color: AppColors.primary, size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 16, mediumSize: 18, largeSize: 20, extraLargeSize: 22)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeField() {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 14, largePadding: 16, extraLargePadding: 18)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEventType,
          isExpanded: true,
          hint: Text(
            localizations.selectEventType,
            style: GoogleFonts.roboto(
              color: Colors.grey.shade600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
            ),
          ),
          items: _eventTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: GoogleFonts.roboto(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedEventType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildOccasionField() {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 12, mediumPadding: 14, largePadding: 16, extraLargePadding: 18)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOccasion,
          isExpanded: true,
          hint: Text(
            localizations.selectOccasion,
            style: GoogleFonts.roboto(
              color: Colors.grey.shade600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
            ),
          ),
          items: _occasionTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: GoogleFonts.roboto(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedOccasion = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPersonalInformation() {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        _buildInputField(
          controller: _nameController,
          label: localizations.fullName,
          icon: Icons.person,
          keyboardType: TextInputType.name,
        ),
        
        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
        
        _buildInputField(
          controller: _emailController,
          label: localizations.emailAddress,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        
        SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
        
        _buildInputField(
          controller: _phoneController,
          label: localizations.phoneNumber,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        labelStyle: GoogleFonts.roboto(
          color: Colors.grey.shade600,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
        ),
      ),
      style: GoogleFonts.roboto(
        color: Colors.black,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
      ),
    );
  }

  Widget _buildSpecialRequests() {
    final localizations = AppLocalizations.of(context)!;
    
    return TextField(
      controller: _specialRequestsController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: localizations.specialRequestsOptional,
        hintText: localizations.anySpecialRequirementsOrDietaryRestrictions,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        labelStyle: GoogleFonts.roboto(
          color: Colors.grey.shade600,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
        ),
        hintStyle: GoogleFonts.roboto(
          color: Colors.grey.shade500,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
        ),
      ),
      style: GoogleFonts.roboto(
        color: Colors.black,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.getResponsiveHeight(context, 0.08),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 25, mediumRadius: 30, largeRadius: 35, extraLargeRadius: 40)
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 16, largeRadius: 20, extraLargeRadius: 24),
            offset: Offset(0, ResponsiveUtils.getResponsiveHeight(context, 0.02)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 25, mediumRadius: 30, largeRadius: 35, extraLargeRadius: 40)
          ),
          onTap: _submitBookingRequest,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.02)),
                Text(
                  localizations.submitBookingRequest,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18, largeSize: 20, extraLargeSize: 22),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitBookingRequest() {
    final localizations = AppLocalizations.of(context)!;
    
    // Validate form
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      _showErrorDialog(localizations.pleaseFillInAllRequiredFields);
      return;
    }

    // Email validation
    if (!_isValidEmail(_emailController.text)) {
      _showErrorDialog(localizations.pleaseEnterAValidEmailAddress);
      return;
    }

    // Here you would send the email / booking request
    // For now, we'll show a success dialog
    _showSuccessDialog();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.error, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.roboto()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.ok, style: GoogleFonts.roboto(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text(localizations.requestSubmitted, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.yourBookingRequestHasBeenSuccessfullySubmitted,
              style: GoogleFonts.roboto(),
            ),
            SizedBox(height: 8),
            Text(
              localizations.weWillContactYouWithin24HoursToConfirmYourBooking,
              style: GoogleFonts.roboto(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(localizations.ok, style: GoogleFonts.roboto(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
