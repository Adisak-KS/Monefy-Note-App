import 'package:injectable/injectable.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/custom_wallet_type_repository.dart';
import '../repositories/mock/mock_wallet_repository.dart';
import '../repositories/mock/mock_transaction_repository.dart';
import '../repositories/mock/mock_category_repository.dart';
import '../repositories/mock/mock_budget_repository.dart';
import '../repositories/mock/mock_custom_wallet_type_repository.dart';

@module
abstract class RepositoryModule {
  @lazySingleton
  WalletRepository get walletRepository => MockWalletRepository();

  @lazySingleton
  TransactionRepository get transactionRepository => MockTransactionRepository();

  @lazySingleton
  CategoryRepository get categoryRepository => MockCategoryRepository();

  @lazySingleton
  BudgetRepository get budgetRepository => MockBudgetRepository();

  @lazySingleton
  CustomWalletTypeRepository get customWalletTypeRepository =>
      MockCustomWalletTypeRepository();
}
