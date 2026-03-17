import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme _headingTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.interTight(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.interTight(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.interTight(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.interTight(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.interTight(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.interTight(textStyle: base.headlineSmall),
      titleLarge: GoogleFonts.interTight(textStyle: base.titleLarge),
      titleMedium: GoogleFonts.interTight(textStyle: base.titleMedium),
      titleSmall: GoogleFonts.interTight(textStyle: base.titleSmall),
    );
  }

  static ThemeData get light {
    final baseText = GoogleFonts.ibmPlexSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryNavy,
        secondary: AppColors.pathwayAmber,
        surface: AppColors.surfaceWhite,
        tertiary: AppColors.stewardshipGreen,
        error: AppColors.warmCrimson,
        onPrimary: AppColors.textOnNavy,
        onSurface: AppColors.textOnSurface,
      ),
      scaffoldBackgroundColor: AppColors.surfaceWhite,
      textTheme: _headingTheme(baseText),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.interTight(
          color: AppColors.textOnNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final baseText = GoogleFonts.ibmPlexSansTextTheme(
      ThemeData.dark(useMaterial3: true).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.pathwayAmber,
        secondary: AppColors.primaryNavy,
        surface: AppColors.darkSurface,
        tertiary: AppColors.stewardshipGreen,
        error: AppColors.warmCrimson,
        onPrimary: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkSurface,
      textTheme: _headingTheme(baseText),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.interTight(
          color: AppColors.darkOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
