import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  AppTheme._();

  // Use bundled Prompt font (download from fonts.google.com/specimen/Prompt)
  // Falls back to system font if not available
  static const String _fontFamily = 'Prompt';

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
      fontFamily: _fontFamily,
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
      fontFamily: _fontFamily,
    );
  }
}
