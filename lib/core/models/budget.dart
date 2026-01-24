import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
sealed class Budget with _$Budget {
  const Budget._();

  const factory Budget({
    required String id,
    required String categoryId,
    required double amount,
    required double spent,
    required int month,
    required int year,
    String? note,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount * 100).clamp(0, 100) : 0;
  bool get isOverBudget => spent > amount;
}
