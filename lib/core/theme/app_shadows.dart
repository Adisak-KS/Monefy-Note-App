import 'package:flutter/material.dart';

/// Soft shadow utilities for modern UI design
class AppShadows {
  AppShadows._();

  // ============================================
  // SOFT SHADOWS (Light Mode)
  // ============================================

  /// Extra small soft shadow - for chips, small buttons
  static List<BoxShadow> softXs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return darkXs;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Small soft shadow - for cards, tiles
  static List<BoxShadow> softSm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return darkSm;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Medium soft shadow - for floating elements
  static List<BoxShadow> softMd(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return darkMd;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  /// Large soft shadow - for modals, dialogs
  static List<BoxShadow> softLg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return darkLg;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 40,
        offset: const Offset(0, 20),
      ),
    ];
  }

  /// Extra large soft shadow - for FABs, prominent elements
  static List<BoxShadow> softXl(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return darkXl;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 30,
        offset: const Offset(0, 15),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 60,
        offset: const Offset(0, 30),
      ),
    ];
  }

  // ============================================
  // COLORED SHADOWS (Light Mode Only)
  // ============================================

  /// Colored soft shadow based on color
  static List<BoxShadow> colored(Color color, {double intensity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.6),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.3),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  /// Primary color shadow
  static List<BoxShadow> primary(BuildContext context, {double intensity = 0.3}) {
    final color = Theme.of(context).colorScheme.primary;
    return colored(color, intensity: intensity);
  }

  /// Success (green) shadow
  static List<BoxShadow> success({double intensity = 0.3}) {
    return colored(const Color(0xFF22C55E), intensity: intensity);
  }

  /// Error (red) shadow
  static List<BoxShadow> error({double intensity = 0.3}) {
    return colored(const Color(0xFFEF4444), intensity: intensity);
  }

  // ============================================
  // DARK MODE SHADOWS
  // ============================================

  static const List<BoxShadow> darkXs = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x70000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> darkXl = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  // ============================================
  // INNER SHADOWS (for pressed states)
  // ============================================

  /// Inset shadow effect for pressed buttons
  static List<BoxShadow> inset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
        blurStyle: BlurStyle.inner,
      ),
    ];
  }

  // ============================================
  // GLOW EFFECTS
  // ============================================

  /// Subtle glow effect
  static List<BoxShadow> glow(Color color, {double intensity = 0.4}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 16,
        spreadRadius: 2,
      ),
    ];
  }

  /// Pulsing glow for attention (use with animation)
  static List<BoxShadow> pulseGlow(Color color, double animationValue) {
    final intensity = 0.2 + (0.3 * animationValue);
    final spread = 4 * animationValue;
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 20,
        spreadRadius: spread,
      ),
    ];
  }
}

/// Extension to easily apply shadows to Container decorations
extension ShadowExtension on BoxDecoration {
  BoxDecoration withSoftShadow(BuildContext context, {String size = 'md'}) {
    final shadows = switch (size) {
      'xs' => AppShadows.softXs(context),
      'sm' => AppShadows.softSm(context),
      'md' => AppShadows.softMd(context),
      'lg' => AppShadows.softLg(context),
      'xl' => AppShadows.softXl(context),
      _ => AppShadows.softMd(context),
    };
    return copyWith(boxShadow: shadows);
  }
}
