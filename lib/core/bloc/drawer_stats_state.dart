import 'package:equatable/equatable.dart';

class DrawerStatsState extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;
  final bool isLoading;

  const DrawerStatsState({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.transactionCount = 0,
    this.isLoading = false,
  });

  DrawerStatsState copyWith({
    double? totalIncome,
    double? totalExpense,
    int? transactionCount,
    bool? isLoading,
  }) {
    return DrawerStatsState(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      transactionCount: transactionCount ?? this.transactionCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [totalIncome, totalExpense, transactionCount, isLoading];
}
