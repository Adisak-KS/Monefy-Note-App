import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/budget.dart';
import '../../../core/repositories/budget_repository.dart';
import '../../../core/repositories/category_repository.dart';
import 'budget_state.dart';

@injectable
class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;
  static const _uuid = Uuid();

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
    if (state is! BudgetLoaded) return;
    final currentState = state as BudgetLoaded;

    try {
      final newBudget = Budget(
        id: _uuid.v4(),
        categoryId: categoryId,
        amount: amount,
        spent: 0,
        month: currentState.selectedMonth,
        year: currentState.selectedYear,
        note: note,
      );

      await _budgetRepository.add(newBudget);
      await loadBudgets(
        month: currentState.selectedMonth,
        year: currentState.selectedYear,
      );
    } catch (error) {
      emit(BudgetError(error.toString()));
    }
  }

  Future<void> updateBudget(Budget budget) async {
    if (state is! BudgetLoaded) return;
    final currentState = state as BudgetLoaded;

    try {
      await _budgetRepository.update(budget);
      await loadBudgets(
        month: currentState.selectedMonth,
        year: currentState.selectedYear,
      );
    } catch (error) {
      emit(BudgetError(error.toString()));
    }
  }

  Future<void> deleteBudget(String id) async {
    if (state is! BudgetLoaded) return;
    final currentState = state as BudgetLoaded;

    try {
      await _budgetRepository.delete(id);
      await loadBudgets(
        month: currentState.selectedMonth,
        year: currentState.selectedYear,
      );
    } catch (error) {
      emit(BudgetError(error.toString()));
    }
  }
}
