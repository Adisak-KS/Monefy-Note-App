import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/models/category.dart';
import '../../../core/models/currency.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/utils/icon_utils.dart';

class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.onTap,
    this.onDelete,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<double> _deleteIconAnimation;
  double _dragExtent = 0;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _deleteIconAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _swipeController.dispose();
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
    final isIncome = widget.transaction.type == TransactionType.income;
    final categoryColor = _getCategoryColor();
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Dismissible(
        key: Key(widget.transaction.id),
        direction: DismissDirection.endToStart,
        dismissThresholds: const {DismissDirection.endToStart: 0.4},
        confirmDismiss: (_) async {
          HapticFeedback.mediumImpact();
          widget.onDelete?.call();
          return false;
        },
        onUpdate: (details) {
          setState(() {
            _dragExtent = details.progress;
          });
          if (details.progress > 0.3 && !_swipeController.isCompleted) {
            _swipeController.forward();
            HapticFeedback.lightImpact();
          } else if (details.progress <= 0.3 && _swipeController.isCompleted) {
            _swipeController.reverse();
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.05),
                Colors.red.withValues(alpha: 0.15 + (_dragExtent * 0.85)),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedBuilder(
            animation: _deleteIconAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _deleteIconAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap?.call();
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface.withValues(alpha: 0.8)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? categoryColor.withValues(alpha: 0.15)
                      : theme.colorScheme.outline.withValues(alpha: 0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : categoryColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Category icon with enhanced gradient
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          categoryColor.withValues(alpha: 0.25),
                          categoryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title, description and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category?.name ?? 'Unknown',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.transaction.description != null &&
                                widget.transaction.description!.isNotEmpty) ...[
                              Flexible(
                                child: Text(
                                  widget.transaction.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              timeFormat.format(widget.transaction.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Amount with enhanced styling
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isIncome
                                ? [
                                    const Color(
                                      0xFF22C55E,
                                    ).withValues(alpha: 0.15),
                                    const Color(
                                      0xFF16A34A,
                                    ).withValues(alpha: 0.1),
                                  ]
                                : [
                                    const Color(
                                      0xFFEF4444,
                                    ).withValues(alpha: 0.15),
                                    const Color(
                                      0xFFDC2626,
                                    ).withValues(alpha: 0.1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isIncome
                                ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                                : const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${isIncome ? '+' : '-'}${currencyFormat.format(widget.transaction.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isIncome
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    if (widget.category?.color != null) {
      try {
        return Color(
          int.parse(widget.category!.color!.replaceFirst('#', '0xFF')),
        );
      } catch (_) {}
    }
    return Colors.grey;
  }

  IconData _getCategoryIcon() {
    return IconUtils.getIconData(widget.category?.icon ?? 'category');
  }
}
