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
/// Accessible from other modules (e.g. AuthModule)
late SharedPreferences sharedPreferencesInstance;

/// Initialize SharedPreferences and local repositories
/// Call this before configureDependencies()
Future<void> initializeRepositories() async {
  sharedPreferencesInstance = await SharedPreferences.getInstance();

  // Initialize local repositories with default data if needed
  final transactionRepo = LocalTransactionRepository(sharedPreferencesInstance);
  final walletRepo = LocalWalletRepository(sharedPreferencesInstance);
  final categoryRepo = LocalCategoryRepository(sharedPreferencesInstance);
  final budgetRepo = LocalBudgetRepository(sharedPreferencesInstance);

  await categoryRepo.initialize();
  await walletRepo.initialize();
  await transactionRepo.initialize();
  await budgetRepo.initialize();
}

@module
abstract class RepositoryModule {
  @lazySingleton
  WalletRepository get walletRepository => LocalWalletRepository(sharedPreferencesInstance);

  @lazySingleton
  TransactionRepository get transactionRepository => LocalTransactionRepository(sharedPreferencesInstance);

  @lazySingleton
  CategoryRepository get categoryRepository => LocalCategoryRepository(sharedPreferencesInstance);

  @lazySingleton
  BudgetRepository get budgetRepository => LocalBudgetRepository(sharedPreferencesInstance);

  @lazySingleton
  CustomWalletTypeRepository get customWalletTypeRepository =>
      MockCustomWalletTypeRepository();
}
