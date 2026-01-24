import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/wallet.dart';
import '../../../core/theme/app_colors.dart';

class CalculatorKeyboard extends StatefulWidget {
  final Color primaryColor;
  final Function(String) onKeyPress;
  final VoidCallback onSave;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final List<Wallet> wallets;
  final Wallet? selectedWallet;
  final ValueChanged<Wallet> onWalletChanged;
  final ValueChanged<double> onQuickAmount;

  const CalculatorKeyboard({
    super.key,
    required this.primaryColor,
    required this.onKeyPress,
    required this.onSave,
    required this.selectedDate,
    required this.onDateChanged,
    required this.wallets,
    this.selectedWallet,
    required this.onWalletChanged,
    required this.onQuickAmount,
  });

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to determine if primary color needs dark text
  bool get _isLightPrimary => ColorUtils.isLightColor(widget.primaryColor);
  Color get _contrastColor => _isLightPrimary ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 16,
            bottom: bottomPadding + 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.primaryColor,
                widget.primaryColor.withValues(alpha: 0.9),
              ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _contrastColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Date selector row
              _buildDateRow(context),
              const SizedBox(height: 10),
              // Quick amount buttons
              _buildQuickAmountRow(context),
              const SizedBox(height: 12),
              // Operators ordered from bottom: +, -, ×, ÷
              _buildKeyRow(context, ['÷', '7', '8', '9', 'C']),
              const SizedBox(height: 10),
              _buildKeyRow(context, ['×', '4', '5', '6', '⌫']),
              const SizedBox(height: 10),
              // Last two rows with tall SAVE button
              _buildLastTwoRows(context),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateLabel(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (selectedDay == today) {
      return 'home.today'.tr();
    } else if (selectedDay == yesterday) {
      return 'home.yesterday'.tr();
    } else {
      final locale = Localizations.localeOf(context).toString();
      return DateFormat('d MMM', locale).format(widget.selectedDate);
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    HapticFeedback.lightImpact();

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: widget.primaryColor,
              onPrimary: Colors.white,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
      widget.onDateChanged(picked);
    }
  }

