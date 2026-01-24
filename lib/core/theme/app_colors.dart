import 'package:flutter/material.dart';

// ============================================
// SPACING CONSTANTS
// ============================================
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// ============================================
// BORDER RADIUS CONSTANTS
// ============================================
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
  static const double pill = 50;

  // Convenience BorderRadius
  static final BorderRadius xsAll = BorderRadius.circular(xs);
  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius xxlAll = BorderRadius.circular(xxl);
  static final BorderRadius xxxlAll = BorderRadius.circular(xxxl);
  static final BorderRadius pillAll = BorderRadius.circular(pill);
}

// ============================================
// ANIMATION DURATION CONSTANTS
// ============================================
class AppDurations {
  AppDurations._();

  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 600);

  // Specific use cases
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration tooltip = Duration(milliseconds: 200);
  static const Duration snackbar = Duration(seconds: 3);
}

// ============================================
// COLORS
// ============================================
class AppColors {
  AppColors._();

  // Default Theme Colors (Blue)
  static const defaultPrimary = Color(0xFF1E88E5);

  // ============================================
  // SEMANTIC COLORS - Income/Expense
  // ============================================
  static const Color income = Color(0xFF22C55E);
  static const Color incomeDark = Color(0xFF16A34A);
  static const Color incomeLight = Color(0xFF4ADE80);
  static const List<Color> incomeGradient = [income, incomeDark];

  static const Color expense = Color(0xFFEF4444);
  static const Color expenseDark = Color(0xFFDC2626);
  static const Color expenseLight = Color(0xFFF87171);
  static const List<Color> expenseGradient = [expense, expenseDark];

  // Alternative expense colors (pink style)
  static const Color expensePink = Color(0xFFE91E63);
  static const Color expensePinkDark = Color(0xFFC2185B);

  // ============================================
  // STATUS COLORS
  // ============================================
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);

  // Network status colors
  static const Color networkOffline = Color(0xFFE53935);
  static const Color networkOnline = Color(0xFF43A047);

  // ============================================
  // BACKGROUND COLORS - Dark Mode
  // ============================================
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardAlt = Color(0xFF293548);
  static const Color darkDialog = Color(0xFF1E1E2E);
  static const Color darkDialogAlt = Color(0xFF1A1A2E);
  static const Color darkSheet = Color(0xFF1A1F2E);

  static const List<Color> darkBackgroundGradient = [
    Color(0xFF0D1117),
    Color(0xFF161B22),
    Color(0xFF0D1117),
  ];

  // ============================================
  // BACKGROUND COLORS - Light Mode
  // ============================================
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFAFAFA);
  static const Color lightButtonGradientEnd = Color(0xFFF0F0F0);

  static const List<Color> lightBackgroundGradient = [
    Color(0xFFF8FAFC),
    Color(0xFFFFFFFF),
    Color(0xFFF1F5F9),
  ];

  // ============================================
  // ACCENT COLORS
  // ============================================
  // Purple
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF6D28D9);
  static const Color purpleAlt = Color(0xFF7C3AED);
  static const Color purpleViolet = Color(0xFFA855F7);
  static const List<Color> purpleGradient = [purple, purpleDark];

  // Blue
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueDark = Color(0xFF2563EB);
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoAlt = Color(0xFF667EEA);
  static const Color indigoDark = Color(0xFF764BA2);
  static const List<Color> indigoGradient = [indigoAlt, indigoDark, Color(0xFF6B8DD6)];

  // Cyan
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanDark = Color(0xFF0891B2);
  static const Color sky = Color(0xFF0EA5E9);

  // Amber/Orange
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeAlt = Color(0xFFFB923C);
  static const List<Color> amberGradient = [amber, amberDark];

  // Pink/Rose
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFF472B6);
  static const Color rose = Color(0xFFE11D48);

  // Teal/Emerald
  static const Color teal = Color(0xFF14B8A6);
  static const Color emerald = Color(0xFF10B981);

  // Other
  static const Color lime = Color(0xFF84CC16);
  static const Color stone = Color(0xFF78716C);

  // Debt gradient
  static const List<Color> debtGradient = [Color(0xFFEB5757), Color(0xFFC53030), Color(0xFFEB5757)];

  // ============================================
  // CHART PALETTE
  // ============================================
  static const List<Color> chartPalette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Red
    Color(0xFF84CC16), // Lime
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
  ];

  static const List<Color> chartPaletteAlt = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFDDA0DD),
    Color(0xFF98D8C8),
    Color(0xFF6C5CE7),
    Color(0xFFFD79A8),
    Color(0xFF00B894),
    Color(0xFFE17055),
  ];

  // ============================================
  // WALLET TYPE COLORS
  // ============================================
  static const List<Color> walletColorPalette = [
    Color(0xFF22C55E), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFF10B981), // Emerald
    Color(0xFF6366F1), // Indigo
    Color(0xFFF97316), // Orange
    Color(0xFF84CC16), // Lime
    Color(0xFFA855F7), // Violet
    Color(0xFF0EA5E9), // Sky
    Color(0xFFE11D48), // Rose
    Color(0xFF78716C), // Stone
  ];

  // ============================================
  // MEDAL COLORS (for rankings)
  // ============================================
  static const Color gold = Color(0xFFFFD700);
  static const Color goldAlt = Color(0xFF808080);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // ============================================
  // EXPORT FORMAT COLORS
  // ============================================
  static const Color excel = Color(0xFF217346);
  static const Color csv = Color(0xFF0277BD);
  static const Color pdf = Color(0xFFD32F2F);

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
