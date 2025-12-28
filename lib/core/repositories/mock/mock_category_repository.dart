import 'package:monefy_note_app/core/models/category.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/repositories/category_repository.dart';
import 'package:monefy_note_app/core/services/mock_data_service.dart';

class MockCategoryRepository implements CategoryRepository {
  final List<Category> _categories = List.from(MockDataService.defaultCategories);

  @override
  Future<List<Category>> getAll() async {
    return _categories;
  }

  @override
  Future<List<Category>> getByType(TransactionType type) async {
    return _categories.where((c) => c.type == type).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Category category) async {
    _categories.add(category);
  }

  @override
  Future<void> update(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  @override
  Future<void> delete(String id) async {
    _categories.removeWhere((c) => c.id == id);
  }
}
