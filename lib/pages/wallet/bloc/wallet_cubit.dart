import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/datasources/remote/transfer_remote_datasource.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/wallet_type.dart';
import '../../../core/repositories/wallet_repository.dart';
import 'wallet_state.dart';

@injectable
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _walletRepository;
  final TransferRemoteDatasource _transferDatasource;

  WalletCubit(this._walletRepository, this._transferDatasource)
      : super(const WalletInitial());

  Future<void> loadWallets() async {
    emit(const WalletLoading());

    try {
      final wallets = await _walletRepository.getAll();
      final (totalBalance, totalDebt) = _calculateTotals(wallets);

      emit(WalletLoaded(
        wallets: wallets,
        totalBalance: totalBalance,
        totalDebt: totalDebt,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    // Optimistic: add wallet to list immediately
    final optimisticWallets = [...currentState.wallets, wallet];
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
    ));

    try {
      await _walletRepository.add(wallet);
      await _refreshWallets();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    // Optimistic: replace wallet in list immediately
    final optimisticWallets = currentState.wallets
        .map((w) => w.id == wallet.id ? wallet : w)
        .toList();
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
    ));

    try {
      await _walletRepository.update(wallet);
      await _refreshWallets();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> deleteWallet(String id) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    final deletedWallets = currentState.wallets.where((w) => w.id == id).toList();
    if (deletedWallets.isEmpty) return;
    final deletedWallet = deletedWallets.first;

    // Optimistic: remove from list immediately
    final optimisticWallets = currentState.wallets
        .where((w) => w.id != id)
        .toList();
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
      recentlyDeletedWallet: deletedWallet,
    ));

    try {
      await _walletRepository.delete(id);
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> undoDelete() async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;
    if (currentState.recentlyDeletedWallet == null) return;

    final restoredWallet = currentState.recentlyDeletedWallet!;

    // Optimistic: add back to list immediately
    final optimisticWallets = [...currentState.wallets, restoredWallet];
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
    ));

    try {
      await _walletRepository.add(restoredWallet);
      await _refreshWallets();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  }) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;
    if (amount <= 0) return;

    // Optimistic: update balances immediately
    final optimisticWallets = currentState.wallets.map((w) {
      if (w.id == fromWalletId) return w.copyWith(balance: w.balance - amount);
      if (w.id == toWalletId) return w.copyWith(balance: w.balance + amount);
      return w;
    }).toList();
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
    ));

    try {
      await _transferDatasource.transfer(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        description: description,
      );
      await _refreshWallets();
    } catch (e) {
      emit(currentState);
    }
  }

  /// Duplicate a wallet with a new ID and zero balance
  Future<void> duplicateWallet(Wallet wallet) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    final duplicatedWallet = wallet.copyWith(
      id: '',
      name: '${wallet.name} (Copy)',
      balance: 0,
    );

    // Optimistic: add duplicate to list immediately
    final optimisticWallets = [...currentState.wallets, duplicatedWallet];
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
    ));

    try {
      await _walletRepository.add(duplicatedWallet);
      await _refreshWallets();
    } catch (e) {
      emit(currentState);
    }
  }

  /// Archive a wallet (hide from main list)
  Future<void> archiveWallet(String id) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    final walletMatches = currentState.wallets.where((w) => w.id == id).toList();
    if (walletMatches.isEmpty) return;

    // Optimistic: mark as archived immediately
    final optimisticWallets = currentState.wallets
        .map((w) => w.id == id ? w.copyWith(isArchived: true) : w)
        .toList();
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
    ));

    try {
      final archivedWallet = walletMatches.first.copyWith(isArchived: true);
      await _walletRepository.update(archivedWallet);
      await _refreshWallets();
    } catch (e) {
      emit(currentState);
    }
  }

  /// Unarchive a wallet (show in main list)
  Future<void> unarchiveWallet(String id) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    final walletMatches = currentState.wallets.where((w) => w.id == id).toList();
    if (walletMatches.isEmpty) return;

    // Optimistic: mark as unarchived immediately
    final optimisticWallets = currentState.wallets
        .map((w) => w.id == id ? w.copyWith(isArchived: false) : w)
        .toList();
    final (totalBalance, totalDebt) = _calculateTotals(optimisticWallets);
    emit(WalletLoaded(
      wallets: optimisticWallets,
      totalBalance: totalBalance,
      totalDebt: totalDebt,
    ));

    try {
      final unarchivedWallet = walletMatches.first.copyWith(isArchived: false);
      await _walletRepository.update(unarchivedWallet);
      await _refreshWallets();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> _refreshWallets() async {
    try {
      final wallets = await _walletRepository.getAll();
      final (totalBalance, totalDebt) = _calculateTotals(wallets);

      emit(WalletLoaded(
        wallets: wallets,
        totalBalance: totalBalance,
        totalDebt: totalDebt,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  (double, double) _calculateTotals(List<Wallet> wallets) {
    double totalBalance = 0;
    double totalDebt = 0;

    for (final wallet in wallets) {
      // Skip wallets that are excluded from total or archived
      if (!wallet.includeInTotal || wallet.isArchived) continue;

      if (wallet.type.isLiability) {
        totalDebt += wallet.balance.abs();
      } else {
        totalBalance += wallet.balance;
      }
    }

    return (totalBalance, totalDebt);
  }
}
