import 'package:flutter/material.dart';

/// GPG Corporate Identity colors.
abstract class AppColors {
  static const Color celestialGold = Color(0xFFFFD700);
  static const Color deepHarborLegacy = Color(0xFF2E5A88);
  static const Color linenWhiteLegacy = Color(0xFFF5F5F5);
  static const Color pathwayGreenLegacy = Color(0xFF4CAF50);

  static const Color primaryNavy = Color(0xFF002E5D);
  static const Color pathwayAmber = Color(0xFFE9B14C);
  static const Color surfaceWhite = Color(0xFFF9F9F9);
  static const Color stewardshipGreen = Color(0xFF00966C);
  static const Color warmCrimson = Color(0xFFBA0C2F);

  static const Color navyLight = Color(0xFF1A4A7A);
  static const Color amberLight = Color(0xFFF5D078);
  static const Color textOnNavy = Color(0xFFFFFFFF);
  static const Color textOnSurface = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color darkSurface = Color(0xFF0A0A0A);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
}

/// Compatibility helper:
/// Some Flutter versions don't include `Color.withValues(...)`.
/// We use `withValues(alpha: ...)` widely for glassmorphism tinting.
extension ColorWithValuesCompat on Color {
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    final a = alpha.clamp(0.0, 1.0);
    return withOpacity(a);
  }
}
