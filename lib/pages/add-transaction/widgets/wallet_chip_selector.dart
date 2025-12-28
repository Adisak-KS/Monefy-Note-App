import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/wallet.dart';

class WalletChipSelector extends StatelessWidget {
  final List<Wallet> wallets;
  final Wallet? selectedWallet;
  final ValueChanged<Wallet> onWalletSelected;

  const WalletChipSelector({
    super.key,
    required this.wallets,
    this.selectedWallet,
    required this.onWalletSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          final isSelected = selectedWallet?.id == wallet.id;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _WalletChip(
              wallet: wallet,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                onWalletSelected(wallet);
              },
            ),
          );
        },
      ),
    );
  }
}

class _WalletChip extends StatefulWidget {
  final Wallet wallet;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletChip({
    required this.wallet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_WalletChip> createState() => _WalletChipState();
}

class _WalletChipState extends State<_WalletChip> {
  bool _isPressed = false;

  IconData _getWalletIcon() {
    switch (widget.wallet.type.name) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'creditCard':
        return Icons.credit_card_rounded;
      case 'eWallet':
        return Icons.phone_android_rounded;
      case 'debt':
        return Icons.money_off_rounded;
      default:
        return Icons.wallet_rounded;
    }
  }

  Color _getWalletColor() {
    if (widget.wallet.color != null) {
      try {
        return Color(
            int.parse(widget.wallet.color!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getWalletColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.85),
                    ],
                  )
                : null,
            color: widget.isSelected
                ? null
                : isDark
                    ? theme.colorScheme.surface.withValues(alpha: 0.8)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getWalletIcon(),
                  size: 16,
                  color: widget.isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.wallet.name,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