  String _formatBalance(double balance) {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(1)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(1)}K';
    }
    return balance.toStringAsFixed(0);
  }

  IconData _getWalletIcon(Wallet wallet) {
    switch (wallet.type.name) {
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

  void _showWalletPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'home.wallet'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.wallets.map((wallet) {
                final isSelected = widget.selectedWallet?.id == wallet.id;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getWalletIcon(wallet),
                      color: widget.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    wallet.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '฿${_formatBalance(wallet.balance)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded,
                          color: widget.primaryColor)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onWalletChanged(wallet);
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAmountRow(BuildContext context) {
    final amounts = [100, 500, 1000, 2000, 5000];
    return Row(
      children: amounts.map((amount) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _QuickAmountKey(
              amount: amount,
              primaryColor: widget.primaryColor,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onQuickAmount(amount.toDouble());
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      children: [
        // Date selector
        Expanded(
          child: GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(left: 4, right: 4),
              decoration: BoxDecoration(
                color: _contrastColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: _contrastColor.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getDateLabel(context),
                    style: TextStyle(
                      color: _contrastColor.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _contrastColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Wallet selector
        Expanded(
          child: GestureDetector(
            onTap: () => _showWalletPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(left: 4, right: 4),
              decoration: BoxDecoration(
                color: _contrastColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.selectedWallet != null
                        ? _getWalletIcon(widget.selectedWallet!)
                        : Icons.wallet_rounded,
                    size: 18,
                    color: _contrastColor.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.selectedWallet?.name ?? 'home.wallet'.tr(),
                          style: TextStyle(
                            color: _contrastColor.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.selectedWallet != null)
                          Text(
                            '฿${_formatBalance(widget.selectedWallet!.balance)}',
                            style: TextStyle(
                              color: _contrastColor.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _contrastColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastTwoRows(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - 4 columns with 2 rows
        Expanded(
          flex: 4,
          child: Column(
            children: [
              // Row 1: - 1 2 3
              Row(
                children: ['-', '1', '2', '3'].map((key) {
                  final isOperator = key == '-';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _CalcKey(
                        label: key,
                        isOperator: isOperator,
                        isAction: false,
                        primaryColor: widget.primaryColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onKeyPress(key);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Row 2: + . 0 =
              Row(
                children: ['+', '.', '0', '='].map((key) {
                  final isOperator = key == '+';
                  final isAction = key == '=';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _CalcKey(
                        label: key,
                        isOperator: isOperator,
                        isAction: isAction,
                        primaryColor: widget.primaryColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onKeyPress(key);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Right side - tall SAVE button
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _TallSaveKey(
              primaryColor: widget.primaryColor,
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onSave();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyRow(BuildContext context, List<String?> keys) {
    return Row(
      children: keys.map((key) {
        if (key == null) {
          return const Expanded(child: SizedBox());
        }

        // Special handling for SAVE button
        if (key == 'SAVE') {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _SaveKey(
                primaryColor: widget.primaryColor,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onSave();
                },
              ),
            ),
          );
        }

        final isOperator = '+-×÷'.contains(key);
        final isAction = key == 'C' || key == '⌫' || key == '=';

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _CalcKey(
              label: key,
              isOperator: isOperator,
              isAction: isAction,
              primaryColor: widget.primaryColor,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onKeyPress(key);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalcKey extends StatefulWidget {
  final String label;
  final bool isOperator;
  final bool isAction;
  final Color primaryColor;
  final VoidCallback onTap;

  const _CalcKey({
    required this.label,
    this.isOperator = false,
    this.isAction = false,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_CalcKey> createState() => _CalcKeyState();
}

class _CalcKeyState extends State<_CalcKey> {
  bool _isPressed = false;

  // Helper to get contrast color based on primary color brightness
  bool get _isLightPrimary => ColorUtils.isLightColor(widget.primaryColor);
  Color get _contrastColor => _isLightPrimary ? Colors.black : Colors.white;
  Color get _inverseContrastColor => _isLightPrimary ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (widget.isOperator) {
      // Operator keys: semi-transparent contrast background with contrast text
      bgColor = _contrastColor.withValues(alpha: 0.25);
      textColor = _contrastColor;
    } else if (widget.label == 'C') {
      // Clear key: high contrast background with primary color text
      bgColor = _contrastColor.withValues(alpha: 0.9);
      textColor = widget.primaryColor;
    } else if (widget.label == '⌫') {
      // Backspace key: high contrast background with primary color text
      bgColor = _contrastColor.withValues(alpha: 0.9);
      textColor = widget.primaryColor;
    } else if (widget.label == '=') {
      // Equals key: semi-transparent contrast background with contrast text
      bgColor = _contrastColor.withValues(alpha: 0.25);
      textColor = _contrastColor;
    } else {
      // Number keys (0-9, ., 00): high contrast background with inverse text
      bgColor = _contrastColor.withValues(alpha: 0.9);
      textColor = _inverseContrastColor.withValues(alpha: 0.87);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 58,
          decoration: BoxDecoration(
            color: _isPressed ? bgColor.withValues(alpha: 0.7) : bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _buildKeyContent(textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyContent(Color textColor) {
    if (widget.label == '⌫') {
      return Icon(
        Icons.backspace_rounded,
        color: textColor,
        size: 22,
      );
    }

    return Text(
      widget.label,
      style: TextStyle(
        fontSize: widget.isOperator ? 32 : 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

class _SaveKey extends StatefulWidget {
  final Color primaryColor;
  final VoidCallback onTap;

  const _SaveKey({
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_SaveKey> createState() => _SaveKeyState();
}

class _SaveKeyState extends State<_SaveKey> {
  bool _isPressed = false;

  bool get _isLightPrimary => ColorUtils.isLightColor(widget.primaryColor);
  Color get _contrastColor => _isLightPrimary ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 54,
          decoration: BoxDecoration(
            color: _isPressed
                ? _contrastColor.withValues(alpha: 0.85)
                : _contrastColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (_isLightPrimary ? Colors.white : Colors.black).withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: widget.primaryColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _TallSaveKey extends StatefulWidget {
  final Color primaryColor;
  final VoidCallback onTap;

  const _TallSaveKey({
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_TallSaveKey> createState() => _TallSaveKeyState();
}

class _TallSaveKeyState extends State<_TallSaveKey> {
  bool _isPressed = false;

  bool get _isLightPrimary => ColorUtils.isLightColor(widget.primaryColor);
  Color get _contrastColor => _isLightPrimary ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    // Height: 58 (button) + 10 (spacing) + 58 (button) = 126
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 126,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _contrastColor,
                _contrastColor.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: _contrastColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'SAVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAmountKey extends StatefulWidget {
  final int amount;
  final Color primaryColor;
  final VoidCallback onTap;

  const _QuickAmountKey({
    required this.amount,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_QuickAmountKey> createState() => _QuickAmountKeyState();
}

class _QuickAmountKeyState extends State<_QuickAmountKey> {
  bool _isPressed = false;

  bool get _isLightPrimary => ColorUtils.isLightColor(widget.primaryColor);
  Color get _contrastColor => _isLightPrimary ? Colors.black : Colors.white;

  String _formatAmount(int amount) {
    if (amount >= 1000) {
      return '${amount ~/ 1000}K';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 36,
          decoration: BoxDecoration(
            color: _isPressed
                ? _contrastColor.withValues(alpha: 0.25)
                : _contrastColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _contrastColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              _formatAmount(widget.amount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _contrastColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
