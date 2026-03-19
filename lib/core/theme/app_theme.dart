import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme _baseTextTheme(Brightness brightness) {
    final seed = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;

    if (kIsWeb) {
      return GoogleFonts.interTextTheme(seed);
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => GoogleFonts.robotoTextTheme(seed),
      TargetPlatform.iOS || TargetPlatform.macOS => seed,
      _ => GoogleFonts.robotoTextTheme(seed),
    };
  }

  static TextTheme _headingTheme(TextTheme base) {
    if (!kIsWeb) {
      return base;
    }

    return base.copyWith(
      displayLarge: GoogleFonts.inter(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.inter(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.inter(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.inter(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.inter(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.inter(textStyle: base.headlineSmall),
      titleLarge: GoogleFonts.inter(textStyle: base.titleLarge),
      titleMedium: GoogleFonts.inter(textStyle: base.titleMedium),
      titleSmall: GoogleFonts.inter(textStyle: base.titleSmall),
    );
  }

  static ThemeData get light {
    final baseText = _baseTextTheme(Brightness.light);
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
        titleTextStyle: kIsWeb
            ? GoogleFonts.inter(
                color: AppColors.textOnNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )
            : TextStyle(
                color: AppColors.textOnNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
      ),
    );
  }

  static ThemeData get dark {
    final baseText = _baseTextTheme(Brightness.dark);
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
        titleTextStyle: kIsWeb
            ? GoogleFonts.inter(
                color: AppColors.darkOnSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )
            : TextStyle(
                color: AppColors.darkOnSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
      ),
    );
  }
}
