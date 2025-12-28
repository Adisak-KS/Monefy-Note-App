import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/models/transaction_type.dart';
import '../../../../../core/repositories/transaction_repository.dart';
import '../../../../../core/repositories/category_repository.dart';
import 'wallet_detail_state.dart';

@injectable
class WalletDetailCubit extends Cubit<WalletDetailState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  WalletDetailCubit(
    this._transactionRepository,
    this._categoryRepository,
  ) : super(const WalletDetailInitial());

  Future<void> loadTransactions(String walletId) async {
    emit(const WalletDetailLoading());

    try {
      final transactions = await _transactionRepository.getByWalletId(walletId);
      final categories = await _categoryRepository.getAll();

      // Map category to each transaction
      final transactionsWithCategory = transactions.map((t) {
        final category = categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => categories.first,
        );
        return t.copyWith(category: category);
      }).toList();

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;

      for (final t in transactionsWithCategory) {
        if (t.type == TransactionType.income) {
          totalIncome += t.amount;
        } else {
          totalExpense += t.amount;
        }
      }

      emit(WalletDetailLoaded(
        transactions: transactionsWithCategory,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ));
    } catch (e) {
      emit(WalletDetailError(e.toString()));
    }
  }
}
