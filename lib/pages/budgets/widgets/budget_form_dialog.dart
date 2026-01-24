import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/budget.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/utils/icon_utils.dart';

class BudgetFormDialog extends StatefulWidget {
  final Budget? budget;
  final List<Category> categories;
  final List<String> usedCategoryIds;
  final Function(String categoryId, double amount, String? note) onSave;

  const BudgetFormDialog({
    super.key,
    this.budget,
    required this.categories,
    required this.usedCategoryIds,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    Budget? budget,
    required List<Category> categories,
    required List<String> usedCategoryIds,
    required Function(String categoryId, double amount, String? note) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetFormDialog(
        budget: budget,
        categories: categories,
        usedCategoryIds: usedCategoryIds,
        onSave: onSave,
      ),
    );
  }

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;

  List<Category> get _availableCategories {
    final expenseCategories = widget.categories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    if (widget.budget != null) {
      return expenseCategories;
    }

    return expenseCategories
        .where((c) => !widget.usedCategoryIds.contains(c.id))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget?.amount.toStringAsFixed(0) ?? '',
    );
    _noteController = TextEditingController(text: widget.budget?.note ?? '');
    _selectedCategoryId = widget.budget?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.budget != null
                      ? 'budgets.edit_budget'.tr()
                      : 'budgets.add_budget'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category selector
              Text(
                'budgets.category'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (_availableCategories.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'budgets.all_categories_used'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = _availableCategories[index];
                      final isSelected = category.id == _selectedCategoryId;
                      final categoryColor = _parseColor(category.color);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedCategoryId = category.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? categoryColor.withValues(alpha: 0.15)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: categoryColor, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                IconUtils.getIconData(category.icon ?? 'category'),
                                color: isSelected
                                    ? categoryColor
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? categoryColor
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: isSelected ? FontWeight.w600 : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // Amount field
              Text(
                'budgets.amount'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'budgets.amount_hint'.tr(),
                  prefixText: '฿ ',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Note field
              Text(
                'budgets.note'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'budgets.note_hint'.tr(),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _availableCategories.isEmpty ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'common.save'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('budgets.select_category'.tr()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('budgets.enter_amount'.tr()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final note = _noteController.text.trim();
    widget.onSave(_selectedCategoryId!, amount, note.isEmpty ? null : note);
    Navigator.pop(context);
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
}
