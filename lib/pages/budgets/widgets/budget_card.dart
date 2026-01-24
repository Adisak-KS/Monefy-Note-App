import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/budget.dart';
import '../../../core/models/category.dart';
import '../../../core/utils/icon_utils.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final categoryColor = _parseColor(category?.color);
    final isOverBudget = budget.isOverBudget;
    final progressColor = isOverBudget ? theme.colorScheme.error : categoryColor;

    return Dismissible(
      key: Key(budget.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) => onDelete?.call(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOverBudget
                    ? theme.colorScheme.error.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.1),
                width: isOverBudget ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconUtils.getIconData(category?.icon ?? 'category'),
                        color: categoryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'budgets.unknown_category'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '฿${budget.spent.toStringAsFixed(0)} / ฿${budget.amount.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${budget.percentage.toStringAsFixed(0)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                        ),
                        if (isOverBudget)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'budgets.over_budget'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onEdit?.call();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budget.percentage / 100,
                    backgroundColor:
                        theme.colorScheme.outline.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(progressColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'budgets.remaining'.tr()}: ฿${budget.remaining.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: budget.remaining < 0
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight:
                            budget.remaining < 0 ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('budgets.delete_title'.tr()),
            content: Text('budgets.delete_message'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('common.cancel'.tr()),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: Text('common.delete'.tr()),
              ),
            ],
          ),
        ) ??
        false;
  }
}
