import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:triumph_hotels/core/constants/app_colors.dart';

class CustomAuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool? isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final String? Function(String?)? validator;

  const CustomAuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible,
    this.onVisibilityToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: controller,
                obscureText: isPassword && !(isPasswordVisible ?? false),
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
                validator: validator,
                cursorColor: AppColors.goldLight,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.roboto(color: Colors.white.withOpacity(0.3), fontSize: 16),
                  prefixIcon: Icon(icon, color: Colors.white70, size: 20),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            (isPasswordVisible ?? false)
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: onVisibilityToggle,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
