import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/providers/language_provider.dart';
import 'package:triumph_hotels/core/providers/auth_provider.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:triumph_hotels/features/settings/language_screen.dart';
import 'package:triumph_hotels/features/auth/login_screen.dart';
import 'package:triumph_hotels/features/auth/register_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  
  // These will be used for editing mode later
  String _tempPhone = '';
  String _tempFirstName = '';
  String _tempLastName = '';
  String _tempNationality = '';
  String? _tempAvatarPath;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.profile,
          style: GoogleFonts.roboto(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: IconThemeData(color: AppColors.primary),
        actions: authProvider.isAuthenticated ? [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: () async {
                if (_isEditing) {
                  // We are saving
                  if (_tempPhone.isNotEmpty || _tempFirstName.isNotEmpty || _tempLastName.isNotEmpty || _tempNationality.isNotEmpty || _tempAvatarPath != null) {
                    final success = await authProvider.updateProfile(
                      phone: _tempPhone.isNotEmpty ? _tempPhone : null,
                      firstName: _tempFirstName.isNotEmpty ? _tempFirstName : null,
                      lastName: _tempLastName.isNotEmpty ? _tempLastName : null,
                      nationality: _tempNationality.isNotEmpty ? _tempNationality : null,
                      avatarPath: _tempAvatarPath,
                    );
                    if (!success && mounted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.errorMessage ?? 'Update failed'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (success) {
                      _tempAvatarPath = null;
                    }
                  }
                  setState(() {
                    _isEditing = false;
                  });
                } else {
                  // We are entering edit mode
                  setState(() {
                    _isEditing = true;
                    _tempPhone = authProvider.currentUser?.phone ?? '';
                    _tempFirstName = authProvider.currentUser?.firstName ?? '';
                    _tempLastName = authProvider.currentUser?.lastName ?? '';
                    _tempNationality = authProvider.currentUser?.nationality ?? '';
                  });
                }
              },
            ),
          ),
        ] : null,
      ),
      body: authProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : !authProvider.isAuthenticated
              ? _buildGuestView(context, localizations, theme)
              : _buildProfileView(context, localizations, theme, authProvider),
    );
  }

  Widget _buildGuestView(BuildContext context, AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            Text(
              'Welcome Guest',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 16),
            
            Text(
              'Sign in to manage your bookings, access exclusive offers, and enjoy your luxury stay.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SIGN IN',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'CREATE ACCOUNT',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, AppLocalizations localizations, ThemeData theme, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context, smallPadding: 16, mediumPadding: 24, largePadding: 32)),
      child: Column(
        children: [
          // Profile Header Section
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 100, mediumSize: 120, largeSize: 140),
                      height: ResponsiveUtils.getResponsiveIconSize(context, smallSize: 100, mediumSize: 120, largeSize: 140),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _tempAvatarPath != null
                          ? ClipOval(child: Image.file(File(_tempAvatarPath!), fit: BoxFit.cover))
                          : (user?.avatar != null 
                              ? ClipOval(child: Image.network(user!.avatar!, fit: BoxFit.cover))
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 60,
                                )),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _tempAvatarPath = pickedFile.path;
                              });
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.cardColor, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 20),
                
                // User Name
                Text(
                  fullName.isEmpty ? 'Triumph Member' : fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, smallSize: 24, mediumSize: 28, largeSize: 32),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(delay: 200.ms, duration: 600.ms),
                
                const SizedBox(height: 8),
                
                // Membership Tier
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.2),
                        Colors.amber.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Member', // Real tier logic here later
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 300.ms, duration: 600.ms),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Personal Information Section
          _buildSectionCard(
            title: localizations.personalInformation,
            icon: Icons.person_outline,
            children: [
              _buildInfoRow(
                icon: Icons.person,
                label: 'First Name',
                value: user?.firstName ?? 'Not provided',
                isEditing: _isEditing,
                onChanged: (value) => _tempFirstName = value,
              ),
              _buildDivider(),
              _buildInfoRow(
                icon: Icons.person,
                label: 'Last Name',
                value: user?.lastName ?? 'Not provided',
                isEditing: _isEditing,
                onChanged: (value) => _tempLastName = value,
              ),
              _buildDivider(),
              _buildInfoRow(
                icon: Icons.public,
                label: 'Nationality',
                value: user?.nationality ?? 'Not provided',
                isEditing: _isEditing,
                onChanged: (value) => _tempNationality = value,
              ),
              _buildDivider(),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: localizations.email,
                value: user?.email ?? 'Not provided',
                isEditing: false, // Don't allow email editing for now
                onChanged: (_) {},
              ),
              _buildDivider(),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: localizations.phone,
                value: user?.phone ?? 'Not provided',
                isEditing: _isEditing,
                onChanged: (value) => _tempPhone = value,
              ),
            ],
          ).animate().fade(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 24),
          
          // Preferences Section
          _buildSectionCard(
            title: localizations.settings,
            icon: Icons.settings_outlined,
            children: [
              _buildLanguageRow(context),
              _buildDivider(),
              _buildPreferenceRow(
                icon: Icons.attach_money_outlined,
                label: localizations.currency,
                value: 'USD',
                onTap: () {},
              ),
            ],
          ).animate().fade(delay: 700.ms, duration: 600.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 24),
          
          // Sign Out Button
          GestureDetector(
            onTap: () {
              authProvider.logout();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.signOut,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fade(delay: 900.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditing,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isEditing
                ? TextFormField(
                    initialValue: value == 'Not provided' ? '' : value,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                    ),
                  )
                : Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        color: theme.dividerColor.withOpacity(0.3),
        thickness: 1,
      ),
    );
  }

  Widget _buildLanguageRow(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    
    return _buildPreferenceRow(
      icon: Icons.language_outlined,
      label: localizations.language,
      value: languageProvider.getLanguageDisplayName(languageProvider.currentLocale),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LanguageScreen(),
          ),
        );
      },
    );
  }
}
