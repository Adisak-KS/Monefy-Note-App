import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/category.dart';
import '../../models/transaction_type.dart';
import '../../services/mock_data_service.dart';
import '../category_repository.dart';

/// Local implementation of CategoryRepository using SharedPreferences
class LocalCategoryRepository implements CategoryRepository {
  static const _key = 'local_categories';
  final SharedPreferences _prefs;

  LocalCategoryRepository(this._prefs);

  /// Initialize with default data if empty
  Future<void> initialize() async {
    final existing = _prefs.getString(_key);
    if (existing == null) {
      // Initialize with default categories
      await _saveAll(MockDataService.defaultCategories);
    }
  }

  Future<void> _saveAll(List<Category> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<Category>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Category>> getByType(TransactionType type) async {
    final all = await getAll();
    return all.where((c) => c.type == type).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Category category) async {
    final all = await getAll();
    all.add(category);
    await _saveAll(all);
  }

  @override
  Future<void> update(Category category) async {
    final all = await getAll();
    final index = all.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      all[index] = category;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((c) => c.id == id);
    await _saveAll(all);
  }
}
