import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/models/category.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/network/dio_client.dart';

abstract class CategoryRemoteDatasource {
  Future<List<Category>> getAll();
  Future<List<Category>> getByType(TransactionType type);
  Future<Category> getById(String id);
  Future<Category> create(Category category);
  Future<Category> update(Category category);
  Future<void> delete(String id);
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final DioClient _dioClient;

  CategoryRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<Category>> getAll() async {
    final response = await _dioClient.get(ApiEndpoint.categories);
    final data = response.data['data'] as List;
    return data.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<List<Category>> getByType(TransactionType type) async {
    final response = await _dioClient.get(
      ApiEndpoint.categories,
      queryParameters: {'type': type.value},
    );
    final data = response.data['data'] as List;
    return data.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<Category> getById(String id) async {
    final response = await _dioClient.get(ApiEndpoint.category(id));
    return Category.fromJson(response.data['data']);
  }

  @override
  Future<Category> create(Category category) async {
    final response = await _dioClient.post(
      ApiEndpoint.categories,
      data: {
        'name': category.name,
        'type': category.type.value,
        if (category.icon != null) 'icon': category.icon,
        if (category.color != null) 'color': category.color,
      },
    );
    return Category.fromJson(response.data['data']);
  }

  @override
  Future<Category> update(Category category) async {
    final response = await _dioClient.put(
      ApiEndpoint.category(category.id),
      data: {
        'name': category.name,
        'type': category.type.value,
        if (category.icon != null) 'icon': category.icon,
        if (category.color != null) 'color': category.color,
      },
    );
    return Category.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(String id) async {
    await _dioClient.delete(ApiEndpoint.category(id));
  }
}
