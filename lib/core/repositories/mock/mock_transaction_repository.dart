import '../../models/paginated_result.dart';
import '../../models/transaction.dart';
import '../../models/transaction_type.dart';
import '../../services/mock_data_service.dart';
import '../transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final List<Transaction> _transactions = List.from(MockDataService.defaultTransactions);

  @override
  Future<List<Transaction>> getAll() async {
    return _transactions;
  }

  @override
  Future<List<Transaction>> getByDate(DateTime date) async {
    return _transactions.where((t) {
      return t.date.year == date.year && t.date.month == date.month && t.date.day == date.day;
    }).toList();
  }

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<Transaction>> getByType(TransactionType type) async {
    return _transactions.where((t) => t.type == type).toList();
  }

  @override
  Future<List<Transaction>> getByWalletId(String walletId) async {
    final transactions = _transactions.where((t) => t.walletId == walletId).toList();
    // Sort by date descending (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<Transaction?> getById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<void> update(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> delete(String id) async {
    _transactions.removeWhere((t) => t.id == id);
  }

  @override
  Future<double> getTotalByType(TransactionType type, DateTime date) async {
    final dayTransactions = await getByDate(date);
    double total = 0;
    for (final t in dayTransactions) {
      if (t.type == type) {
        total += t.amount;
      }
    }
    return total;
  }

  @override
  Future<PaginatedResult<Transaction>> getPaginated({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Transaction> filtered;

    if (startDate != null && endDate != null) {
      filtered = await getByDateRange(startDate, endDate);
    } else {
      filtered = await getAll();
    }

    // Sort by date descending (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    final totalCount = filtered.length;
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    final items = startIndex < filtered.length
        ? filtered.sublist(
            startIndex,
            endIndex > filtered.length ? filtered.length : endIndex,
          )
        : <Transaction>[];

    return PaginatedResult<Transaction>(
      items: items,
      totalCount: totalCount,
      currentPage: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<int> getCount({DateTime? startDate, DateTime? endDate}) async {
    if (startDate != null && endDate != null) {
      final filtered = await getByDateRange(startDate, endDate);
      return filtered.length;
    }
    return _transactions.length;
  }
}
