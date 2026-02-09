import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/scan_history_repository.dart';
import '../../services/gemini_service.dart';
import '../settings/questionnaire_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final SettingsRepository repository;
  final ScanHistoryRepository? scanHistoryRepo;
  final GeminiService? geminiService;

  const WelcomeScreen({
    super.key,
    required this.repository,
    this.scanHistoryRepo,
    this.geminiService,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _start() async {
    if (_nameController.text.trim().isEmpty) return;

    final prefs = widget.repository.getUserPreferences();
    prefs.username = _nameController.text.trim();
    await widget.repository.saveUserPreferences(prefs);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionnaireScreen(
            repository: widget.repository,
            scanHistoryRepo: widget.scanHistoryRepo,
            geminiService: widget.geminiService,
            isOnboarding: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 64),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    // Logo or Graphic
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_scanner,
                            color: AppColors.white, size: 48),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Welcome to\nScan The Lie',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Let\'s personalize your experience. First, what should we call you?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Your Name',
                        hintStyle: TextStyle(color: AppColors.lightGray),
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.black, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.black, width: 2),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _start,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
