import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/wallet_type.dart';
import '../../../core/theme/app_colors.dart';

class WalletGroupHeader extends StatefulWidget {
  final WalletType type;
  final double totalBalance;
  final int walletCount;
  final bool isExpanded;
  final bool hideBalance;
  final VoidCallback? onTap;

  const WalletGroupHeader({
    super.key,
    required this.type,
    required this.totalBalance,
    required this.walletCount,
    this.isExpanded = true,
    this.hideBalance = false,
    this.onTap,
  });

  @override
  State<WalletGroupHeader> createState() => _WalletGroupHeaderState();
}

class _WalletGroupHeaderState extends State<WalletGroupHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    if (!widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(WalletGroupHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.type.color;
    final isDebt = widget.type.isLiability;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08),
                    ]
                  : [
                      color.withValues(alpha: 0.08),
                      color.withValues(alpha: 0.03),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  widget.type.icon,
                  color: ColorUtils.getContrastColor(color),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Type info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeName(widget.type),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.walletCount} ${'wallet.wallet_count'.tr()}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      widget.hideBalance
                          ? '฿ ••••'
                          : _formatCurrency(widget.totalBalance),
                      key: ValueKey(
                          widget.hideBalance ? 'hidden' : widget.totalBalance),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDebt ? const Color(0xFFEF4444) : color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Animated arrow
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeName(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'wallet.type_cash'.tr();
      case WalletType.bank:
        return 'wallet.type_bank'.tr();
      case WalletType.creditCard:
        return 'wallet.type_credit_card'.tr();
      case WalletType.eWallet:
        return 'wallet.type_ewallet'.tr();
      case WalletType.investment:
        return 'wallet.type_investment'.tr();
      case WalletType.debt:
        return 'wallet.type_debt'.tr();
      case WalletType.crypto:
        return 'wallet.type_crypto'.tr();
      case WalletType.savings:
        return 'wallet.type_savings'.tr();
      case WalletType.loan:
        return 'wallet.type_loan'.tr();
      case WalletType.insurance:
        return 'wallet.type_insurance'.tr();
      case WalletType.gold:
        return 'wallet.type_gold'.tr();
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '\u0E3F',
      decimalDigits: 2,
    );
    return formatter.format(amount.abs());
  }
}
