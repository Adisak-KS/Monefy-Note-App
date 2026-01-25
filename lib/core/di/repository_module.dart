import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/custom_wallet_type_repository.dart';
import '../repositories/local/local_wallet_repository.dart';
import '../repositories/local/local_transaction_repository.dart';
import '../repositories/local/local_category_repository.dart';
import '../repositories/local/local_budget_repository.dart';
import '../repositories/mock/mock_custom_wallet_type_repository.dart';

/// Singleton instance of SharedPreferences - must be initialized before DI
late SharedPreferences _sharedPreferences;

/// Initialize SharedPreferences and local repositories
/// Call this before configureDependencies()
Future<void> initializeRepositories() async {
  _sharedPreferences = await SharedPreferences.getInstance();

  // Initialize local repositories with default data if needed
  final transactionRepo = LocalTransactionRepository(_sharedPreferences);
  final walletRepo = LocalWalletRepository(_sharedPreferences);
  final categoryRepo = LocalCategoryRepository(_sharedPreferences);
  final budgetRepo = LocalBudgetRepository(_sharedPreferences);

  await categoryRepo.initialize();
  await walletRepo.initialize();
  await transactionRepo.initialize();
  await budgetRepo.initialize();
}

@module
abstract class RepositoryModule {
  @lazySingleton
  WalletRepository get walletRepository => LocalWalletRepository(_sharedPreferences);

  @lazySingleton
  TransactionRepository get transactionRepository => LocalTransactionRepository(_sharedPreferences);

  @lazySingleton
  CategoryRepository get categoryRepository => LocalCategoryRepository(_sharedPreferences);

  @lazySingleton
  BudgetRepository get budgetRepository => LocalBudgetRepository(_sharedPreferences);

  @lazySingleton
  CustomWalletTypeRepository get customWalletTypeRepository =>
      MockCustomWalletTypeRepository();
}
