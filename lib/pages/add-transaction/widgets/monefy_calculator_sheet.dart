import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/models/wallet.dart';
import '../../home/bloc/home_cubit.dart';
import '../../home/bloc/home_state.dart';

class MonefyCalculatorSheet extends StatefulWidget {
  final TransactionType type;

  const MonefyCalculatorSheet({
    super.key,
    required this.type,
  });

  static Future<void> show(BuildContext context, {required TransactionType type}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: MonefyCalculatorSheet(type: type),
      ),
    );
  }

  @override
  State<MonefyCalculatorSheet> createState() => _MonefyCalculatorSheetState();
}

class _MonefyCalculatorSheetState extends State<MonefyCalculatorSheet> {
  String _expression = '0';
  double _result = 0;
  String _note = '';
  Category? _selectedCategory;
  Wallet? _selectedWallet;
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();

  Color get _primaryColor => widget.type == TransactionType.expense
      ? const Color(0xFFE91E63)
      : const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HomeCubit>().state;
      if (state is HomeLoaded) {
        setState(() {
          if (state.wallets.isNotEmpty) {
            _selectedWallet = state.wallets.first;
          }
          final categories = state.categories.where((c) => c.type == widget.type).toList();
          if (categories.isNotEmpty) {
            _selectedCategory = categories.first;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      switch (key) {
        case 'C':
          _expression = '0';
          _result = 0;
          break;
        case '⌫':
          if (_expression.length > 1) {
            _expression = _expression.substring(0, _expression.length - 1);
          } else {
            _expression = '0';
          }
          _calculateResult();
          break;
        case '=':
          _calculateResult();
          if (_result > 0) {
            _expression = _formatResult(_result);
          }
          break;
        case '+':
        case '-':
        case '×':
        case '÷':
          if (_expression != '0' && !'+-×÷'.contains(_expression[_expression.length - 1])) {
            _expression += key;
          } else if (_expression.length > 1 && '+-×÷'.contains(_expression[_expression.length - 1])) {
            _expression = _expression.substring(0, _expression.length - 1) + key;
          }
          break;
        case '.':
          // Find the last number in expression
          final parts = _expression.split(RegExp(r'[+\-×÷]'));
          if (!parts.last.contains('.')) {
            _expression += '.';
          }
          break;
        default:
          if (_expression == '0') {
            _expression = key;
          } else {
            _expression += key;
          }
          _calculateResult();
      }
    });
  }

  void _calculateResult() {
    try {
      String expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      // Remove trailing operator
      if ('+-*/'.contains(expr[expr.length - 1])) {
        expr = expr.substring(0, expr.length - 1);
      }

      _result = _evaluateExpression(expr);
    } catch (_) {
      // Keep current result
    }
  }

  double _evaluateExpression(String expression) {
    final tokens = <String>[];
    var currentNumber = '';

    for (var i = 0; i < expression.length; i++) {
      final char = expression[i];
      if ('+-*/'.contains(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      } else {
        currentNumber += char;
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    if (tokens.isEmpty) return 0;

    // Handle * and / first
    final reducedTokens = <String>[];
    var i = 0;
    while (i < tokens.length) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final left = double.parse(reducedTokens.removeLast());
        final right = double.parse(tokens[i + 1]);
        final result = tokens[i] == '*' ? left * right : left / right;
        reducedTokens.add(result.toString());
        i += 2;
      } else {
        reducedTokens.add(tokens[i]);
        i++;
      }
    }

    // Handle + and -
    var result = double.parse(reducedTokens[0]);
    i = 1;
    while (i < reducedTokens.length) {
      final op = reducedTokens[i];
      final right = double.parse(reducedTokens[i + 1]);
      result = op == '+' ? result + right : result - right;
      i += 2;
    }

    return result;
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.truncate().toString();
    }
    return value.toStringAsFixed(2);
  }

  void _save() {
    _calculateResult();
    if (_result <= 0) {
      HapticFeedback.vibrate();
      return;
    }

    if (_selectedCategory == null || _selectedWallet == null) {
      HapticFeedback.vibrate();
      return;
    }

    context.read<HomeCubit>().addTransaction(
      type: widget.type,
      amount: _result,
      categoryId: _selectedCategory!.id,
      walletId: _selectedWallet!.id,
      date: _selectedDate,
      description: _note.isNotEmpty ? _note : null,
    );

    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 100,
      ),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Top row: Note + Amount
          _buildTopRow(theme),

          // Control row: Category + Date + Wallet + Confirm
          _buildControlRow(theme),

          // Calculator pad
          _buildCalculatorPad(theme),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildTopRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Note input
          Expanded(
            flex: 2,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'home.note'.tr(),
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => _note = v,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Amount display
          Expanded(
            flex: 2,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedWallet != null)
                    Text(
                      _selectedWallet!.name,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _expression,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlRow(ThemeData theme) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        final categories = state.categories.where((c) => c.type == widget.type).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              // Category button
              _ControlButton(
                icon: _getCategoryIcon(_selectedCategory?.icon),
                onTap: () => _showCategoryPicker(categories),
              ),
              const SizedBox(width: 8),
              // Date button
              _ControlButton(
                label: _getDateLabel(),
                onTap: _showDatePicker,
              ),
              const SizedBox(width: 8),
              // Wallet button
              _ControlButton(
                icon: _getWalletIcon(_selectedWallet?.type.name),
                onTap: () => _showWalletPicker(state.wallets),
              ),
              const SizedBox(width: 8),
              // Confirm button
              _ControlButton(
                icon: Icons.check_rounded,
                isHighlighted: true,
                onTap: _save,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalculatorPad(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          _buildKeyRow(['×', '7', '8', '9', 'C']),
          const SizedBox(height: 8),
          _buildKeyRow(['÷', '4', '5', '6', '⌫']),
          const SizedBox(height: 8),
          _buildKeyRow(['-', '1', '2', '3', null]),
          const SizedBox(height: 8),
          _buildKeyRow(['+', '.', '0', '=', null]),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String?> keys) {
    return Row(
      children: keys.map((key) {
        if (key == null) {
          return const Expanded(child: SizedBox());
        }
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _CalcKey(
              label: key,
              isOperator: '+-×÷'.contains(key),
              isAction: key == 'C' || key == '⌫' || key == '=',
              onTap: () => _onKeyPress(key),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) {
      return 'TODAY';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'YESTERDAY';
    } else {
      return DateFormat('d MMM').format(_selectedDate);
    }
  }

  IconData _getCategoryIcon(String? icon) {
    switch (icon) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'movie': return Icons.movie;
      case 'receipt': return Icons.receipt;
      case 'medical_services': return Icons.medical_services;
      case 'payments': return Icons.payments;
      case 'work': return Icons.work;
      case 'trending_up': return Icons.trending_up;
      case 'card_giftcard': return Icons.card_giftcard;
      default: return Icons.category;
    }
  }

  IconData _getWalletIcon(String? type) {
    switch (type) {
      case 'cash': return Icons.payments_rounded;
      case 'bank': return Icons.account_balance_rounded;
      case 'creditCard': return Icons.credit_card_rounded;
      case 'eWallet': return Icons.phone_android_rounded;
      default: return Icons.wallet_rounded;
    }
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showCategoryPicker(List<Category> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'home.category'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((cat) {
                final isSelected = _selectedCategory?.id == cat.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? _primaryColor : _primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(cat.icon),
                          color: isSelected ? Colors.white : _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showWalletPicker(List<Wallet> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'home.wallet'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...wallets.map((wallet) {
              final isSelected = _selectedWallet?.id == wallet.id;
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : _primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getWalletIcon(wallet.type.name),
                    color: isSelected ? Colors.white : _primaryColor,
                  ),
                ),
                title: Text(
                  wallet.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check, color: _primaryColor) : null,
                onTap: () {
                  setState(() => _selectedWallet = wallet);
                  Navigator.pop(ctx);
                },
              );
            }),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _ControlButton({
    this.label,
    this.icon,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: widget.isHighlighted
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: widget.isHighlighted
                          ? const Color(0xFFE91E63)
                          : Colors.white,
                      size: 24,
                    )
                  : Text(
                      widget.label!,
                      style: TextStyle(
                        color: widget.isHighlighted
                            ? const Color(0xFFE91E63)
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalcKey extends StatefulWidget {
  final String label;
  final bool isOperator;
  final bool isAction;
  final VoidCallback onTap;

  const _CalcKey({
    required this.label,
    this.isOperator = false,
    this.isAction = false,
    required this.onTap,
  });

  @override
  State<_CalcKey> createState() => _CalcKeyState();
}

class _CalcKeyState extends State<_CalcKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: widget.isOperator ? 0.3 : 0.9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: widget.label == '⌫'
                ? Icon(
                    Icons.backspace_outlined,
                    color: const Color(0xFFE91E63),
                    size: 22,
                  )
                : widget.label == 'C'
                    ? Icon(
                        Icons.close_rounded,
                        color: const Color(0xFFE91E63),
                        size: 24,
                      )
                    : Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: widget.isOperator ? 24 : 22,
                          fontWeight: FontWeight.w600,
                          color: widget.isOperator || widget.isAction
                              ? const Color(0xFFE91E63)
                              : Colors.black87,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
