import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/remote/wallet_remote_datasource.dart';
import '../datasources/remote/transaction_remote_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';
import '../datasources/remote/budget_remote_datasource.dart';
import '../datasources/remote/transfer_remote_datasource.dart';
import '../datasources/remote/wallet_type_remote_datasource.dart';
import '../network/dio_client.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/custom_wallet_type_repository.dart';
import '../repositories/remote/remote_wallet_repository.dart';
import '../repositories/remote/remote_transaction_repository.dart';
import '../repositories/remote/remote_category_repository.dart';
import '../repositories/remote/remote_budget_repository.dart';
import '../repositories/remote/remote_custom_wallet_type_repository.dart';

/// Singleton instance of SharedPreferences - must be initialized before DI
/// Accessible from other modules (e.g. AuthModule)
late SharedPreferences sharedPreferencesInstance;

/// Initialize SharedPreferences
/// Call this before configureDependencies()
Future<void> initializeRepositories() async {
  sharedPreferencesInstance = await SharedPreferences.getInstance();
}

@module
abstract class RepositoryModule {
  // Remote Datasources
  @lazySingleton
  WalletRemoteDatasource walletRemoteDatasource(DioClient dioClient) =>
      WalletRemoteDatasourceImpl(dioClient);

  @lazySingleton
  TransactionRemoteDatasource transactionRemoteDatasource(DioClient dioClient) =>
      TransactionRemoteDatasourceImpl(dioClient);

  @lazySingleton
  CategoryRemoteDatasource categoryRemoteDatasource(DioClient dioClient) =>
      CategoryRemoteDatasourceImpl(dioClient);

  @lazySingleton
  BudgetRemoteDatasource budgetRemoteDatasource(DioClient dioClient) =>
      BudgetRemoteDatasourceImpl(dioClient);

  @lazySingleton
  TransferRemoteDatasource transferRemoteDatasource(DioClient dioClient) =>
      TransferRemoteDatasourceImpl(dioClient);

  // Remote Repositories
  @lazySingleton
  WalletRepository walletRepository(WalletRemoteDatasource ds) =>
      RemoteWalletRepository(ds);

  @lazySingleton
  TransactionRepository transactionRepository(TransactionRemoteDatasource ds) =>
      RemoteTransactionRepository(ds);

  @lazySingleton
  CategoryRepository categoryRepository(CategoryRemoteDatasource ds) =>
      RemoteCategoryRepository(ds);

  @lazySingleton
  BudgetRepository budgetRepository(BudgetRemoteDatasource ds) =>
      RemoteBudgetRepository(ds);

  @lazySingleton
  WalletTypeRemoteDatasource walletTypeRemoteDatasource(DioClient dioClient) =>
      WalletTypeRemoteDatasourceImpl(dioClient);

  @lazySingleton
  CustomWalletTypeRepository customWalletTypeRepository(WalletTypeRemoteDatasource ds) =>
      RemoteCustomWalletTypeRepository(ds);
}
