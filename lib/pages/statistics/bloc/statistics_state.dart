import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/core/models/category.dart';
import 'package:monefy_note_app/core/models/date_filter_type.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/wallet.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final List<Transaction> transactions;
  final List<Category> categories;
  final List<Wallet> wallets;
  final double totalIncome;
  final double totalExpense;
  final DateFilterType filterType;
  final DateTimeRange? customDateRange;
  final List<CategoryStatistic> expenseByCategory;
  final List<CategoryStatistic> incomeByCategory;
  final List<DailyStatistic> dailyStatistics;
  final List<WalletStatistic> walletStatistics;

  const StatisticsLoaded({
    required this.transactions,
    required this.categories,
    required this.wallets,
    required this.totalIncome,
    required this.totalExpense,
    required this.filterType,
    this.customDateRange,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.dailyStatistics,
    required this.walletStatistics,
  });

  double get balance => totalIncome - totalExpense;

  StatisticsLoaded copyWith({
    List<Transaction>? transactions,
    List<Category>? categories,
    List<Wallet>? wallets,
    double? totalIncome,
    double? totalExpense,
    DateFilterType? filterType,
    DateTimeRange? customDateRange,
    List<CategoryStatistic>? expenseByCategory,
    List<CategoryStatistic>? incomeByCategory,
    List<DailyStatistic>? dailyStatistics,
    List<WalletStatistic>? walletStatistics,
  }) {
    return StatisticsLoaded(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      wallets: wallets ?? this.wallets,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      filterType: filterType ?? this.filterType,
      customDateRange: customDateRange ?? this.customDateRange,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      incomeByCategory: incomeByCategory ?? this.incomeByCategory,
      dailyStatistics: dailyStatistics ?? this.dailyStatistics,
      walletStatistics: walletStatistics ?? this.walletStatistics,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        categories,
        wallets,
        totalIncome,
        totalExpense,
        filterType,
        customDateRange,
        expenseByCategory,
        incomeByCategory,
        dailyStatistics,
        walletStatistics,
      ];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryStatistic {
  final Category category;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategoryStatistic({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

class DailyStatistic {
  final DateTime date;
  final double income;
  final double expense;

  const DailyStatistic({
    required this.date,
    required this.income,
    required this.expense,
  });

  double get balance => income - expense;
}

class WalletStatistic {
  final Wallet wallet;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  const WalletStatistic({
    required this.wallet,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  double get netFlow => totalIncome - totalExpense;
}
