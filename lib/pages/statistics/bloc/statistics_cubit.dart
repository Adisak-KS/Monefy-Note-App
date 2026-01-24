import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:monefy_note_app/core/models/category.dart';
import 'package:monefy_note_app/core/models/date_filter_type.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/repositories/category_repository.dart';
import 'package:monefy_note_app/core/repositories/transaction_repository.dart';
import 'package:monefy_note_app/core/repositories/wallet_repository.dart';
import 'statistics_state.dart';

@injectable
class StatisticsCubit extends Cubit<StatisticsState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final WalletRepository _walletRepository;

  DateFilterType _currentFilter = DateFilterType.month;
  DateTimeRange? _customDateRange;

  StatisticsCubit(
    this._transactionRepository,
    this._categoryRepository,
    this._walletRepository,
  ) : super(StatisticsInitial());

  Future<void> loadStatistics({
    DateFilterType? filter,
    DateTimeRange? customRange,
  }) async {
    emit(StatisticsLoading());

    try {
      if (filter != null) _currentFilter = filter;
      if (customRange != null) _customDateRange = customRange;

      final dateRange = _currentFilter == DateFilterType.custom
          ? _customDateRange!
          : _currentFilter.getDateRange();

      final transactions = await _transactionRepository.getByDateRange(
        dateRange.start,
        dateRange.end,
      );
      final categories = await _categoryRepository.getAll();
      final wallets = await _walletRepository.getAll();

      final totalIncome = _calculateTotal(transactions, TransactionType.income);
      final totalExpense =
          _calculateTotal(transactions, TransactionType.expense);

      final expenseByCategory = _calculateCategoryStatistics(
        transactions,
        categories,
        TransactionType.expense,
      );

      final incomeByCategory = _calculateCategoryStatistics(
        transactions,
        categories,
        TransactionType.income,
      );

      final dailyStatistics = _calculateDailyStatistics(
        transactions,
        dateRange,
      );

      final walletStatistics = _calculateWalletStatistics(
        transactions,
        wallets,
      );

      emit(StatisticsLoaded(
        transactions: transactions,
        categories: categories,
        wallets: wallets,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        filterType: _currentFilter,
        customDateRange: _customDateRange,
        expenseByCategory: expenseByCategory,
        incomeByCategory: incomeByCategory,
        dailyStatistics: dailyStatistics,
        walletStatistics: walletStatistics,
      ));
    } catch (error) {
      emit(StatisticsError(error.toString()));
    }
  }

  void changeFilter(DateFilterType filter, {DateTimeRange? customRange}) {
    loadStatistics(filter: filter, customRange: customRange);
  }

  double _calculateTotal(
      List<Transaction> transactions, TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<CategoryStatistic> _calculateCategoryStatistics(
    List<Transaction> transactions,
    List<Category> categories,
    TransactionType type,
  ) {
    final filteredTransactions =
        transactions.where((t) => t.type == type).toList();

    if (filteredTransactions.isEmpty) return [];

    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryCounts = {};

    for (final t in filteredTransactions) {
      categoryTotals[t.categoryId] =
          (categoryTotals[t.categoryId] ?? 0) + t.amount;
      categoryCounts[t.categoryId] = (categoryCounts[t.categoryId] ?? 0) + 1;
    }

    final totalAmount =
        filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);

    final result = <CategoryStatistic>[];
    for (final entry in categoryTotals.entries) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(
          id: entry.key,
          name: 'Unknown',
          type: type,
        ),
      );

      result.add(CategoryStatistic(
        category: category,
        amount: entry.value,
        percentage: totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0,
        transactionCount: categoryCounts[entry.key] ?? 0,
      ));
    }

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  List<DailyStatistic> _calculateDailyStatistics(
    List<Transaction> transactions,
    DateTimeRange dateRange,
  ) {
    final Map<DateTime, DailyStatistic> dailyMap = {};

    // Initialize all days in the range
    var currentDay = DateTime(
      dateRange.start.year,
      dateRange.start.month,
      dateRange.start.day,
    );
    final endDay = DateTime(
      dateRange.end.year,
      dateRange.end.month,
      dateRange.end.day,
    );

    while (!currentDay.isAfter(endDay)) {
      dailyMap[currentDay] = DailyStatistic(
        date: currentDay,
        income: 0,
        expense: 0,
      );
      currentDay = currentDay.add(const Duration(days: 1));
    }

    // Aggregate transactions
    for (final t in transactions) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      final existing = dailyMap[day];
      if (existing != null) {
        dailyMap[day] = DailyStatistic(
          date: day,
          income: existing.income +
              (t.type == TransactionType.income ? t.amount : 0),
          expense: existing.expense +
              (t.type == TransactionType.expense ? t.amount : 0),
        );
      }
    }

    final result = dailyMap.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  List<WalletStatistic> _calculateWalletStatistics(
    List<Transaction> transactions,
    List<dynamic> wallets,
  ) {
    final Map<String, WalletStatistic> walletMap = {};

    for (final wallet in wallets) {
      final walletTransactions =
          transactions.where((t) => t.walletId == wallet.id).toList();

      final totalIncome =
          _calculateTotal(walletTransactions, TransactionType.income);
      final totalExpense =
          _calculateTotal(walletTransactions, TransactionType.expense);

      if (walletTransactions.isNotEmpty) {
        walletMap[wallet.id] = WalletStatistic(
          wallet: wallet,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          transactionCount: walletTransactions.length,
        );
      }
    }

    final result = walletMap.values.toList();
    result.sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
    return result;
  }
}
