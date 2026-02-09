import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: AppColors.white, size: 64),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            const Text(
              'SCAN THE LIE',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.black,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .moveY(begin: 20, end: 0),
          ],
        ),
      ),
    );
  }
}
