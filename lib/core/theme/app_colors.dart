import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Default Theme Colors (Blue)
  static const defaultPrimary = Color(0xFF1E88E5);

  // Default Gradient - Light Mode
  static const List<Color> defaultGradientLight = [
    Color(0xFF64B5F6),
    Color(0xFF1E88E5),
    Color(0xFF1565C0),
  ];

  // Default Gradient - Dark Mode
  static const List<Color> defaultGradientDark = [
    Color(0xFF1A237E),
    Color(0xFF0D47A1),
    Color(0xFF01579B),
  ];

  // Logo Colors
  static const Color logoGradientStart = Color(0xFF42A5F5);
  static const Color logoGradientEnd = Color(0xFF1565C0);
  static const Color coinGold = Color(0xFFFFD700);

  // Preset Themes (สำหรับให้ user เลือก)
  static const Map<String, List<Color>> presetGradients = {
    'blue': [Color(0xFF64B5F6), Color(0xFF1E88E5), Color(0xFF1565C0)],
    'green': [Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFF388E3C)],
    'purple': [Color(0xFFBA68C8), Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    'orange': [Color(0xFFFFB74D), Color(0xFFFF9800), Color(0xFFF57C00)],
    'teal': [Color(0xFF4DD0E1), Color(0xFF00BCD4), Color(0xFF0097A7)],
    'pink': [Color(0xFFF48FB1), Color(0xFFE91E63), Color(0xFFC2185B)],
    'indigo': [Color(0xFF7986CB), Color(0xFF3F51B5), Color(0xFF303F9F)],
    'red': [Color(0xFFE57373), Color(0xFFF44336), Color(0xFFD32F2F)],
    'cyan': [Color(0xFF80DEEA), Color(0xFF26C6DA), Color(0xFF00ACC1)],
    'amber': [Color(0xFFFFD54F), Color(0xFFFFC107), Color(0xFFFFA000)],
    'lime': [Color(0xFFDCE775), Color(0xFFCDDC39), Color(0xFFAFB42B)],
    'deepPurple': [Color(0xFF9575CD), Color(0xFF673AB7), Color(0xFF512DA8)],
    'brown': [Color(0xFFA1887F), Color(0xFF795548), Color(0xFF5D4037)],
    'blueGrey': [Color(0xFF90A4AE), Color(0xFF607D8B), Color(0xFF455A64)],
  };

  // Sign-in page colors
  static SignInColors signInColors(bool isDark) {
    return isDark ? SignInColors.dark() : SignInColors.light();
  }
}

/// Colors for Sign-in page that adapt to light/dark mode
class SignInColors {
  final Color textPrimary;
  final Color textSecondary;
  final Color inputBackground;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color buttonText;
  final Color error;
  final Color divider;
  final List<Color> backgroundGradient;

  const SignInColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.buttonText,
    required this.error,
    required this.divider,
    required this.backgroundGradient,
  });

  factory SignInColors.light() {
    return SignInColors(
      textPrimary: Colors.white,
      textSecondary: Colors.white.withValues(alpha: 0.7),
      inputBackground: Colors.white.withValues(alpha: 0.12),
      inputBorder: Colors.white.withValues(alpha: 0.2),
      inputBorderFocused: Colors.white.withValues(alpha: 0.6),
      buttonText: const Color(0xFF1E88E5),
      error: Colors.red.shade400,
      divider: Colors.white.withValues(alpha: 0.3),
      backgroundGradient: AppColors.defaultGradientLight,
    );
  }

  factory SignInColors.dark() {
    return SignInColors(
      textPrimary: Colors.white,
      textSecondary: Colors.white.withValues(alpha: 0.7),
      inputBackground: Colors.white.withValues(alpha: 0.08),
      inputBorder: Colors.white.withValues(alpha: 0.15),
      inputBorderFocused: Colors.white.withValues(alpha: 0.5),
      buttonText: const Color(0xFF0D47A1),
      error: Colors.red.shade300,
      divider: Colors.white.withValues(alpha: 0.2),
      backgroundGradient: AppColors.defaultGradientDark,
    );
  }
}
