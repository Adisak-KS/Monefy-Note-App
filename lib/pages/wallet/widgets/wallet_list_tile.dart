import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/models/currency.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/wallet_type.dart';

class WalletListTile extends StatefulWidget {
  final Wallet wallet;
  final int index;
  final bool hideBalance;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onTransfer;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const WalletListTile({
    super.key,
    required this.wallet,
    required this.index,
    this.hideBalance = false,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onTransfer,
    this.onArchive,
    this.onDelete,
  });

  @override
  State<WalletListTile> createState() => _WalletListTileState();
}

class _WalletListTileState extends State<WalletListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500 + (widget.index * 80)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseColor(String? colorHex) {
    if (colorHex != null) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return _getDefaultColor(widget.wallet.type);
  }

  Color _getDefaultColor(WalletType type) => type.color;

  IconData _getWalletIcon(WalletType type) => type.icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(widget.wallet.color);
    final isDark = theme.brightness == Brightness.dark;
    final isDebt = widget.wallet.type.isLiability;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Slidable(
              key: Key(widget.wallet.id),
              startActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.4,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) {
                      HapticFeedback.lightImpact();
                      widget.onEdit?.call();
                    },
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_rounded, size: 22),
                        const SizedBox(height: 4),
                        Text('common.edit'.tr(),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (_) {
                      HapticFeedback.lightImpact();
                      widget.onDuplicate?.call();
                    },
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy_rounded, size: 22),
                        const SizedBox(height: 4),
                        Text('wallet.duplicate'.tr(),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.6,
                children: [
                  CustomSlidableAction(
                    onPressed: widget.onTransfer != null
                        ? (_) {
                            HapticFeedback.lightImpact();
                            widget.onTransfer?.call();
                          }
                        : null,
                    backgroundColor: widget.onTransfer != null
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swap_horiz_rounded, size: 22),
                        const SizedBox(height: 4),
                        Text('wallet.transfer'.tr(),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (_) {
                      HapticFeedback.lightImpact();
                      widget.onArchive?.call();
                    },
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.archive_rounded, size: 22),
                        const SizedBox(height: 4),
                        Text('wallet.archive'.tr(),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (_) {
                      HapticFeedback.mediumImpact();
                      widget.onDelete?.call();
                    },
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_rounded, size: 22),
                        const SizedBox(height: 4),
                        Text('common.delete'.tr(),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap?.call();
                },
                child: AnimatedScale(
                  scale: _isPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF1E293B),
                                const Color(0xFF293548),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFFAFAFA),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon with gradient
                        _buildIconContainer(color),
                        const SizedBox(width: 14),
                        // Info
                        Expanded(
                          child: _buildWalletInfo(theme, color),
                        ),
                        // Balance & Actions
                        _buildBalanceSection(theme, color, isDebt),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner glow effect
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
          ),
          Icon(
            _getWalletIcon(widget.wallet.type),
            color: Colors.white,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo(ThemeData theme, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                widget.wallet.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!widget.wallet.includeInTotal) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: 'wallet.excluded_from_total'.tr(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.visibility_off_rounded,
                    size: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getWalletIcon(widget.wallet.type),
                size: 10,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                _getTypeName(widget.wallet.type),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSection(ThemeData theme, Color color, bool isDebt) {
    final currency = context.watch<CurrencyCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.hideBalance
                ? '${currency.symbol} ••••'
                : _formatCurrency(widget.wallet.balance, currency),
            key: ValueKey(widget.hideBalance ? 'hidden' : widget.wallet.balance),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDebt ? const Color(0xFFEF4444) : color,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showOptionsMenu(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.more_horiz_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _parseColor(widget.wallet.color);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
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
            // Wallet preview
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getWalletIcon(widget.wallet.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlocBuilder<CurrencyCubit, Currency>(
                      builder: (context, currency) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.wallet.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatCurrency(widget.wallet.balance, currency),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            _buildActionTile(
              context: context,
              icon: Icons.edit_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: 'common.edit'.tr(),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),
            _buildActionTile(
              context: context,
              icon: Icons.delete_rounded,
              iconColor: const Color(0xFFEF4444),
              title: 'common.delete'.tr(),
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? iconColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount, Currency currency) {
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: (currency == Currency.jpy || currency == Currency.krw || currency == Currency.vnd) ? 0 : 2,
    );
    return formatter.format(amount.abs());
  }
}
