import '../models/paginated_result.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll();
  Future<List<Transaction>> getByDate(DateTime date);
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);
  Future<List<Transaction>> getByType(TransactionType type);
  Future<List<Transaction>> getByWalletId(String walletId);
  Future<Transaction?> getById(String id);
  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Future<double> getTotalByType(TransactionType type, DateTime date);

  /// Get paginated transactions within a date range
  Future<PaginatedResult<Transaction>> getPaginated({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get total count of transactions within a date range
  Future<int> getCount({DateTime? startDate, DateTime? endDate});
}
