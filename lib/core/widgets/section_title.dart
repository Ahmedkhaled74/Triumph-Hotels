import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';

import '../utils/responsive_utils.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionTitle({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0), // Increased padding for elegance
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: GoogleFonts.roboto(
              color: AppColors.primary,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 18, mediumSize: 20, largeSize: 22, extraLargeSize: 24),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
