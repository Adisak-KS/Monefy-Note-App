// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/bloc/drawer_stats_cubit.dart' as _i410;
import 'core/di/repository_module.dart' as _i29;
import 'core/di/service_module.dart' as _i429;
import 'core/repositories/budget_repository.dart' as _i432;
import 'core/repositories/category_repository.dart' as _i94;
import 'core/repositories/custom_wallet_type_repository.dart' as _i453;
import 'core/repositories/transaction_repository.dart' as _i140;
import 'core/repositories/wallet_repository.dart' as _i678;
import 'core/services/preferences_service.dart' as _i811;
import 'pages/budgets/bloc/budget_cubit.dart' as _i458;
import 'pages/categories/bloc/category_cubit.dart' as _i723;
import 'pages/home/bloc/home_cubit.dart' as _i65;
import 'pages/settings/bloc/settings_cubit.dart' as _i78;
import 'pages/statistics/bloc/statistics_cubit.dart' as _i339;
import 'pages/wallet/bloc/wallet_cubit.dart' as _i984;
import 'pages/wallet/features/add_wallet_type/bloc/custom_wallet_type_cubit.dart'
    as _i749;
import 'pages/wallet/features/wallet_detail/bloc/wallet_detail_cubit.dart'
    as _i650;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final repositoryModule = _$RepositoryModule();
    final serviceModule = _$ServiceModule();
    gh.lazySingleton<_i410.DrawerStatsCubit>(() => _i410.DrawerStatsCubit());
    gh.lazySingleton<_i678.WalletRepository>(
      () => repositoryModule.walletRepository,
    );
    gh.lazySingleton<_i140.TransactionRepository>(
      () => repositoryModule.transactionRepository,
    );
    gh.lazySingleton<_i94.CategoryRepository>(
      () => repositoryModule.categoryRepository,
    );
    gh.lazySingleton<_i432.BudgetRepository>(
      () => repositoryModule.budgetRepository,
    );
    gh.lazySingleton<_i453.CustomWalletTypeRepository>(
      () => repositoryModule.customWalletTypeRepository,
    );
    gh.lazySingleton<_i811.PreferencesService>(
      () => serviceModule.preferencesService,
    );
    gh.factory<_i339.StatisticsCubit>(
      () => _i339.StatisticsCubit(
        gh<_i140.TransactionRepository>(),
        gh<_i94.CategoryRepository>(),
        gh<_i678.WalletRepository>(),
      ),
    );
    gh.factory<_i749.CustomWalletTypeCubit>(
      () => _i749.CustomWalletTypeCubit(gh<_i453.CustomWalletTypeRepository>()),
    );
    gh.factory<_i984.WalletCubit>(
      () => _i984.WalletCubit(gh<_i678.WalletRepository>()),
    );
    gh.factory<_i78.SettingsCubit>(
      () => _i78.SettingsCubit(gh<_i811.PreferencesService>()),
    );
    gh.factory<_i65.HomeCubit>(
      () => _i65.HomeCubit(
        gh<_i140.TransactionRepository>(),
        gh<_i94.CategoryRepository>(),
        gh<_i678.WalletRepository>(),
        gh<_i410.DrawerStatsCubit>(),
      ),
    );
    gh.factory<_i650.WalletDetailCubit>(
      () => _i650.WalletDetailCubit(
        gh<_i140.TransactionRepository>(),
        gh<_i94.CategoryRepository>(),
      ),
    );
    gh.factory<_i458.BudgetCubit>(
      () => _i458.BudgetCubit(
        gh<_i432.BudgetRepository>(),
        gh<_i94.CategoryRepository>(),
      ),
    );
    gh.factory<_i723.CategoryCubit>(
      () => _i723.CategoryCubit(gh<_i94.CategoryRepository>()),
    );
    return this;
  }
}

class _$RepositoryModule extends _i29.RepositoryModule {}

class _$ServiceModule extends _i429.ServiceModule {}
