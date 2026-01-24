import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/models/currency.dart';
import '../../../core/theme/app_colors.dart';

class BalanceOverviewCard extends StatefulWidget {
  final double totalBalance;
  final double totalDebt;
  final bool hideBalance;
  final VoidCallback? onToggleHide;

  const BalanceOverviewCard({
    super.key,
    required this.totalBalance,
    required this.totalDebt,
    this.hideBalance = false,
    this.onToggleHide,
  });

  @override
  State<BalanceOverviewCard> createState() => _BalanceOverviewCardState();
}

class _BalanceOverviewCardState extends State<BalanceOverviewCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final netWorth = widget.totalBalance - widget.totalDebt;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                // Net Worth Header with Gradient
                _buildNetWorthHeader(theme, isDark, netWorth),
                // Balance & Debt Section
                _buildBalanceDebtSection(theme, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetWorthHeader(ThemeData theme, bool isDark, double netWorth) {
    final isPositive = netWorth >= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? AppColors.indigoGradient
              : AppColors.debtGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles (background)
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content (main - determines Stack size)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'wallet.net_worth'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onToggleHide,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.hideBalance
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<CurrencyCubit, Currency>(
                  builder: (context, currency) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        widget.hideBalance ? '${currency.symbol} ••••••••' : _formatCurrency(netWorth, currency),
                        key: ValueKey(widget.hideBalance ? 'hidden' : netWorth),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPositive ? 'home.profit'.tr() : 'home.loss'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Shimmer overlay (on top, subtle)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1.0 + 3 * _shimmerController.value, 0),
                        end: Alignment(1.0 + 3 * _shimmerController.value, 0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDebtSection(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSheet : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _BalanceItem(
              icon: Icons.arrow_upward_rounded,
              iconGradient: AppColors.incomeGradient,
              label: 'wallet.total_balance'.tr(),
              amount: widget.totalBalance,
              theme: theme,
              isDark: isDark,
              hideBalance: widget.hideBalance,
            ),
          ),
          Container(
            width: 1,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.outline.withValues(alpha: 0),
                  theme.colorScheme.outline.withValues(alpha: 0.2),
                  theme.colorScheme.outline.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Expanded(
            child: _BalanceItem(
              icon: Icons.arrow_downward_rounded,
              iconGradient: AppColors.expenseGradient,
              label: 'wallet.total_debt'.tr(),
              amount: widget.totalDebt,
              theme: theme,
              isDark: isDark,
              isDebt: true,
              hideBalance: widget.hideBalance,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount, Currency currency) {
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: (currency == Currency.jpy || currency == Currency.krw || currency == Currency.vnd) ? 0 : 2,
    );
    return formatter.format(amount);
  }
}

class _BalanceItem extends StatelessWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String label;
  final double amount;
  final ThemeData theme;
  final bool isDark;
  final bool isDebt;
  final bool hideBalance;

  const _BalanceItem({
    required this.icon,
    required this.iconGradient,
    required this.label,
    required this.amount,
    required this.theme,
    required this.isDark,
    this.isDebt = false,
    this.hideBalance = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, Currency>(
      builder: (context, currency) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconGradient[0].withValues(alpha: 0.15),
                    iconGradient[1].withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: iconGradient[0].withValues(alpha: 0.2),
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: iconGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                hideBalance ? '${currency.symbol} ••••' : _formatCurrency(amount, currency),
                key: ValueKey(hideBalance ? 'hidden' : amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDebt ? AppColors.expense : AppColors.income,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(double amount, Currency currency) {
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: (currency == Currency.jpy || currency == Currency.krw || currency == Currency.vnd) ? 0 : 0,
    );
    return formatter.format(amount);
  }
}
