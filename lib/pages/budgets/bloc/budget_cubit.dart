import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/models/budget.dart';
import '../../../core/repositories/budget_repository.dart';
import '../../../core/repositories/category_repository.dart';
import 'budget_state.dart';

@injectable
class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;

  BudgetCubit(this._budgetRepository, this._categoryRepository)
      : super(const BudgetInitial());

  Future<void> loadBudgets({int? month, int? year}) async {
    emit(const BudgetLoading());

    try {
      final now = DateTime.now();
      final selectedMonth = month ?? now.month;
      final selectedYear = year ?? now.year;

      final budgets = await _budgetRepository.getByMonth(
        selectedMonth,
        selectedYear,
      );
      final categories = await _categoryRepository.getAll();

      final totalBudget = budgets.fold<double>(0, (sum, b) => sum + b.amount);
      final totalSpent = budgets.fold<double>(0, (sum, b) => sum + b.spent);

      emit(BudgetLoaded(
        budgets: budgets,
        categories: categories,
        selectedMonth: selectedMonth,
        selectedYear: selectedYear,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
      ));
    } catch (error) {
      emit(BudgetError(error.toString()));
    }
  }

  void changeMonth(int month, int year) {
    loadBudgets(month: month, year: year);
  }

  void previousMonth() {
    if (state is! BudgetLoaded) return;
    final currentState = state as BudgetLoaded;

    int newMonth = currentState.selectedMonth - 1;
    int newYear = currentState.selectedYear;

    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    loadBudgets(month: newMonth, year: newYear);
  }

  void nextMonth() {
    if (state is! BudgetLoaded) return;
    final currentState = state as BudgetLoaded;

    int newMonth = currentState.selectedMonth + 1;
    int newYear = currentState.selectedYear;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }

    loadBudgets(month: newMonth, year: newYear);
  }

  void setMonth(int month) {
    if (state is! BudgetLoaded) return;
    final currentState = state as BudgetLoaded;
    loadBudgets(month: month, year: currentState.selectedYear);
  }

  Future<void> addBudget({
    required String categoryId,
    required double amount,
    String? note,
  }) async {
    final currentState = state;
    if (currentState is! BudgetLoaded) return;

    final newBudget = Budget(
      id: '',
      categoryId: categoryId,
      amount: amount,
      spent: 0,
      month: currentState.selectedMonth,
      year: currentState.selectedYear,
      note: note,
    );

    // Optimistic: add budget to list immediately
    final optimisticBudgets = [...currentState.budgets, newBudget];
    emit(currentState.copyWith(
      budgets: optimisticBudgets,
      totalBudget: currentState.totalBudget + amount,
    ));

    try {
      await _budgetRepository.add(newBudget);
      await loadBudgets(
        month: currentState.selectedMonth,
        year: currentState.selectedYear,
      );
    } catch (error) {
      emit(currentState);
    }
  }

  Future<void> updateBudget(Budget budget) async {
    final currentState = state;
    if (currentState is! BudgetLoaded) return;

    // Optimistic: replace budget in list immediately
    final optimisticBudgets = currentState.budgets
        .map((b) => b.id == budget.id ? budget : b)
        .toList();
    final newTotalBudget = optimisticBudgets.fold<double>(0, (sum, b) => sum + b.amount);
    final newTotalSpent = optimisticBudgets.fold<double>(0, (sum, b) => sum + b.spent);

    emit(currentState.copyWith(
      budgets: optimisticBudgets,
      totalBudget: newTotalBudget,
      totalSpent: newTotalSpent,
    ));

    try {
      await _budgetRepository.update(budget);
      await loadBudgets(
        month: currentState.selectedMonth,
        year: currentState.selectedYear,
      );
    } catch (error) {
      emit(currentState);
    }
  }

  Future<void> deleteBudget(String id) async {
    final currentState = state;
    if (currentState is! BudgetLoaded) return;

    // Optimistic: remove from list immediately
    final optimisticBudgets = currentState.budgets
        .where((b) => b.id != id)
        .toList();
    final newTotalBudget = optimisticBudgets.fold<double>(0, (sum, b) => sum + b.amount);
    final newTotalSpent = optimisticBudgets.fold<double>(0, (sum, b) => sum + b.spent);

    emit(currentState.copyWith(
      budgets: optimisticBudgets,
      totalBudget: newTotalBudget,
      totalSpent: newTotalSpent,
    ));

    try {
      await _budgetRepository.delete(id);
    } catch (error) {
      emit(currentState);
    }
  }
}
