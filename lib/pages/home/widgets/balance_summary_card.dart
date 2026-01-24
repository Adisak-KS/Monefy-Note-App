import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/models/currency.dart';
import '../../../core/theme/app_colors.dart';

class BalanceSummaryCard extends StatefulWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const BalanceSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  State<BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<BalanceSummaryCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = context.watch<CurrencyCubit>().state;
    final currencyFormat = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: (currency == Currency.jpy || currency == Currency.krw || currency == Currency.vnd) ? 0 : 2,
    );

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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(-10, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Main gradient background - use Positioned.fill to ensure it fills the stack
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              theme.colorScheme.primary.withValues(alpha: 0.9),
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                              theme.colorScheme.secondary.withValues(alpha: 0.6),
                            ]
                          : [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.85),
                              theme.colorScheme.secondary.withValues(alpha: 0.75),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Animated floating circles
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -40 + (_floatAnimation.value * 10),
                          right: -40 + (_floatAnimation.value * 5),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30 - (_floatAnimation.value * 8),
                          left: -30 + (_floatAnimation.value * 5),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.12),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 60 + (_floatAnimation.value * 6),
                          right: 80,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Shimmer effect overlay
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: [
                            _shimmerAnimation.value - 0.3,
                            _shimmerAnimation.value,
                            _shimmerAnimation.value + 0.3,
                          ].map((e) => e.clamp(0.0, 1.0)).toList(),
                          transform: const GradientRotation(math.pi / 4),
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'home.today_balance'.tr(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        _TrendBadge(balance: widget.balance),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _AnimatedCounter(
                      value: widget.balance,
                      formatter: currencyFormat,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryItem(
                              icon: Icons.south_west_rounded,
                              label: 'home.income'.tr(),
                              amount: currencyFormat.format(widget.totalIncome),
                              iconColor: AppColors.incomeLight,
                              iconBgColor: AppColors.incomeLight.withValues(alpha: 0.2),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: _SummaryItem(
                              icon: Icons.north_east_rounded,
                              label: 'home.expense'.tr(),
                              amount: currencyFormat.format(widget.totalExpense),
                              iconColor: AppColors.expenseLight,
                              iconBgColor: AppColors.expenseLight.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final double balance;

  const _TrendBadge({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.incomeLight.withValues(alpha: 0.2)
            : AppColors.expenseLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive
              ? AppColors.incomeLight.withValues(alpha: 0.3)
              : AppColors.expenseLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isPositive ? AppColors.incomeLight : AppColors.expenseLight,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isPositive ? 'home.profit'.tr() : 'home.loss'.tr(),
            style: TextStyle(
              color: isPositive ? AppColors.incomeLight : AppColors.expenseLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  final double value;
  final NumberFormat formatter;
  final TextStyle style;

  const _AnimatedCounter({
    required this.value,
    required this.formatter,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          formatter.format(animatedValue),
          style: style,
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color iconColor;
  final Color? iconBgColor;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBgColor ?? iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
