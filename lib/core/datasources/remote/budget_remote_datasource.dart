import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/models/budget.dart';
import 'package:monefy_note_app/core/network/dio_client.dart';

abstract class BudgetRemoteDatasource {
  Future<List<Budget>> getAll();
  Future<List<Budget>> getByMonth(int month, int year);
  Future<Budget> getById(String id);
  Future<Budget?> getByCategoryAndMonth(String categoryId, int month, int year);
  Future<Budget> create(Budget budget);
  Future<Budget> update(Budget budget);
  Future<void> delete(String id);
  Future<void> updateSpent(String categoryId, int month, int year, double spent);
}

class BudgetRemoteDatasourceImpl implements BudgetRemoteDatasource {
  final DioClient _dioClient;

  BudgetRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<Budget>> getAll() async {
    final response = await _dioClient.get(ApiEndpoint.budgets);
    final data = response.data['data'] as List;
    return data.map((json) => Budget.fromJson(json)).toList();
  }

  @override
  Future<List<Budget>> getByMonth(int month, int year) async {
    final response = await _dioClient.get(
      ApiEndpoint.budgets,
      queryParameters: {'month': month, 'year': year},
    );
    final data = response.data['data'] as List;
    return data.map((json) => Budget.fromJson(json)).toList();
  }

  @override
  Future<Budget> getById(String id) async {
    final response = await _dioClient.get(ApiEndpoint.budget(id));
    return Budget.fromJson(response.data['data']);
  }

  @override
  Future<Budget?> getByCategoryAndMonth(String categoryId, int month, int year) async {
    final response = await _dioClient.get(
      ApiEndpoint.budgets,
      queryParameters: {
        'categoryId': categoryId,
        'month': month,
        'year': year,
      },
    );
    final data = response.data['data'] as List;
    if (data.isEmpty) return null;
    return Budget.fromJson(data.first);
  }

  @override
  Future<Budget> create(Budget budget) async {
    final response = await _dioClient.post(
      ApiEndpoint.budgets,
      data: {
        'categoryId': budget.categoryId,
        'amount': budget.amount,
        'spent': budget.spent,
        'month': budget.month,
        'year': budget.year,
        if (budget.note != null) 'note': budget.note,
      },
    );
    return Budget.fromJson(response.data['data']);
  }

  @override
  Future<Budget> update(Budget budget) async {
    final response = await _dioClient.put(
      ApiEndpoint.budget(budget.id),
      data: {
        'categoryId': budget.categoryId,
        'amount': budget.amount,
        'spent': budget.spent,
        'month': budget.month,
        'year': budget.year,
        if (budget.note != null) 'note': budget.note,
      },
    );
    return Budget.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(String id) async {
    await _dioClient.delete(ApiEndpoint.budget(id));
  }

  @override
  Future<void> updateSpent(String categoryId, int month, int year, double spent) async {
    // Find the budget first, then update it
    final budget = await getByCategoryAndMonth(categoryId, month, year);
    if (budget != null) {
      await _dioClient.put(
        ApiEndpoint.budget(budget.id),
        data: {'spent': spent},
      );
    }
  }
}
