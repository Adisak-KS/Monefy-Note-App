import 'package:monefy_note_app/core/datasources/remote/category_remote_datasource.dart';
import 'package:monefy_note_app/core/models/category.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/repositories/category_repository.dart';

class RemoteCategoryRepository implements CategoryRepository {
  final CategoryRemoteDatasource _remoteDatasource;

  RemoteCategoryRepository(this._remoteDatasource);

  @override
  Future<List<Category>> getAll() => _remoteDatasource.getAll();

  @override
  Future<List<Category>> getByType(TransactionType type) =>
      _remoteDatasource.getByType(type);

  @override
  Future<Category?> getById(String id) async {
    try {
      return await _remoteDatasource.getById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Category category) => _remoteDatasource.create(category);

  @override
  Future<void> update(Category category) => _remoteDatasource.update(category);

  @override
  Future<void> delete(String id) => _remoteDatasource.delete(id);
}
