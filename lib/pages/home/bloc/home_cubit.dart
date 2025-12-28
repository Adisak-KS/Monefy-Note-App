import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monefy_note_app/core/models/date_filter_type.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/repositories/category_repository.dart';
import 'package:monefy_note_app/core/repositories/transaction_repository.dart';
import 'package:monefy_note_app/core/repositories/wallet_repository.dart';
import 'package:monefy_note_app/pages/home/bloc/home_state.dart';
import 'package:uuid/uuid.dart';

class HomeCubit extends Cubit<HomeState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final WalletRepository _walletRepository;
  static const _uuid = Uuid();

  Transaction? _recentlyDeletedTransaction;
  Timer? _undoTimer;
  DateFilterType _currentFilter = DateFilterType.today;
  DateTimeRange? _customDateRange;

  HomeCubit({
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required WalletRepository walletRepository,
  }) : _transactionRepository = transactionRepository,
       _categoryRepository = categoryRepository,
       _walletRepository = walletRepository,
       super(HomeInitial());

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

      final transactions = await _transactionRepository.getByDateRange(
        dateRange.start,
        dateRange.end,
      );
      final categories = await _categoryRepository.getAll();
      final wallets = await _walletRepository.getAll();

      final totalIncome = _calculateTotal(transactions, TransactionType.income);
      final totalExpense = _calculateTotal(transactions, TransactionType.expense);

      emit(
        HomeLoaded(
          todayTransactions: transactions,
          categories: categories,
          wallets: wallets,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          filterType: _currentFilter,
          customDateRange: _customDateRange,
        ),
      );
    } catch (error) {
      emit(HomeError(error.toString()));
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
    final transaction = Transaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      date: date ?? DateTime.now(),
      categoryId: categoryId,
      walletId: walletId,
      description: description,
    );

    await _transactionRepository.add(transaction);
    await loadData();
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
    final transaction = Transaction(
      id: id,
      type: type,
      amount: amount,
      date: date ?? DateTime.now(),
      categoryId: categoryId,
      walletId: walletId,
      description: description,
    );

    await _transactionRepository.update(transaction);
    await loadData();
  }

  Future<void> deleteTransaction(String id) async {
    // Store transaction before deleting for undo
    _recentlyDeletedTransaction = await _transactionRepository.getById(id);

    await _transactionRepository.delete(id);

    if (state is HomeLoaded && _recentlyDeletedTransaction != null) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        todayTransactions: currentState.todayTransactions
            .where((t) => t.id != id)
            .toList(),
        recentlyDeletedTransaction: _recentlyDeletedTransaction,
      ));

      _startUndoTimer();
    } else {
      await loadData();
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
