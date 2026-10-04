import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.greatVibes(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.greatVibes(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.greatVibes(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.greatVibes(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.greatVibes(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.greatVibes(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.greatVibes(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.greatVibes(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.greatVibes(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.tenorSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.tenorSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.tenorSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.roboto(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.greatVibes(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        displayMedium: GoogleFonts.greatVibes(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        displaySmall: GoogleFonts.greatVibes(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        headlineLarge: GoogleFonts.greatVibes(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.greatVibes(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        headlineSmall: GoogleFonts.greatVibes(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: GoogleFonts.greatVibes(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: GoogleFonts.greatVibes(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        titleSmall: GoogleFonts.greatVibes(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.tenorSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.tenorSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        bodySmall: GoogleFonts.tenorSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextSecondary,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.roboto(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkBackground,
      ),
    );
  }
}
