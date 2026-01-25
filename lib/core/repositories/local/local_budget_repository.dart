import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/budget.dart';
import '../budget_repository.dart';

/// Local implementation of BudgetRepository using SharedPreferences
class LocalBudgetRepository implements BudgetRepository {
  static const _key = 'local_budgets';
  final SharedPreferences _prefs;

  LocalBudgetRepository(this._prefs);

  /// Initialize - no default budgets needed
  Future<void> initialize() async {
    // Budgets are user-created, so no defaults
    final existing = _prefs.getString(_key);
    if (existing == null) {
      await _saveAll([]);
    }
  }

  Future<void> _saveAll(List<Budget> budgets) async {
    final jsonList = budgets.map((b) => b.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<Budget>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Budget.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Budget>> getByMonth(int month, int year) async {
    final all = await getAll();
    return all.where((b) => b.month == month && b.year == year).toList();
  }

  @override
  Future<Budget?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((b) => b.id == id);
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
    final all = await getAll();
    try {
      return all.firstWhere(
        (b) => b.categoryId == categoryId && b.month == month && b.year == year,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Budget budget) async {
    final all = await getAll();
    all.add(budget);
    await _saveAll(all);
  }

  @override
  Future<void> update(Budget budget) async {
    final all = await getAll();
    final index = all.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      all[index] = budget;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((b) => b.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> updateSpent(
    String categoryId,
    int month,
    int year,
    double spent,
  ) async {
    final all = await getAll();
    final index = all.indexWhere(
      (b) => b.categoryId == categoryId && b.month == month && b.year == year,
    );
    if (index != -1) {
      final budget = all[index];
      all[index] = budget.copyWith(spent: spent);
      await _saveAll(all);
    }
  }
}
