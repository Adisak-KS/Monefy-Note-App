import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeSelectorDialog extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemeSelectorDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required ThemeMode currentTheme,
    required ValueChanged<ThemeMode> onThemeChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeSelectorDialog(
        currentTheme: currentTheme,
        onThemeChanged: onThemeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'settings.theme'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'settings.theme_description'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: 'settings.theme_light'.tr(),
                  isSelected: currentTheme == ThemeMode.light,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onThemeChanged(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: 'settings.theme_dark'.tr(),
                  isSelected: currentTheme == ThemeMode.dark,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onThemeChanged(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                _ThemeOption(
                  icon: Icons.settings_suggest_rounded,
                  label: 'settings.theme_system'.tr(),
                  isSelected: currentTheme == ThemeMode.system,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onThemeChanged(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? null
                : Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
