import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  /// Show a themed snackbar with consistent styling
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    bool hapticFeedback = true,
  }) {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _getColors(type, isDark);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon ?? _getDefaultIcon(type),
                color: colors.icon,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: colors.action,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction();
                },
              )
            : null,
      ),
    );
  }

  /// Show success snackbar
  static void success(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.success,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show error snackbar
  static void error(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show warning snackbar
  static void warning(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.warning,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show info snackbar
  static void info(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show undo snackbar for deleted items
  static void showUndo(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    String undoLabel = 'Undo',
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      icon: Icons.delete_outline_rounded,
      actionLabel: undoLabel,
      onAction: onUndo,
      duration: duration,
    );
  }

  static IconData _getDefaultIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline_rounded;
      case SnackbarType.error:
        return Icons.error_outline_rounded;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.info:
        return Icons.info_outline_rounded;
    }
  }

  static _SnackbarColors _getColors(SnackbarType type, bool isDark) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarColors(
          background: isDark
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.success.withValues(alpha: 0.1),
          icon: AppColors.success,
          iconBg: AppColors.success.withValues(alpha: 0.2),
          text: isDark ? Colors.white : Colors.black87,
          border: AppColors.success.withValues(alpha: 0.3),
          action: AppColors.success,
        );
      case SnackbarType.error:
        return _SnackbarColors(
          background: isDark
              ? AppColors.error.withValues(alpha: 0.15)
              : AppColors.error.withValues(alpha: 0.1),
          icon: AppColors.error,
          iconBg: AppColors.error.withValues(alpha: 0.2),
          text: isDark ? Colors.white : Colors.black87,
          border: AppColors.error.withValues(alpha: 0.3),
          action: AppColors.error,
        );
      case SnackbarType.warning:
        return _SnackbarColors(
          background: isDark
              ? AppColors.warning.withValues(alpha: 0.15)
              : AppColors.warning.withValues(alpha: 0.1),
          icon: AppColors.warning,
          iconBg: AppColors.warning.withValues(alpha: 0.2),
          text: isDark ? Colors.white : Colors.black87,
          border: AppColors.warning.withValues(alpha: 0.3),
          action: AppColors.warningDark,
        );
      case SnackbarType.info:
        return _SnackbarColors(
          background: isDark
              ? AppColors.info.withValues(alpha: 0.15)
              : AppColors.info.withValues(alpha: 0.1),
          icon: AppColors.info,
          iconBg: AppColors.info.withValues(alpha: 0.2),
          text: isDark ? Colors.white : Colors.black87,
          border: AppColors.info.withValues(alpha: 0.3),
          action: AppColors.info,
        );
    }
  }
}

class _SnackbarColors {
  final Color background;
  final Color icon;
  final Color iconBg;
  final Color text;
  final Color border;
  final Color action;

  const _SnackbarColors({
    required this.background,
    required this.icon,
    required this.iconBg,
    required this.text,
    required this.border,
    required this.action,
  });
}
