import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triumph_hotels/core/constants/app_colors.dart';
import 'package:triumph_hotels/core/utils/responsive_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/utils/app_translations.dart';

class GuestPortalCustomRequestScreen extends StatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final String? initialDescription;

  const GuestPortalCustomRequestScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    this.initialDescription,
  });

  @override
  State<GuestPortalCustomRequestScreen> createState() => _GuestPortalCustomRequestScreenState();
}

class _GuestPortalCustomRequestScreenState extends State<GuestPortalCustomRequestScreen> {
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  // Media state
  final List<XFile> _selectedImages = [];
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;
  String? _tempAudioPath;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed.')),
      );
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final returnedPath = await _audioRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        // flutter_sound returns the actual path used. Fall back to temp path if null.
        _audioPath = returnedPath ?? _tempAudioPath;
      });
    } else {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder!.startRecorder(
          toFile: path,
          codec: Codec.aacMP4,
        );
        setState(() {
          _isRecording = true;
          _audioPath = null; // Clear previous attachment
          _tempAudioPath = path; // Store path temporarily
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied.')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Custom Request'.tr(context),
          style: GoogleFonts.roboto(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20.0 : ResponsiveUtils.getScreenWidth(context) * 0.15,
          vertical: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.categoryColor.withOpacity(0.5)),
              ),
              child: Text(
                widget.categoryTitle.tr(context),
                style: GoogleFonts.roboto(
                  color: widget.categoryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fade().slideY(begin: 0.1),
            
            const SizedBox(height: 24),
            
            Text(
              'How can we help?'.tr(context),
              style: GoogleFonts.roboto(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 8),
            
            Text(
              'Please provide the details of your request below.'.tr(context),
              style: GoogleFonts.roboto(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
              ),
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 24),
            
            // Description Input
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 6,
                style: GoogleFonts.roboto(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your request here...'.tr(context),
                  hintStyle: GoogleFonts.roboto(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 32),
            
            // Attachments Section
            Text(
              'Attachments (Optional)'.tr(context),
              style: GoogleFonts.roboto(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildAttachmentButton(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: 'Add Image'.tr(context),
                    color: Colors.blue,
                    onTap: _pickImage,
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAttachmentButton(
                    context,
                    icon: _isRecording ? Icons.stop_circle_outlined : Icons.mic_none_outlined,
                    label: _isRecording ? 'Recording...' : (_audioPath != null ? 'Retake Voice' : 'Voice Note'.tr(context)),
                    color: _isRecording ? Colors.red : Colors.redAccent,
                    onTap: _toggleRecording,
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                ),
              ],
            ),
            
            // Show Audio Attachment
            if (_audioPath != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audio_file, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Voice Note Attached',
                        style: GoogleFonts.roboto(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () {
                        setState(() => _audioPath = null);
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Show Selected Images
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    final image = _selectedImages[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12, top: 8),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(image.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 48),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isLoading || _isRecording) ? null : () async {
                  final description = _descriptionController.text.trim();
                  if (description.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your request details.'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  final provider = context.read<GuestPortalProvider>();
                  bool success;

                  if (_selectedImages.isNotEmpty || _audioPath != null) {
                    success = await provider.submitSmartRequest(
                      category: widget.categoryTitle,
                      text: description,
                      imagePaths: _selectedImages.map((e) => e.path).toList(),
                      voicePath: _audioPath,
                    );
                  } else {
                    success = await provider.submitRequest(
                      category: widget.categoryTitle,
                      title: description,
                    );
                  }

                  if (!mounted || !context.mounted) return;
                  setState(() => _isLoading = false);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Request submitted successfully!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    // Pop back to the category list (or further)
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? 'Failed to submit request.'),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'SUBMIT REQUEST'.tr(context),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.roboto(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
