import 'package:equatable/equatable.dart';
import '../../../core/models/budget.dart';
import '../../../core/models/category.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetLoaded extends BudgetState {
  final List<Budget> budgets;
  final List<Category> categories;
  final int selectedMonth;
  final int selectedYear;
  final double totalBudget;
  final double totalSpent;

  const BudgetLoaded({
    required this.budgets,
    required this.categories,
    required this.selectedMonth,
    required this.selectedYear,
    required this.totalBudget,
    required this.totalSpent,
  });

  double get totalRemaining => totalBudget - totalSpent;
  double get overallPercentage =>
      totalBudget > 0 ? (totalSpent / totalBudget * 100).clamp(0, 100) : 0;

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        budgets,
        categories,
        selectedMonth,
        selectedYear,
        totalBudget,
        totalSpent,
      ];

  BudgetLoaded copyWith({
    List<Budget>? budgets,
    List<Category>? categories,
    int? selectedMonth,
    int? selectedYear,
    double? totalBudget,
    double? totalSpent,
  }) {
    return BudgetLoaded(
      budgets: budgets ?? this.budgets,
      categories: categories ?? this.categories,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object> get props => [message];
}
