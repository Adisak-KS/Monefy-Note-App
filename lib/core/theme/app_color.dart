import 'package:flutter/material.dart';

enum AppColorTheme {
  blue,
  green,
  purple,
  orange,
  pink,
  teal,
  red,
  indigo,
  cyan,
  amber,
  lime,
  deepPurple,
  brown,
  blueGrey,
  lightBlue,
  deepOrange,
  mint,
  coral,
  navy,
  rose,
  emerald,
  gold,
}

class AppColor {
  final String name;
  final String nameKey;
  final Color primary;
  final Color secondary;
  final AppColorTheme theme;

  const AppColor({
    required this.name,
    required this.nameKey,
    required this.primary,
    required this.secondary,
    required this.theme,
  });

  static const List<AppColor> presets = [
    // Row 1: Blues
    AppColor(
      name: 'Blue',
      nameKey: 'colors.blue',
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF64B5F6),
      theme: AppColorTheme.blue,
    ),
    AppColor(
      name: 'Light Blue',
      nameKey: 'colors.light_blue',
      primary: Color(0xFF03A9F4),
      secondary: Color(0xFF4FC3F7),
      theme: AppColorTheme.lightBlue,
    ),
    AppColor(
      name: 'Cyan',
      nameKey: 'colors.cyan',
      primary: Color(0xFF00BCD4),
      secondary: Color(0xFF4DD0E1),
      theme: AppColorTheme.cyan,
    ),
    AppColor(
      name: 'Navy',
      nameKey: 'colors.navy',
      primary: Color(0xFF1A237E),
      secondary: Color(0xFF3949AB),
      theme: AppColorTheme.navy,
    ),
    // Row 2: Greens
    AppColor(
      name: 'Green',
      nameKey: 'colors.green',
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF81C784),
      theme: AppColorTheme.green,
    ),
    AppColor(
      name: 'Teal',
      nameKey: 'colors.teal',
      primary: Color(0xFF009688),
      secondary: Color(0xFF4DB6AC),
      theme: AppColorTheme.teal,
    ),
    AppColor(
      name: 'Emerald',
      nameKey: 'colors.emerald',
      primary: Color(0xFF10B981),
      secondary: Color(0xFF34D399),
      theme: AppColorTheme.emerald,
    ),
    AppColor(
      name: 'Mint',
      nameKey: 'colors.mint',
      primary: Color(0xFF26A69A),
      secondary: Color(0xFF80CBC4),
      theme: AppColorTheme.mint,
    ),
    // Row 3: Purples
    AppColor(
      name: 'Purple',
      nameKey: 'colors.purple',
      primary: Color(0xFF9C27B0),
      secondary: Color(0xFFBA68C8),
      theme: AppColorTheme.purple,
    ),
    AppColor(
      name: 'Deep Purple',
      nameKey: 'colors.deep_purple',
      primary: Color(0xFF673AB7),
      secondary: Color(0xFF9575CD),
      theme: AppColorTheme.deepPurple,
    ),
    AppColor(
      name: 'Indigo',
      nameKey: 'colors.indigo',
      primary: Color(0xFF3F51B5),
      secondary: Color(0xFF7986CB),
      theme: AppColorTheme.indigo,
    ),
    AppColor(
      name: 'Lime',
      nameKey: 'colors.lime',
      primary: Color(0xFF8BC34A),
      secondary: Color(0xFFAED581),
      theme: AppColorTheme.lime,
    ),
    // Row 4: Warm colors
    AppColor(
      name: 'Red',
      nameKey: 'colors.red',
      primary: Color(0xFFF44336),
      secondary: Color(0xFFE57373),
      theme: AppColorTheme.red,
    ),
    AppColor(
      name: 'Pink',
      nameKey: 'colors.pink',
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFF06292),
      theme: AppColorTheme.pink,
    ),
    AppColor(
      name: 'Rose',
      nameKey: 'colors.rose',
      primary: Color(0xFFF43F5E),
      secondary: Color(0xFFFB7185),
      theme: AppColorTheme.rose,
    ),
    AppColor(
      name: 'Coral',
      nameKey: 'colors.coral',
      primary: Color(0xFFFF6B6B),
      secondary: Color(0xFFFF8E8E),
      theme: AppColorTheme.coral,
    ),
    // Row 5: Oranges & Yellows
    AppColor(
      name: 'Orange',
      nameKey: 'colors.orange',
      primary: Color(0xFFFF9800),
      secondary: Color(0xFFFFB74D),
      theme: AppColorTheme.orange,
    ),
    AppColor(
      name: 'Deep Orange',
      nameKey: 'colors.deep_orange',
      primary: Color(0xFFFF5722),
      secondary: Color(0xFFFF8A65),
      theme: AppColorTheme.deepOrange,
    ),
    AppColor(
      name: 'Amber',
      nameKey: 'colors.amber',
      primary: Color(0xFFFFC107),
      secondary: Color(0xFFFFD54F),
      theme: AppColorTheme.amber,
    ),
    AppColor(
      name: 'Gold',
      nameKey: 'colors.gold',
      primary: Color(0xFFD4AF37),
      secondary: Color(0xFFE6C84D),
      theme: AppColorTheme.gold,
    ),
    // Row 6: Neutrals
    AppColor(
      name: 'Brown',
      nameKey: 'colors.brown',
      primary: Color(0xFF795548),
      secondary: Color(0xFFA1887F),
      theme: AppColorTheme.brown,
    ),
    AppColor(
      name: 'Blue Grey',
      nameKey: 'colors.blue_grey',
      primary: Color(0xFF607D8B),
      secondary: Color(0xFF90A4AE),
      theme: AppColorTheme.blueGrey,
    ),
  ];

  static AppColor fromTheme(AppColorTheme theme) {
    return presets.firstWhere(
      (c) => c.theme == theme,
      orElse: () => presets.first,
    );
  }

  static AppColor fromName(String name) {
    return presets.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => presets.first,
    );
  }
}
