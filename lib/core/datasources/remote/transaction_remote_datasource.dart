import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/models/paginated_result.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/network/dio_client.dart';

abstract class TransactionRemoteDatasource {
  Future<List<Transaction>> getAll();
  Future<List<Transaction>> getByDate(DateTime date);
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);
  Future<List<Transaction>> getByType(TransactionType type);
  Future<List<Transaction>> getByWalletId(String walletId);
  Future<Transaction> getById(String id);
  Future<Transaction> create(Transaction transaction);
  Future<Transaction> update(Transaction transaction);
  Future<void> delete(String id);
  Future<PaginatedResult<Transaction>> getPaginated({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  final DioClient _dioClient;

  TransactionRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<Transaction>> getAll() async {
    final response = await _dioClient.get(ApiEndpoint.transactions);
    final data = response.data['data'] as List;
    return data.map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<List<Transaction>> getByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    final response = await _dioClient.get(
      ApiEndpoint.transactions,
      queryParameters: {
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
      },
    );
    final data = response.data['data'] as List;
    return data.map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<List<Transaction>> getByType(TransactionType type) async {
    final response = await _dioClient.get(
      ApiEndpoint.transactions,
      queryParameters: {'type': type.value},
    );
    final data = response.data['data'] as List;
    return data.map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<List<Transaction>> getByWalletId(String walletId) async {
    final response = await _dioClient.get(
      ApiEndpoint.transactions,
      queryParameters: {'walletId': walletId},
    );
    final data = response.data['data'] as List;
    return data.map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<Transaction> getById(String id) async {
    final response = await _dioClient.get(ApiEndpoint.transaction(id));
    return Transaction.fromJson(response.data['data']);
  }

  @override
  Future<Transaction> create(Transaction transaction) async {
    final response = await _dioClient.post(
      ApiEndpoint.transactions,
      data: {
        'type': transaction.type.value,
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
        'categoryId': transaction.categoryId,
        'walletId': transaction.walletId,
        if (transaction.description != null) 'description': transaction.description,
      },
    );
    return Transaction.fromJson(response.data['data']);
  }

  @override
  Future<Transaction> update(Transaction transaction) async {
    final response = await _dioClient.put(
      ApiEndpoint.transaction(transaction.id),
      data: {
        'type': transaction.type.value,
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
        'categoryId': transaction.categoryId,
        'walletId': transaction.walletId,
        if (transaction.description != null) 'description': transaction.description,
      },
    );
    return Transaction.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(String id) async {
    await _dioClient.delete(ApiEndpoint.transaction(id));
  }

  @override
  Future<PaginatedResult<Transaction>> getPaginated({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': pageSize,
    };
    if (startDate != null) queryParameters['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParameters['endDate'] = endDate.toIso8601String();

    final response = await _dioClient.get(
      ApiEndpoint.transactions,
      queryParameters: queryParameters,
    );

    final data = response.data['data'];
    final List items;
    final int totalCount;

    // Handle both paginated response format and simple list format
    if (data is List) {
      items = data;
      totalCount = data.length;
    } else {
      items = data['items'] as List? ?? data['transactions'] as List? ?? [];
      totalCount = data['totalCount'] as int? ?? data['total'] as int? ?? items.length;
    }

    return PaginatedResult<Transaction>(
      items: items.map((json) => Transaction.fromJson(json)).toList(),
      totalCount: totalCount,
      currentPage: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Map<String, dynamic>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (startDate != null) queryParameters['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParameters['endDate'] = endDate.toIso8601String();

    final response = await _dioClient.get(
      ApiEndpoint.transactionSummary,
      queryParameters: queryParameters,
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
