import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/drawer_stats_cubit.dart';
import '../bloc/drawer_stats_state.dart';
import '../theme/theme_cubit.dart';
import '../../pages/settings/widgets/theme_selector_dialog.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _menuController;
  late Animation<double> _headerAnimation;
  late List<Animation<double>> _menuAnimations;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );

    // Create staggered animations for menu items
    _menuAnimations = List.generate(12, (index) {
      final start = index * 0.06;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _menuController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      );
    });

    _headerController.forward();
    _menuController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with gradient background
            _buildHeader(context, theme, isDark),
            // Stats Row
            FadeTransition(
              opacity: _headerAnimation,
              child: _buildStatsRow(context, theme),
            ),
            const SizedBox(height: 8),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildAnimatedMenuItem(0, theme, Icons.account_balance_wallet_rounded, 'nav.wallet'.tr(), () => _showComingSoon(context)),
                  _buildAnimatedMenuItem(1, theme, Icons.bar_chart_rounded, 'nav.statistics'.tr(), () => _showComingSoon(context)),
                  _buildAnimatedMenuItem(2, theme, Icons.category_rounded, 'drawer.categories'.tr(), () => _navigateTo(context, '/categories')),
                  _buildAnimatedMenuItem(3, theme, Icons.savings_rounded, 'drawer.budgets'.tr(), () => _navigateTo(context, '/budgets')),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, 'drawer.preferences'.tr(), 4),
                  _buildAnimatedThemeToggle(context, theme, isDark, 5),
                  _buildAnimatedLanguageSelector(context, theme, 6),
                  _buildAnimatedMenuItem(7, theme, Icons.notifications_outlined, 'drawer.notifications'.tr(), () => _showComingSoon(context)),
                  _buildAnimatedMenuItem(8, theme, Icons.security_rounded, 'drawer.security'.tr(), () => _navigateTo(context, '/security-setup')),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, 'drawer.about'.tr(), 9),
                  _buildAnimatedMenuItem(10, theme, Icons.help_outline_rounded, 'drawer.help'.tr(), () => _showComingSoon(context)),
                  _buildAnimatedMenuItem(11, theme, Icons.info_outline_rounded, 'drawer.about_app'.tr(), () => _showAboutDialog(context), subtitle: 'v1.0.0'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Logout Button
            FadeTransition(
              opacity: _headerAnimation,
              child: _buildLogoutButton(context, theme),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
                ]
              : [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: ScaleTransition(
              scale: _headerAnimation,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with animated border
                  _buildAnimatedAvatar(theme),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'drawer.guest'.tr(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Premium badge
                        _buildPremiumBadge(theme),
                      ],
                    ),
                  ),
                  // Settings button
                  _buildSettingsButton(context, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAvatar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
            theme.colorScheme.tertiary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade600,
            Colors.orange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            'drawer.free_plan'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          // Navigate to settings
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.settings_rounded,
            size: 22,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ThemeData theme) {
    return BlocBuilder<DrawerStatsCubit, DrawerStatsState>(
      builder: (context, state) {
        return _buildStatsContent(
          theme,
          state.totalIncome,
          state.totalExpense,
          state.transactionCount,
        );
      },
    );
  }

  Widget _buildStatsContent(
    ThemeData theme,
    double income,
    double expense,
    int transactionCount,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildStatItem(
            theme,
            Icons.arrow_downward_rounded,
            Colors.green,
            '฿${_formatNumber(income)}',
            'home.income'.tr(),
          ),
          _buildVerticalDivider(theme),
          _buildStatItem(
            theme,
            Icons.arrow_upward_rounded,
            Colors.red,
            '฿${_formatNumber(expense)}',
            'home.expense'.tr(),
          ),
          _buildVerticalDivider(theme),
          _buildStatItem(
            theme,
            Icons.receipt_long_rounded,
            theme.colorScheme.primary,
            '$transactionCount',
            'home.transactions'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 40,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildSectionHeader(ThemeData theme, String title, int index) {
    return FadeTransition(
      opacity: index < _menuAnimations.length ? _menuAnimations[index] : const AlwaysStoppedAnimation(1),
      child: SlideTransition(
        position: index < _menuAnimations.length
            ? Tween<Offset>(
                begin: const Offset(-0.2, 0),
                end: Offset.zero,
              ).animate(_menuAnimations[index])
            : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuItem(
    int index,
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return FadeTransition(
      opacity: index < _menuAnimations.length ? _menuAnimations[index] : const AlwaysStoppedAnimation(1),
      child: SlideTransition(
        position: index < _menuAnimations.length
            ? Tween<Offset>(
                begin: const Offset(-0.3, 0),
                end: Offset.zero,
              ).animate(_menuAnimations[index])
            : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (subtitle != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedThemeToggle(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    int index,
  ) {
    return FadeTransition(
      opacity: index < _menuAnimations.length ? _menuAnimations[index] : const AlwaysStoppedAnimation(1),
      child: SlideTransition(
        position: index < _menuAnimations.length
            ? Tween<Offset>(
                begin: const Offset(-0.3, 0),
                end: Offset.zero,
              ).animate(_menuAnimations[index])
            : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
                final themeCubit = context.read<ThemeCubit>();
                ThemeSelectorDialog.show(
                  context,
                  currentTheme: themeCubit.state,
                  onThemeChanged: (mode) {
                    themeCubit.setTheme(mode);
                  },
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [Colors.indigo.withValues(alpha: 0.3), Colors.purple.withValues(alpha: 0.2)]
                              : [Colors.amber.withValues(alpha: 0.3), Colors.orange.withValues(alpha: 0.2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        size: 20,
                        color: isDark ? Colors.indigo.shade300 : Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'setting.theme'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.indigo.withValues(alpha: 0.2)
                            : Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.indigo.withValues(alpha: 0.3)
                              : Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            size: 14,
                            color: isDark ? Colors.indigo.shade200 : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isDark
                                ? 'onboarding.theme.dark'.tr()
                                : 'onboarding.theme.light'.tr(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.indigo.shade200 : Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLanguageSelector(BuildContext context, ThemeData theme, int index) {
    final currentLocale = context.locale;
    final isEnglish = currentLocale.languageCode == 'en';

    return FadeTransition(
      opacity: index < _menuAnimations.length ? _menuAnimations[index] : const AlwaysStoppedAnimation(1),
      child: SlideTransition(
        position: index < _menuAnimations.length
            ? Tween<Offset>(
                begin: const Offset(-0.3, 0),
                end: Offset.zero,
              ).animate(_menuAnimations[index])
            : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _showLanguageDialog(context, theme);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withValues(alpha: 0.2),
                            Colors.cyan.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.translate_rounded,
                        size: 20,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'setting.language'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isEnglish ? '🇺🇸' : '🇹🇭',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isEnglish ? 'EN' : 'TH',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguagePickerSheet(
        currentLocale: context.locale,
        onSelect: (locale) {
          context.setLocale(locale);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            // Handle logout
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'auth.sign_out'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context);
    context.push(route);
  }

  void _showComingSoon(BuildContext context) {
    Navigator.pop(context);
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
            Text('common.coming_soon'.tr()),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'app.name'.tr(),
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.attach_money, color: Colors.white, size: 28),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onSelect;

  const _LanguagePickerSheet({
    required this.currentLocale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languages = [
      (const Locale('en', 'US'), 'English', '🇺🇸', 'United States'),
      (const Locale('th', 'TH'), 'ไทย', '🇹🇭', 'ประเทศไทย'),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.translate_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'setting.language'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: languages.map((lang) {
                final isSelected = currentLocale.languageCode == lang.$1.languageCode;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Material(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelect(lang.$1);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  lang.$3,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.$2,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    lang.$4,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
