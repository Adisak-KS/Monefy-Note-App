import 'package:monefy_note_app/core/models/budget.dart';
import 'package:monefy_note_app/core/repositories/budget_repository.dart';
import 'package:monefy_note_app/core/services/mock_data_service.dart';

class MockBudgetRepository implements BudgetRepository {
  final List<Budget> _budgets = [];

  MockBudgetRepository() {
    _initDefaultBudgets();
  }

  void _initDefaultBudgets() {
    final now = DateTime.now();
    _budgets.addAll([
      Budget(
        id: 'budget-food-001',
        categoryId: MockDataService.catFoodId,
        amount: 5000,
        spent: 2350,
        month: now.month,
        year: now.year,
      ),
      Budget(
        id: 'budget-transport-001',
        categoryId: MockDataService.catTransportId,
        amount: 3000,
        spent: 1200,
        month: now.month,
        year: now.year,
      ),
      Budget(
        id: 'budget-shopping-001',
        categoryId: MockDataService.catShoppingId,
        amount: 4000,
        spent: 4500,
        month: now.month,
        year: now.year,
      ),
      Budget(
        id: 'budget-entertainment-001',
        categoryId: MockDataService.catEntertainmentId,
        amount: 2000,
        spent: 800,
        month: now.month,
        year: now.year,
      ),
      Budget(
        id: 'budget-bills-001',
        categoryId: MockDataService.catBillsId,
        amount: 10000,
        spent: 8500,
        month: now.month,
        year: now.year,
      ),
    ]);
  }

  @override
  Future<List<Budget>> getAll() async {
    return List.from(_budgets);
  }

  @override
  Future<List<Budget>> getByMonth(int month, int year) async {
    return _budgets
        .where((b) => b.month == month && b.year == year)
        .toList();
  }

  @override
  Future<Budget?> getById(String id) async {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Budget?> getByCategoryAndMonth(
    String categoryId,
    int month,
    int year,
  ) async {
    try {
      return _budgets.firstWhere(
        (b) => b.categoryId == categoryId && b.month == month && b.year == year,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Budget budget) async {
    _budgets.add(budget);
  }

  @override
  Future<void> update(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
    }
  }

  @override
  Future<void> delete(String id) async {
    _budgets.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> updateSpent(
    String categoryId,
    int month,
    int year,
    double spent,
  ) async {
    final index = _budgets.indexWhere(
      (b) => b.categoryId == categoryId && b.month == month && b.year == year,
    );
    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(spent: spent);
    }
  }
}
