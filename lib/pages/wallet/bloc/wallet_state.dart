import 'package:equatable/equatable.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/wallet_type.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final List<Wallet> wallets;
  final double totalBalance;
  final double totalDebt;
  final Wallet? recentlyDeletedWallet;

  const WalletLoaded({
    required this.wallets,
    required this.totalBalance,
    required this.totalDebt,
    this.recentlyDeletedWallet,
  });

  /// Get wallets that are not archived
  List<Wallet> get activeWallets => wallets.where((w) => !w.isArchived).toList();

  /// Get wallets that are archived
  List<Wallet> get archivedWallets => wallets.where((w) => w.isArchived).toList();

  /// Get wallets that are assets (positive balance types) and included in total
  List<Wallet> get assetWallets => wallets
      .where((w) => !w.isArchived && w.includeInTotal && !w.type.isLiability)
      .toList();

  /// Get wallets that are liabilities (debt, credit card, loan) and included in total
  List<Wallet> get debtWallets => wallets
      .where((w) => !w.isArchived && w.includeInTotal && w.type.isLiability)
      .toList();

  WalletLoaded copyWith({
    List<Wallet>? wallets,
    double? totalBalance,
    double? totalDebt,
    Wallet? recentlyDeletedWallet,
  }) {
    return WalletLoaded(
      wallets: wallets ?? this.wallets,
      totalBalance: totalBalance ?? this.totalBalance,
      totalDebt: totalDebt ?? this.totalDebt,
      recentlyDeletedWallet: recentlyDeletedWallet,
    );
  }

  @override
  List<Object?> get props => [wallets, totalBalance, totalDebt, recentlyDeletedWallet];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
