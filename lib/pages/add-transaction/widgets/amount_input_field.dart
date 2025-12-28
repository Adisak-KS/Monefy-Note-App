import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInputField extends StatefulWidget {
  final double initialAmount;
  final ValueChanged<double> onAmountChanged;
  final Color primaryColor;
  final bool isExpense;

  const AmountInputField({
    super.key,
    this.initialAmount = 0,
    required this.onAmountChanged,
    required this.primaryColor,
    required this.isExpense,
  });

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  String _expression = '0';
  double _result = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount > 0) {
      _expression = _formatNumber(widget.initialAmount);
      _result = widget.initialAmount;
    }
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.truncate().toString();
    }
    return value.toStringAsFixed(2);
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
            _expression = _formatNumber(_result);
          }
          break;
        case '+':
        case '-':
        case '×':
        case '÷':
          if (_expression != '0' &&
              !'+-×÷'.contains(_expression[_expression.length - 1])) {
            _expression += key;
          } else if (_expression.length > 1 &&
              '+-×÷'.contains(_expression[_expression.length - 1])) {
            _expression =
                _expression.substring(0, _expression.length - 1) + key;
          }
          break;
        case '.':
          final parts = _expression.split(RegExp(r'[+\-×÷]'));
          if (!parts.last.contains('.')) {
            if (_expression == '0') {
              _expression = '0.';
            } else {
              _expression += '.';
            }
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
    widget.onAmountChanged(_result);
  }

  void _calculateResult() {
    try {
      String expr =
          _expression.replaceAll('×', '*').replaceAll('÷', '/');

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

  @override
  Widget build(BuildContext context) {
    final hasOperators = _expression.contains(RegExp(r'[+\-×÷]'));

    return Column(
      children: [
        // Amount Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            children: [
              // Result preview when calculating
              if (hasOperators && _result > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '= ${_formatNumber(_result)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.primaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),

              // Main amount display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.isExpense ? '-' : '+',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: widget.primaryColor,
                    ),
                  ),
                  Text(
                    '฿',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: widget.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                        letterSpacing: -1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Calculator Pad
        _buildCalculatorPad(),
      ],
    );
  }

  Widget _buildCalculatorPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
              primaryColor: widget.primaryColor,
              onTap: () => _onKeyPress(key),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color textColor;

    if (widget.isOperator) {
      bgColor = widget.primaryColor.withValues(alpha: 0.15);
      textColor = widget.primaryColor;
    } else if (widget.label == 'C') {
      bgColor = theme.colorScheme.error.withValues(alpha: 0.15);
      textColor = theme.colorScheme.error;
    } else if (widget.label == '⌫') {
      bgColor = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.15);
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    } else if (widget.label == '=') {
      bgColor = widget.primaryColor;
      textColor = Colors.white;
    } else {
      bgColor = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.white;
      textColor = theme.colorScheme.onSurface;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: !isDark && !widget.isOperator && widget.label != '='
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.label == '⌫'
                ? Icon(
                    Icons.backspace_outlined,
                    color: textColor,
                    size: 22,
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.isOperator ? 26 : 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
