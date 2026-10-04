import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/constants/app_images.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:triumph_hotels/features/auth/widgets/custom_auth_field.dart';
import 'package:triumph_hotels/features/guest_portal/guest_portal_home_screen.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';

class GuestPortalLoginScreen extends StatefulWidget {
  const GuestPortalLoginScreen({super.key});

  @override
  State<GuestPortalLoginScreen> createState() => _GuestPortalLoginScreenState();
}

class _GuestPortalLoginScreenState extends State<GuestPortalLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkSessionState();
  }

  void _checkSessionState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isNavigating) return;
      final provider = context.read<GuestPortalProvider>();
      if (!provider.isRestoringSession && provider.isLoggedIn) {
        _isNavigating = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GuestPortalHomeScreen()),
        );
      }
    });
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<GuestPortalProvider>();
    final success = await provider.loginByRoom(
      roomNumber: _roomController.text.trim(),
      resvNameId: _codeController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GuestPortalHomeScreen()),
      );
    } else {
      String errorMsg = provider.errorMessage ?? '';
      if (errorMsg.isEmpty ||
          errorMsg.contains('<') ||
          errorMsg.contains('CSRF') ||
          errorMsg.startsWith('Status ')) {
        errorMsg = 'Room number or confirmation code is incorrect. Please try again or contact the front desk.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final horizontalPadding = isSmallScreen ? 28.0 : ResponsiveUtils.getScreenWidth(context) * 0.25;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ).animate().fade().slideX(begin: -0.2),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Quiet Simple Background (Dimmed image or solid elegant gradient)
          Image.asset(
            AppImages.guestLogin, // A quiet image
            fit: BoxFit.cover,
            alignment: const Alignment(-0.04, 0.0), // Moves the image just a tiny bit to the right
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A1A1A)),
          ),
          
          // Heavy Elegant Dark Gradient Overlay to keep it quiet and simple
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A1A1A).withOpacity(0.4),
                    const Color(0xFF1A1A1A).withOpacity(0.85),
                    const Color(0xFF1A1A1A).withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Consumer<GuestPortalProvider>(
              builder: (context, provider, child) {
                if (provider.isRestoringSession) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (provider.isLoggedIn) {
                  _checkSessionState();
                  return const SizedBox.shrink();
                }

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.goldLight.withOpacity(0.5), width: 1),
                        ),
                        child: Icon(
                          Icons.vpn_key_outlined,
                          size: 32,
                          color: AppColors.goldLight,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      
                      Text(
                        'Discover Your Stay',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'GUEST PORTAL ACCESS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: AppColors.goldLight.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.0,
                        ),
                      ).animate().fade(delay: 300.ms).slideY(begin: 0.2),

                      const SizedBox(height: 48),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: -5,
                                )
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  CustomAuthField(
                                    label: 'ROOM NUMBER',
                                    hint: 'Enter your room number',
                                    icon: Icons.meeting_room_outlined,
                                    controller: _roomController,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your room number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  CustomAuthField(
                                    label: 'CONFIRMATION CODE',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline,
                                    controller: _codeController,
                                    isPassword: true,
                                    isPasswordVisible: _isPasswordVisible,
                                    onVisibilityToggle: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter confirmation code';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 40),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'ACCESS PORTAL',
                                              style: GoogleFonts.roboto(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2.0,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'If you haven\'t received a confirmation code, please contact the front desk.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ).animate().fade(delay: 500.ms),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
