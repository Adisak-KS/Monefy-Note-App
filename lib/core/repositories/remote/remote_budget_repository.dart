import 'package:monefy_note_app/core/datasources/remote/budget_remote_datasource.dart';
import 'package:monefy_note_app/core/models/budget.dart';
import 'package:monefy_note_app/core/repositories/budget_repository.dart';

class RemoteBudgetRepository implements BudgetRepository {
  final BudgetRemoteDatasource _remoteDatasource;

  RemoteBudgetRepository(this._remoteDatasource);

  @override
  Future<List<Budget>> getAll() => _remoteDatasource.getAll();

  @override
  Future<List<Budget>> getByMonth(int month, int year) =>
      _remoteDatasource.getByMonth(month, year);

  @override
  Future<Budget?> getById(String id) async {
    try {
      return await _remoteDatasource.getById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Budget?> getByCategoryAndMonth(String categoryId, int month, int year) =>
      _remoteDatasource.getByCategoryAndMonth(categoryId, month, year);

  @override
  Future<void> add(Budget budget) => _remoteDatasource.create(budget);

  @override
  Future<void> update(Budget budget) => _remoteDatasource.update(budget);

  @override
  Future<void> delete(String id) => _remoteDatasource.delete(id);

  @override
  Future<void> updateSpent(String categoryId, int month, int year, double spent) =>
      _remoteDatasource.updateSpent(categoryId, month, year, spent);
}
