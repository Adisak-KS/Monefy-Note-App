import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:monefy_note_app/core/bloc/drawer_stats_cubit.dart';
import 'package:monefy_note_app/core/models/date_filter_type.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/repositories/category_repository.dart';
import 'package:monefy_note_app/core/repositories/transaction_repository.dart';
import 'package:monefy_note_app/core/repositories/wallet_repository.dart';
import 'package:monefy_note_app/pages/home/bloc/home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final WalletRepository _walletRepository;
  final DrawerStatsCubit _drawerStatsCubit;
  static const _pageSize = 20;

  Transaction? _recentlyDeletedTransaction;
  Timer? _undoTimer;
  DateFilterType _currentFilter = DateFilterType.today;
  DateTimeRange? _customDateRange;

  HomeCubit(
    this._transactionRepository,
    this._categoryRepository,
    this._walletRepository,
    this._drawerStatsCubit,
  ) : super(HomeInitial());

  @override
  Future<void> close() {
    _undoTimer?.cancel();
    return super.close();
  }

  Future<void> loadTodayData() async {
    await loadData();
  }

  Future<void> loadData({DateFilterType? filter, DateTimeRange? customRange}) async {
    emit(HomeLoading());

    try {
      if (filter != null) _currentFilter = filter;
      if (customRange != null) _customDateRange = customRange;

      final dateRange = _currentFilter == DateFilterType.custom
          ? _customDateRange!
          : _currentFilter.getDateRange();

      // Use pagination for initial load
      final paginatedResult = await _transactionRepository.getPaginated(
        page: 1,
        pageSize: _pageSize,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      final categories = await _categoryRepository.getAll();
      final wallets = await _walletRepository.getAll();

      // Get all transactions for totals calculation
      final allTransactions = await _transactionRepository.getByDateRange(
        dateRange.start,
        dateRange.end,
      );
      final totalIncome = _calculateTotal(allTransactions, TransactionType.income);
      final totalExpense = _calculateTotal(allTransactions, TransactionType.expense);

      emit(
        HomeLoaded(
          todayTransactions: paginatedResult.items,
          categories: categories,
          wallets: wallets,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          filterType: _currentFilter,
          customDateRange: _customDateRange,
          currentPage: 1,
          totalCount: paginatedResult.totalCount,
          hasMore: paginatedResult.hasMore,
        ),
      );

      // Sync stats with DrawerStatsCubit
      _drawerStatsCubit.updateStats(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        transactionCount: paginatedResult.totalCount,
      );
    } catch (error) {
      emit(HomeError(error.toString()));
    }
  }

  /// Load more transactions for infinite scroll
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final dateRange = _currentFilter == DateFilterType.custom
          ? _customDateRange!
          : _currentFilter.getDateRange();

      final nextPage = currentState.currentPage + 1;
      final paginatedResult = await _transactionRepository.getPaginated(
        page: nextPage,
        pageSize: _pageSize,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      final updatedTransactions = [
        ...currentState.todayTransactions,
        ...paginatedResult.items,
      ];

      emit(currentState.copyWith(
        todayTransactions: updatedTransactions,
        currentPage: nextPage,
        hasMore: paginatedResult.hasMore,
        isLoadingMore: false,
      ));
    } catch (error) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  double _calculateTotal(List<Transaction> transactions, TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void changeFilter(DateFilterType filter, {DateTimeRange? customRange}) {
    loadData(filter: filter, customRange: customRange);
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String categoryId,
    required String walletId,
    DateTime? date,
    String? description,
  }) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final transaction = Transaction(
      id: '',
      type: type,
      amount: amount,
      date: date ?? DateTime.now(),
      categoryId: categoryId,
      walletId: walletId,
      description: description,
    );

    // Optimistic: add to list immediately
    final optimisticList = [transaction, ...currentState.todayTransactions];
    final newIncome = currentState.totalIncome +
        (type == TransactionType.income ? amount : 0);
    final newExpense = currentState.totalExpense +
        (type == TransactionType.expense ? amount : 0);

    emit(currentState.copyWith(
      todayTransactions: optimisticList,
      totalIncome: newIncome,
      totalExpense: newExpense,
      totalCount: currentState.totalCount + 1,
    ));

    try {
      await _transactionRepository.add(transaction);
      await loadData();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> updateTransaction({
    required String id,
    required TransactionType type,
    required double amount,
    required String categoryId,
    required String walletId,
    DateTime? date,
    String? description,
  }) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final transaction = Transaction(
      id: id,
      type: type,
      amount: amount,
      date: date ?? DateTime.now(),
      categoryId: categoryId,
      walletId: walletId,
      description: description,
    );

    // Optimistic: replace in list immediately
    final oldTransaction = currentState.todayTransactions.firstWhere(
      (t) => t.id == id,
      orElse: () => transaction,
    );
    final optimisticList = currentState.todayTransactions
        .map((t) => t.id == id ? transaction : t)
        .toList();

    double incomeAdjust = 0;
    double expenseAdjust = 0;
    if (oldTransaction.type == TransactionType.income) {
      incomeAdjust -= oldTransaction.amount;
    } else {
      expenseAdjust -= oldTransaction.amount;
    }
    if (type == TransactionType.income) {
      incomeAdjust += amount;
    } else {
      expenseAdjust += amount;
    }

    emit(currentState.copyWith(
      todayTransactions: optimisticList,
      totalIncome: currentState.totalIncome + incomeAdjust,
      totalExpense: currentState.totalExpense + expenseAdjust,
    ));

    try {
      await _transactionRepository.update(transaction);
      await loadData();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    // Store for undo from local state (no network call needed)
    final deletedTx = currentState.todayTransactions
        .where((t) => t.id == id)
        .toList();
    _recentlyDeletedTransaction = deletedTx.isNotEmpty ? deletedTx.first : null;

    // Optimistic: remove from list immediately
    final optimisticList = currentState.todayTransactions
        .where((t) => t.id != id)
        .toList();

    double incomeAdjust = 0;
    double expenseAdjust = 0;
    if (_recentlyDeletedTransaction != null) {
      if (_recentlyDeletedTransaction!.type == TransactionType.income) {
        incomeAdjust = _recentlyDeletedTransaction!.amount;
      } else {
        expenseAdjust = _recentlyDeletedTransaction!.amount;
      }
    }

    emit(currentState.copyWith(
      todayTransactions: optimisticList,
      totalIncome: currentState.totalIncome - incomeAdjust,
      totalExpense: currentState.totalExpense - expenseAdjust,
      totalCount: currentState.totalCount - 1,
      recentlyDeletedTransaction: _recentlyDeletedTransaction,
    ));

    _startUndoTimer();

    try {
      await _transactionRepository.delete(id);
    } catch (e) {
      _recentlyDeletedTransaction = null;
      emit(currentState);
    }
  }

  Future<void> undoDelete() async {
    _undoTimer?.cancel();

    if (_recentlyDeletedTransaction != null) {
      await _transactionRepository.add(_recentlyDeletedTransaction!);
      _recentlyDeletedTransaction = null;
      await loadData();
    }
  }

  void clearDeletedTransaction() {
    _recentlyDeletedTransaction = null;
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(clearDeletedTransaction: true));
    }
  }

  void _startUndoTimer() {
    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(seconds: 5), () {
      clearDeletedTransaction();
    });
  }

  void toggleSearch() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        isSearching: !currentState.isSearching,
        searchQuery: currentState.isSearching ? '' : currentState.searchQuery,
      ));
    }
  }

  void search(String query) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(searchQuery: query));
    }
  }

  void clearSearch() {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(
        searchQuery: '',
        isSearching: false,
      ));
    }
  }
}
