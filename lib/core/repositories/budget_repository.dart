import '../models/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAll();
  Future<List<Budget>> getByMonth(int month, int year);
  Future<Budget?> getById(String id);
  Future<Budget?> getByCategoryAndMonth(String categoryId, int month, int year);
  Future<void> add(Budget budget);
  Future<void> update(Budget budget);
  Future<void> delete(String id);
  Future<void> updateSpent(String categoryId, int month, int year, double spent);
}
