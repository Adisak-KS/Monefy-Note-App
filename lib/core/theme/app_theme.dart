import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => FlexThemeData.light(
    scheme: FlexScheme.blue,
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSansThai().fontFamily,
  );

  static ThemeData get dark => FlexThemeData.dark(
    scheme: FlexScheme.blue,
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSansThai().fontFamily,
  );
}
