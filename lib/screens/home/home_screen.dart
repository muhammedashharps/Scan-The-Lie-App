import 'package:flutter/material.dart';
// For ValueListenableBuilder usually needs types if not inferred
import '../../core/theme/app_colors.dart';
import '../../widgets/stickman_battle_widget.dart';
import '../../data/repositories/scan_history_repository.dart';
import '../../data/repositories/settings_repository.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onScanPressed;
  final VoidCallback onHistoryPressed;
  final VoidCallback onSettingsPressed;
  final ScanHistoryRepository scanHistoryRepo;
  final SettingsRepository settingsRepo;

  const HomeScreen({
    super.key,
    required this.onScanPressed,
    required this.onHistoryPressed,
    required this.onSettingsPressed,
    required this.scanHistoryRepo,
    required this.settingsRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pinkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SCAN\nTHE LIE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: 1,
                        ),
                      ),
                      IconButton(
                        onPressed: onSettingsPressed,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.black, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stickman Battle Animation
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: StickmanBattleWidget(),
                ),

                const SizedBox(height: 8),

                // Main Action Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.black, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Scan & Discover\nWhat\'s Really Inside',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Scan packaged food to analyse ingredients and verify marketing claims',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onScanPressed,
                          child: const Text('START SCANNING'),
                        ),
                      ),
                    ],
                  ),
                ),

                // How It Works Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildStepCard(
                            '1',
                            'Scan',
                            'Take a photo of the product',
                            AppColors.cyan,
                            Icons.document_scanner,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStepCard(
                            '2',
                            'Analyze',
                            'AI checks ingredients & claims',
                            AppColors.purple,
                            Icons.psychology,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStepCard(
                            '3',
                            'Decide',
                            'Make informed choices',
                            AppColors.green,
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Health Info Card with scan illustration
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.green, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'HEALTHY EATING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Know what\'s good\nand what\'s not',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Get instant health scores',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Image.asset(
                        'assets/images/scan_illustration.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                // Stats Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Your Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ValueListenableBuilder(
                    valueListenable: scanHistoryRepo.getListenable()!,
                    builder: (context, historyBox, _) {
                      final totalScans = scanHistoryRepo.productCount;
                      final allProducts = scanHistoryRepo.getAllProducts();
                      final highRisk = allProducts
                          .where((p) => p.healthScore < 50) // < 50 is Risky
                          .length;

                      return ValueListenableBuilder(
                        valueListenable: settingsRepo.getListenable()!,
                        builder: (context, settingsBox, _) {
                          final savedReports =
                              settingsRepo.getSavedReportCount();

                          return Row(
                            children: [
                              Expanded(
                                  child: _buildStatCard(
                                      '$totalScans',
                                      'Total Scans',
                                      AppColors.purple,
                                      Icons.qr_code_scanner)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildStatCard(
                                      '$highRisk',
                                      'High Risk', // Replaced Products
                                      AppColors.orange,
                                      Icons.warning_amber_rounded)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildStatCard(
                                      '$savedReports',
                                      'Saved',
                                      AppColors.cyan,
                                      Icons
                                          .file_download)), // Bookmark -> Download
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String description,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.gray,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}
