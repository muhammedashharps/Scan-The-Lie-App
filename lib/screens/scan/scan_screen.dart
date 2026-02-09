import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product.dart';
import '../../services/gemini_service.dart';

import '../../data/repositories/settings_repository.dart';
import '../common/error_screen.dart';
import '../../widgets/scanning_animation.dart';

class ScanScreen extends StatefulWidget {
  final GeminiService geminiService;
  final SettingsRepository settingsRepo;
  final Function(Product) onProductScanned;

  const ScanScreen({
    super.key,
    required this.geminiService,
    required this.settingsRepo,
    required this.onProductScanned,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _frontImage;
  File? _backImage;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _pickImage(bool isFront, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source: source, maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
      if (pickedFile != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(pickedFile.path);
          } else {
            _backImage = File(pickedFile.path);
          }
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to pick image: $e');
    }
  }

  void _showSourceSheet(bool isFront) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isFront, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isFront, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeProduct() async {
    // ... checks ...
    if (_frontImage == null || _backImage == null) {
      setState(() => _errorMessage = 'Please scan both FRONT and BACK images.');
      return;
    }
    if (!widget.geminiService.isInitialized) {
      setState(() =>
          _errorMessage = 'Please set your Gemini API key in Settings first.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final userPrefs = widget.settingsRepo.getUserPreferences();
      final product = await widget.geminiService
          .analyzeProduct(_frontImage!, _backImage!, userPrefs);

      widget.onProductScanned(product);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _frontImage = null;
          _backImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        // Navigate to error screen without stopping loading state to prevent flash
        final shouldRetry = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(
              title: 'Analysis Failed',
              message: e.toString().replaceAll('Exception: ', ''),
              retryText: 'Retry Analysis',
              onRetry: () => Navigator.pop(context, true), // Signal retry
            ),
          ),
        );

        // Handle navigation result
        if (shouldRetry == true) {
          // Restart analysis (loading state is already true)
          _analyzeProduct();
        } else {
          // User canceled, stop loading
          if (mounted) {
            setState(() => _isAnalyzing = false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.greenGradient),
        child: SafeArea(
          child: _isAnalyzing ? _buildLoadingView() : _buildScannerView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scanner Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.black)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ANALYSIS IN PROGRESS",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),

            // The Scanner
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(18)),
              child: ScanningAnimation(
                width: double.infinity,
                height: 350,
                child: _frontImage != null
                    ? Image.file(_frontImage!, fit: BoxFit.cover)
                    : Container(color: AppColors.gray),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SCAN PRODUCT',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (!widget.geminiService.isInitialized)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'API Key missing. Go to Settings > Gemini API Key.',
                      style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger),
              ),
              child: Text(_errorMessage!,
                  style:
                      const TextStyle(color: AppColors.danger, fontSize: 13)),
            ),

          // Front Image Card
          _buildImageCard(true),
          const SizedBox(height: 16),

          // Back Image Card
          _buildImageCard(false),

          const SizedBox(height: 32),

          // Action Button Wrapper (Stickman Holder)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Stickman drawing below
              Positioned(
                bottom: -60, // Stickman body positioned below button
                child: CustomPaint(
                  size: const Size(100, 60),
                  painter: StickmanHolderPainter(),
                ),
              ),

              // The Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_frontImage != null && _backImage != null)
                      ? _analyzeProduct
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 4, // Give it some depth
                    shadowColor: AppColors.black,
                  ),
                  child: const Text('ANALYZE PRODUCT'),
                ),
              ),
            ],
          ),

          const SizedBox(
              height: 100), // Extra scroll space including stickman space
        ],
      ),
    );
  }

  Widget _buildImageCard(bool isFront) {
    File? image = isFront ? _frontImage : _backImage;
    String title = isFront ? 'FRONT SIDE' : 'BACK SIDE';
    String subtitle =
        isFront ? 'Scan Main Label & Claims' : 'Scan Ingredients & Facts';
    IconData icon = isFront ? Icons.branding_watermark : Icons.receipt_long;

    return GestureDetector(
      onTap: () => _showSourceSheet(isFront),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.black, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              if (image != null)
                Positioned.fill(child: Image.file(image, fit: BoxFit.cover))
              else
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 40, color: AppColors.black),
                      ),
                      const SizedBox(height: 12),
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppColors.gray, fontSize: 12)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.black),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo, size: 16),
                            SizedBox(width: 8),
                            Text('TAP TO SCAN',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (image != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 20),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFront ? 'FRONT' : 'BACK',
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StickmanHolderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headPaint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;

    // Head (Below the "hands" level)
    // Hands are at y=0 (touching button)
    // Body starts at y=10?

    // Let's say button bottom is at Y=0 relative to this paint?
    // No, I positioned it at bottom: -60. So Y=0 is button bottom? No.
    // Stack:
    // Button
    // Painter (bottom: -60). Size(100, 60).
    // So Painter Top (y=0) is roughly 60px below button... No.
    // Stack alignment is bottomCenter.
    // Button is laid out.
    // Positioned(bottom: -60). This puts the Painter's bottom edge 60px below the stack's bottom edge (which aligns with button).
    // So Painter is mostly below the button.

    // Let's assume Painter's y=0 is "touching the button".
    // Arms go Up.

    // Head
    canvas.drawCircle(Offset(centerX, 20), 10, headPaint);

    // Body
    canvas.drawLine(Offset(centerX, 30), Offset(centerX, 50), paint);

    // Legs
    canvas.drawLine(Offset(centerX, 50), Offset(centerX - 10, 60), paint);
    canvas.drawLine(Offset(centerX, 50), Offset(centerX + 10, 60), paint);

    // Arms (Holding UP)
    // Shoulders
    canvas.drawLine(Offset(centerX, 35), Offset(centerX - 12, 35), paint);
    canvas.drawLine(Offset(centerX, 35), Offset(centerX + 12, 35), paint);

    // Forearms (Up to Button)
    canvas.drawLine(Offset(centerX - 12, 35), Offset(centerX - 20, 0),
        paint); // Left Hand touches top (y=0)
    canvas.drawLine(Offset(centerX + 12, 35), Offset(centerX + 20, 0),
        paint); // Right Hand touches top (y=0)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
