import '../models/category.dart';
import '../models/transaction_type.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAll();
  Future<List<Category>> getByType(TransactionType type);
  Future<Category?> getById(String id);
  Future<void> add(Category category);
  Future<void> update(Category category);
  Future<void> delete(String id);
}
