import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light([AppColor? appColor]) {
    final color = appColor ?? AppColor.presets.first;
    return FlexThemeData.light(
      colors: FlexSchemeColor(
        primary: color.primary,
        primaryContainer: color.primary.withValues(alpha: 0.2),
        secondary: color.secondary,
        secondaryContainer: color.secondary.withValues(alpha: 0.2),
        tertiary: color.secondary,
        tertiaryContainer: color.secondary.withValues(alpha: 0.1),
      ),
      useMaterial3: true,
      fontFamily: GoogleFonts.prompt().fontFamily,
    );
  }

  static ThemeData dark([AppColor? appColor]) {
    final color = appColor ?? AppColor.presets.first;
    return FlexThemeData.dark(
      colors: FlexSchemeColor(
        primary: color.primary,
        primaryContainer: color.primary.withValues(alpha: 0.3),
        secondary: color.secondary,
        secondaryContainer: color.secondary.withValues(alpha: 0.3),
        tertiary: color.secondary,
        tertiaryContainer: color.secondary.withValues(alpha: 0.2),
      ),
      useMaterial3: true,
      fontFamily: GoogleFonts.prompt().fontFamily,
    );
  }
}
