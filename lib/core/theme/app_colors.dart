import 'package:flutter/material.dart';

/// TinkerHub-inspired color palette
class AppColors {
  // Primary gradients
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF0F5), Color(0xFFE8D5F2)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A5FD9), Color(0xFF2E3A8C)],
  );

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF9E6), Color(0xFFFFE5B4)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFECFDF5), Color(0xFFA7F3D0)],
  );

  // Primary colors
  static const Color primary = Color(0xFF000000);
  static const Color accent = Color(0xFF00D9FF);

  // Accent colors
  static const Color cyan = Color(0xFF00D9FF);
  static const Color yellow = Color(0xFFFFF500);
  static const Color purple = Color(0xFF6366F1);
  static const Color green = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFBBF24);

  // Base colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFE5E7EB);
  static const Color gray = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444);

  static Color getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return success;
      case 'moderate':
        return warning;
      case 'high':
        return danger;
      default:
        return gray;
    }
  }

  static Color getScoreColor(int score) {
    if (score >= 70) return success;
    if (score >= 40) return warning;
    return danger;
  }
}
