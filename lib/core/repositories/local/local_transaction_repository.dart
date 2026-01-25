import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transaction.dart';
import '../../models/transaction_type.dart';
import '../../services/mock_data_service.dart';
import '../transaction_repository.dart';

/// Local implementation of TransactionRepository using SharedPreferences
class LocalTransactionRepository implements TransactionRepository {
  static const _key = 'local_transactions';
  final SharedPreferences _prefs;

  LocalTransactionRepository(this._prefs);

  /// Initialize with default data if empty
  Future<void> initialize() async {
    final existing = _prefs.getString(_key);
    if (existing == null) {
      // Initialize with sample transactions
      final defaults = MockDataService.defaultTransactions;
      await _saveAll(defaults);
    }
  }

  Future<void> _saveAll(List<Transaction> transactions) async {
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<Transaction>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Transaction>> getByDate(DateTime date) async {
    final all = await getAll();
    return all.where((t) {
      return t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
    }).toList();
  }

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    final all = await getAll();
    return all.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<Transaction>> getByType(TransactionType type) async {
    final all = await getAll();
    return all.where((t) => t.type == type).toList();
  }

  @override
  Future<List<Transaction>> getByWalletId(String walletId) async {
    final all = await getAll();
    final transactions = all.where((t) => t.walletId == walletId).toList();
    // Sort by date descending (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<Transaction?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Transaction transaction) async {
    final all = await getAll();
    all.add(transaction);
    await _saveAll(all);
  }

  @override
  Future<void> update(Transaction transaction) async {
    final all = await getAll();
    final index = all.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      all[index] = transaction;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((t) => t.id == id);
    await _saveAll(all);
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
}
