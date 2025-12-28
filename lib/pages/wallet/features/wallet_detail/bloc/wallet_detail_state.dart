import 'package:equatable/equatable.dart';
import '../../../../../core/models/transaction.dart';

abstract class WalletDetailState extends Equatable {
  const WalletDetailState();

  @override
  List<Object?> get props => [];
}

class WalletDetailInitial extends WalletDetailState {
  const WalletDetailInitial();
}

class WalletDetailLoading extends WalletDetailState {
  const WalletDetailLoading();
}

class WalletDetailLoaded extends WalletDetailState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;

  const WalletDetailLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpense];
}

class WalletDetailError extends WalletDetailState {
  final String message;

  const WalletDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
