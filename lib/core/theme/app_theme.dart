import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryNavy,
        secondary: AppColors.pathwayAmber,
        surface: AppColors.surfaceWhite,
        onPrimary: AppColors.textOnNavy,
        onSurface: AppColors.textOnSurface,
      ),
      scaffoldBackgroundColor: AppColors.surfaceWhite,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textOnNavy,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
