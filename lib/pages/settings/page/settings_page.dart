import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/models/currency.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/color_cubit.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/widgets/page_gradient_background.dart';
import '../../../core/widgets/skeleton/skeleton.dart';
import '../../../injection.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector_dialog.dart';
import '../widgets/language_selector_dialog.dart';
import '../widgets/color_selector_dialog.dart';
import '../widgets/currency_selector_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..loadSettings(),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatefulWidget {
  const _SettingsPageContent();

  @override
  State<_SettingsPageContent> createState() => _SettingsPageContentState();
}

class _SettingsPageContentState extends State<_SettingsPageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const PageGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      if (state is SettingsLoading) {
                        return const _LoadingState();
                      }

                      if (state is SettingsError) {
                        return _ErrorState(message: state.message);
                      }

                      if (state is SettingsLoaded) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildContent(context, state),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'settings.title'.tr(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, SettingsLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // Appearance Section
          SettingsSection(
            title: 'settings.appearance'.tr(),
            children: [
              SettingsValueTile(
                icon: Icons.palette_outlined,
                title: 'settings.theme'.tr(),
                value: _getThemeLabel(state.themeMode),
                onTap: () => _showThemeSelector(context, state),
              ),
              BlocBuilder<ColorCubit, AppColor>(
                builder: (context, appColor) {
                  return SettingsValueTile(
                    icon: Icons.color_lens_outlined,
                    title: 'settings.color'.tr(),
                    value: appColor.nameKey.tr(),
                    onTap: () => _showColorSelector(context, appColor),
                  );
                },
              ),
            ],
          ),

          // Management Section
          SettingsSection(
            title: 'settings.management'.tr(),
            children: [
              SettingsTile(
                icon: Icons.category_rounded,
                iconColor: Colors.indigo,
                title: 'settings.categories'.tr(),
                subtitle: 'settings.categories_description'.tr(),
                showArrow: true,
                onTap: () => context.push('/categories'),
              ),
              SettingsTile(
                icon: Icons.savings_rounded,
                iconColor: Colors.teal,
                title: 'settings.budgets'.tr(),
                subtitle: 'settings.budgets_description'.tr(),
                showArrow: true,
                onTap: () => context.push('/budgets'),
              ),
            ],
          ),

          // Language & Region Section
          SettingsSection(
            title: 'settings.language_region'.tr(),
            children: [
              SettingsValueTile(
                icon: Icons.language_rounded,
                title: 'settings.language'.tr(),
                value: _getLanguageLabel(state.locale),
                onTap: () => _showLanguageSelector(context, state),
              ),
              BlocBuilder<CurrencyCubit, Currency>(
                builder: (context, currency) {
                  return SettingsTile(
                    icon: Icons.attach_money_rounded,
                    iconColor: Colors.green,
                    title: 'settings.currency'.tr(),
                    subtitle: 'settings.currency_description'.tr(),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${currency.flag} ${currency.code}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    onTap: () => _showCurrencySelector(context, currency),
                  );
                },
              ),
            ],
          ),

          // Security Section
          SettingsSection(
            title: 'settings.security'.tr(),
            children: [
              SettingsTile(
                icon: Icons.lock_outline_rounded,
                iconColor: Colors.orange,
                title: 'settings.app_lock'.tr(),
                subtitle: state.isSecurityEnabled
                    ? _getSecurityTypeLabel(state.securityType)
                    : 'settings.not_configured'.tr(),
                showArrow: true,
                onTap: () => context.push('/security-setup'),
              ),
              if (state.isSecurityEnabled)
                SettingsSwitchTile(
                  icon: Icons.fingerprint_rounded,
                  iconColor: Colors.purple,
                  title: 'settings.biometric'.tr(),
                  subtitle: 'settings.biometric_description'.tr(),
                  value: state.isBiometricEnabled,
                  onChanged: (value) {
                    context.read<SettingsCubit>().setBiometricEnabled(value);
                  },
                ),
            ],
          ),

          // Data Section
          SettingsSection(
            title: 'settings.data'.tr(),
            children: [
              SettingsTile(
                icon: Icons.cloud_upload_outlined,
                iconColor: Colors.blue,
                title: 'settings.backup'.tr(),
                subtitle: 'settings.backup_description'.tr(),
                showArrow: true,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              SettingsTile(
                icon: Icons.file_download_outlined,
                iconColor: Colors.teal,
                title: 'settings.export'.tr(),
                subtitle: 'settings.export_description'.tr(),
                showArrow: true,
                onTap: () {
                  context.push('/export');
                },
              ),
              SettingsTile(
                icon: Icons.delete_sweep_outlined,
                iconColor: Colors.red,
                title: 'settings.clear_cache'.tr(),
                subtitle: 'settings.clear_cache_description'.tr(),
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
            ],
          ),

          // About Section
          SettingsSection(
            title: 'settings.about'.tr(),
            children: [
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'settings.app_version'.tr(),
                subtitle: state.appVersion,
              ),
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'settings.privacy_policy'.tr(),
                showArrow: true,
                onTap: () => context.push('/privacy-policy'),
              ),
              SettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: Colors.blue,
                title: 'settings.help_support'.tr(),
                showArrow: true,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              SettingsTile(
                icon: Icons.star_outline_rounded,
                iconColor: Colors.amber,
                title: 'settings.rate_app'.tr(),
                showArrow: true,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'settings.theme_light'.tr();
      case ThemeMode.dark:
        return 'settings.theme_dark'.tr();
      case ThemeMode.system:
        return 'settings.theme_system'.tr();
    }
  }

  String _getLanguageLabel(Locale locale) {
    if (locale.languageCode == 'th') {
      return 'ไทย';
    }
    return 'English';
  }

  String _getSecurityTypeLabel(dynamic securityType) {
    if (securityType == null) return '';
    final type = securityType.toString().split('.').last;
    switch (type) {
      case 'pin':
        return 'settings.security_pin'.tr();
      case 'pattern':
        return 'settings.security_pattern'.tr();
      case 'password':
        return 'settings.security_password'.tr();
      default:
        return '';
    }
  }

  void _showThemeSelector(BuildContext context, SettingsLoaded state) {
    final settingsCubit = context.read<SettingsCubit>();
    final themeCubit = context.read<ThemeCubit>();

    ThemeSelectorDialog.show(
      context,
      currentTheme: state.themeMode,
      onThemeChanged: (mode) {
        settingsCubit.setThemeMode(mode);
        themeCubit.setTheme(mode);
      },
    );
  }

  void _showLanguageSelector(BuildContext context, SettingsLoaded state) {
    final settingsCubit = context.read<SettingsCubit>();
    final localeCubit = context.read<LocalCubit>();

    LanguageSelectorDialog.show(
      context,
      currentLocale: state.locale,
      onLocaleChanged: (locale) {
        settingsCubit.setLocale(locale);
        localeCubit.setLocal(locale);
        context.setLocale(locale);
      },
    );
  }

  void _showColorSelector(BuildContext context, AppColor currentColor) {
    final colorCubit = context.read<ColorCubit>();

    ColorSelectorDialog.show(
      context,
      currentColor: currentColor,
      onColorChanged: (color) {
        colorCubit.setColor(color);
      },
    );
  }

  void _showCurrencySelector(BuildContext context, Currency currentCurrency) {
    final currencyCubit = context.read<CurrencyCubit>();

    CurrencySelectorDialog.show(
      context,
      currentCurrency: currentCurrency,
      onCurrencyChanged: (currency) {
        currencyCubit.setCurrency(currency);
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.construction_rounded,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text('settings.coming_soon'.tr()),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('settings.clear_cache'.tr()),
        content: Text('settings.clear_cache_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text('settings.cache_cleared'.tr()),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Text('common.confirm'.tr()),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SkeletonSettingsPage();
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'common.error'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<SettingsCubit>().loadSettings();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
