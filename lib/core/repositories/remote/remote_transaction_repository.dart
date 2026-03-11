import 'package:monefy_note_app/core/datasources/remote/transaction_remote_datasource.dart';
import 'package:monefy_note_app/core/models/paginated_result.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/repositories/transaction_repository.dart';

class RemoteTransactionRepository implements TransactionRepository {
  final TransactionRemoteDatasource _remoteDatasource;

  RemoteTransactionRepository(this._remoteDatasource);

  @override
  Future<List<Transaction>> getAll() => _remoteDatasource.getAll();

  @override
  Future<List<Transaction>> getByDate(DateTime date) =>
      _remoteDatasource.getByDate(date);

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) =>
      _remoteDatasource.getByDateRange(start, end);

  @override
  Future<List<Transaction>> getByType(TransactionType type) =>
      _remoteDatasource.getByType(type);

  @override
  Future<List<Transaction>> getByWalletId(String walletId) =>
      _remoteDatasource.getByWalletId(walletId);

  @override
  Future<Transaction?> getById(String id) async {
    try {
      return await _remoteDatasource.getById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Transaction transaction) =>
      _remoteDatasource.create(transaction);

  @override
  Future<void> update(Transaction transaction) =>
      _remoteDatasource.update(transaction);

  @override
  Future<void> delete(String id) => _remoteDatasource.delete(id);

  @override
  Future<double> getTotalByType(TransactionType type, DateTime date) async {
    final transactions = await _remoteDatasource.getByDate(date);
    double total = 0.0;
    for (final t in transactions) {
      if (t.type == type) total += t.amount;
    }
    return total;
  }

  @override
  Future<PaginatedResult<Transaction>> getPaginated({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _remoteDatasource.getPaginated(
        page: page,
        pageSize: pageSize,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  Future<int> getCount({DateTime? startDate, DateTime? endDate}) async {
    final result = await _remoteDatasource.getPaginated(
      page: 1,
      pageSize: 1,
      startDate: startDate,
      endDate: endDate,
    );
    return result.totalCount;
  }
}
