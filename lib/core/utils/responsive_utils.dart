import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Device detection
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 900 && width < 1200;
  }

  static bool isExtraLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, {
    required double smallSize,
    double? mediumSize,
    double? largeSize,
    double? extraLargeSize,
  }) {
    if (isExtraLargeScreen(context)) {
      return extraLargeSize ?? smallSize;
    } else if (isLargeScreen(context)) {
      return largeSize ?? mediumSize ?? smallSize;
    } else if (isMediumScreen(context)) {
      return mediumSize ?? smallSize;
    } else {
      return smallSize;
    }
  }

  // Responsive spacing
  static double getResponsivePadding(BuildContext context, {
    required double smallPadding,
    double? mediumPadding,
    double? largePadding,
    double? extraLargePadding,
  }) {
    if (isExtraLargeScreen(context)) {
      return extraLargePadding ?? largePadding ?? mediumPadding ?? smallPadding;
    } else if (isLargeScreen(context)) {
      return largePadding ?? mediumPadding ?? smallPadding;
    } else if (isMediumScreen(context)) {
      return mediumPadding ?? smallPadding;
    } else {
      return smallPadding;
    }
  }

  static double getResponsiveMargin(BuildContext context, {
    required double smallMargin,
    double? mediumMargin,
    double? largeMargin,
    double? extraLargeMargin,
  }) {
    if (isExtraLargeScreen(context)) {
      return extraLargeMargin ?? largeMargin ?? mediumMargin ?? smallMargin;
    } else if (isLargeScreen(context)) {
      return largeMargin ?? mediumMargin ?? smallMargin;
    } else if (isMediumScreen(context)) {
      return mediumMargin ?? smallMargin;
    } else {
      return smallMargin;
    }
  }

  // Responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, {
    required double smallRadius,
    double? mediumRadius,
    double? largeRadius,
    double? extraLargeRadius,
  }) {
    if (isExtraLargeScreen(context)) {
      return extraLargeRadius ?? largeRadius ?? mediumRadius ?? smallRadius;
    } else if (isLargeScreen(context)) {
      return largeRadius ?? mediumRadius ?? smallRadius;
    } else if (isMediumScreen(context)) {
      return mediumRadius ?? smallRadius;
    } else {
      return smallRadius;
    }
  }

  // Responsive icon sizes
  static double getResponsiveIconSize(BuildContext context, {
    required double smallSize,
    double? mediumSize,
    double? largeSize,
    double? extraLargeSize,
  }) {
    if (isExtraLargeScreen(context)) {
      return extraLargeSize ?? largeSize ?? mediumSize ?? smallSize;
    } else if (isLargeScreen(context)) {
      return largeSize ?? mediumSize ?? smallSize;
    } else if (isMediumScreen(context)) {
      return mediumSize ?? smallSize;
    } else {
      return smallSize;
    }
  }

  // Responsive height/width percentages
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  // Safe area insets
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getSafeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // Device-specific optimizations
  static bool shouldUseCompactLayout(BuildContext context) {
    return isSmallScreen(context) && isPortrait(context);
  }

  static bool shouldUseTabletLayout(BuildContext context) {
    return isTablet(context) || isLandscape(context);
  }

  // Responsive grid columns
  static int getResponsiveColumns(BuildContext context) {
    if (isExtraLargeScreen(context)) {
      return 4;
    } else if (isLargeScreen(context)) {
      return 3;
    } else if (isMediumScreen(context)) {
      return 2;
    } else {
      return 1;
    }
  }

  // Responsive item count
  static int getResponsiveItemCount(BuildContext context, int maxItems) {
    if (isSmallScreen(context)) {
      return (maxItems * 0.6).round();
    } else if (isMediumScreen(context)) {
      return (maxItems * 0.8).round();
    } else {
      return maxItems;
    }
  }

  // Text scaling helper
  static double getScaledTextSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSize * 0.8;
    } else if (screenWidth < 600) {
      return baseSize;
    } else if (screenWidth < 900) {
      return baseSize * 1.1;
    } else if (screenWidth < 1200) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.3;
    }
  }

  // Device type detection
  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 'Mobile Small';
    if (width < 900) return 'Mobile Medium';
    if (width < 1200) return 'Tablet';
    return 'Desktop';
  }

  // Breakpoint constants
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Common responsive values
  static const Map<String, double> commonFontSizes = {
    'xs': 12.0,
    'sm': 14.0,
    'md': 16.0,
    'lg': 18.0,
    'xl': 20.0,
    '2xl': 24.0,
    '3xl': 32.0,
    '4xl': 40.0,
  };

  static const Map<String, double> commonSpacing = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 12.0,
    'lg': 16.0,
    'xl': 20.0,
    '2xl': 24.0,
    '3xl': 32.0,
  };

  static const Map<String, double> commonBorderRadius = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 12.0,
    'lg': 16.0,
    'xl': 20.0,
    '2xl': 24.0,
    '3xl': 32.0,
  };

  // Design-based scaling (Reference: 375x812)
  static double scaleWidth(BuildContext context, double designWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (designWidth / 375.0) * screenWidth;
  }

  static double scaleHeight(BuildContext context, double designHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (designHeight / 812.0) * screenHeight;
  }

  static double scaleFontSize(BuildContext context, double designFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Use the smaller scale factor for fonts to prevent oversized text on tablets
    final scale = screenWidth / 375.0;
    return designFontSize * (scale > 1.2 ? 1.2 : scale);
  }
}
