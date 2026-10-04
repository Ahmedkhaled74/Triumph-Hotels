import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/providers/language_provider.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.language,
          style: GoogleFonts.roboto(
            color: AppColors.primary,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 20, largePadding: 22, extraLargePadding: 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              localizations.language,
              style: GoogleFonts.roboto(
                color: Theme.of(context).textTheme.headlineSmall?.color,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 20, mediumSize: 22, largeSize: 24, extraLargeSize: 26),
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
            
            Text(
              'Choose your preferred language for the app interface',
              style: GoogleFonts.roboto(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 14, mediumSize: 16, largeSize: 17, extraLargeSize: 18),
              ),
            ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.04)),
            
            // Language Options
            ...languageProvider.supportedLocales.map((locale) {
              final isSelected = languageProvider.currentLocale == locale;
              final displayName = languageProvider.getLanguageDisplayName(locale);
              final nativeName = languageProvider.getLanguageNativeName(locale);
              final flag = _getLanguageFlag(locale);
              
              return _buildLanguageOption(
                context,
                locale: locale,
                displayName: displayName,
                nativeName: nativeName,
                flag: flag,
                isSelected: isSelected,
                onTap: () {
                  languageProvider.changeLanguage(locale);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $nativeName'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required Locale locale,
    required String displayName,
    required String nativeName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveHeight(context, 0.02)),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 14, largeRadius: 16, extraLargeRadius: 18)
        ),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : Theme.of(context).dividerColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 12, mediumRadius: 14, largeRadius: 16, extraLargeRadius: 18)
          ),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 18, largePadding: 20, extraLargePadding: 22)
            ),
            child: Row(
              children: [
                // Flag
                Container(
                  width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 40, mediumSize: 45, largeSize: 50, extraLargeSize: 55),
                  height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 40, mediumSize: 45, largeSize: 50, extraLargeSize: 55),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, smallRadius: 8, mediumRadius: 10, largeRadius: 12, extraLargeRadius: 14)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      flag,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 24, mediumSize: 28, largeSize: 32, extraLargeSize: 36),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 0.04)),
                
                // Language Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nativeName,
                        style: GoogleFonts.roboto(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 16, mediumSize: 18, largeSize: 19, extraLargeSize: 20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 0.005)),
                      Text(
                        displayName,
                        style: GoogleFonts.roboto(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 12, mediumSize: 14, largeSize: 15, extraLargeSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Selection Indicator
                if (isSelected)
                  Container(
                    width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 24, mediumSize: 26, largeSize: 28, extraLargeSize: 30),
                    height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 24, mediumSize: 26, largeSize: 28, extraLargeSize: 30),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 14, mediumSize: 16, largeSize: 18, extraLargeSize: 20),
                    ),
                  )
                else
                  Container(
                    width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 24, mediumSize: 26, largeSize: 28, extraLargeSize: 30),
                    height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 24, mediumSize: 26, largeSize: 28, extraLargeSize: 30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: 400.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ar':
        return '🇸🇦';
      default:
        return '🌐';
    }
  }
}
