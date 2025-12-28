import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/core/models/category.dart';
import 'package:monefy_note_app/core/models/date_filter_type.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/wallet.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Transaction> todayTransactions;
  final List<Category> categories;
  final List<Wallet> wallets;
  final double totalIncome;
  final double totalExpense;
  final Transaction? recentlyDeletedTransaction;
  final DateFilterType filterType;
  final DateTimeRange? customDateRange;
  final String searchQuery;
  final bool isSearching;

  const HomeLoaded({
    required this.todayTransactions,
    required this.categories,
    required this.wallets,
    required this.totalIncome,
    required this.totalExpense,
    this.recentlyDeletedTransaction,
    this.filterType = DateFilterType.today,
    this.customDateRange,
    this.searchQuery = '',
    this.isSearching = false,
  });

  List<Transaction> get filteredTransactions {
    if (searchQuery.isEmpty) return todayTransactions;
    final query = searchQuery.toLowerCase();
    return todayTransactions.where((t) {
      final category = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(id: '', name: '', type: t.type),
      );
      return category.name.toLowerCase().contains(query) ||
          (t.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  double get balance => totalIncome - totalExpense;

  HomeLoaded copyWith({
    List<Transaction>? todayTransactions,
    List<Category>? categories,
    List<Wallet>? wallets,
    double? totalIncome,
    double? totalExpense,
    Transaction? recentlyDeletedTransaction,
    bool clearDeletedTransaction = false,
    DateFilterType? filterType,
    DateTimeRange? customDateRange,
    String? searchQuery,
    bool? isSearching,
  }) {
    return HomeLoaded(
      todayTransactions: todayTransactions ?? this.todayTransactions,
      categories: categories ?? this.categories,
      wallets: wallets ?? this.wallets,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      recentlyDeletedTransaction: clearDeletedTransaction
          ? null
          : (recentlyDeletedTransaction ?? this.recentlyDeletedTransaction),
      filterType: filterType ?? this.filterType,
      customDateRange: customDateRange ?? this.customDateRange,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        todayTransactions,
        categories,
        wallets,
        totalIncome,
        totalExpense,
        recentlyDeletedTransaction,
        filterType,
        customDateRange,
        searchQuery,
        isSearching,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
