import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/wallet_type.dart';
import '../../../core/repositories/wallet_repository.dart';
import 'wallet_state.dart';

const _uuid = Uuid();

@injectable
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _walletRepository;

  WalletCubit(this._walletRepository) : super(const WalletInitial());

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
    if (state is! WalletLoaded) return;

    try {
      await _walletRepository.add(wallet);
      await _refreshWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    if (state is! WalletLoaded) return;

    try {
      await _walletRepository.update(wallet);
      await _refreshWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> deleteWallet(String id) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    try {
      // Find wallet before deleting for undo
      final deletedWallet = currentState.wallets.firstWhere(
        (w) => w.id == id,
        orElse: () => throw Exception('Wallet not found'),
      );

      await _walletRepository.delete(id);
      final wallets = await _walletRepository.getAll();
      final (totalBalance, totalDebt) = _calculateTotals(wallets);

      emit(WalletLoaded(
        wallets: wallets,
        totalBalance: totalBalance,
        totalDebt: totalDebt,
        recentlyDeletedWallet: deletedWallet,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> undoDelete() async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;
    if (currentState.recentlyDeletedWallet == null) return;

    try {
      await _walletRepository.add(currentState.recentlyDeletedWallet!);
      await _refreshWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
  }) async {
    if (state is! WalletLoaded) return;
    if (amount <= 0) return;

    try {
      // Deduct from source wallet
      await _walletRepository.updateBalance(fromWalletId, -amount);
      // Add to destination wallet
      await _walletRepository.updateBalance(toWalletId, amount);

      await _refreshWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// Duplicate a wallet with a new ID and zero balance
  Future<void> duplicateWallet(Wallet wallet) async {
    if (state is! WalletLoaded) return;

    try {
      final duplicatedWallet = wallet.copyWith(
        id: _uuid.v4(),
        name: '${wallet.name} (Copy)',
        balance: 0,
      );
      await _walletRepository.add(duplicatedWallet);
      await _refreshWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// Archive a wallet (hide from main list)
  Future<void> archiveWallet(String id) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    try {
      final wallet = currentState.wallets.firstWhere(
        (w) => w.id == id,
        orElse: () => throw Exception('Wallet not found'),
      );
      final archivedWallet = wallet.copyWith(isArchived: true);
      await _walletRepository.update(archivedWallet);
      await _refreshWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// Unarchive a wallet (show in main list)
  Future<void> unarchiveWallet(String id) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    try {
      final wallet = currentState.wallets.firstWhere(
        (w) => w.id == id,
        orElse: () => throw Exception('Wallet not found'),
      );
      final unarchivedWallet = wallet.copyWith(isArchived: false);
      await _walletRepository.update(unarchivedWallet);
      await _refreshWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
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
