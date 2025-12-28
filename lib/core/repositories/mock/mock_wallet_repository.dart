import 'package:monefy_note_app/core/models/wallet.dart';
import 'package:monefy_note_app/core/repositories/wallet_repository.dart';
import 'package:monefy_note_app/core/services/mock_data_service.dart';

class MockWalletRepository implements WalletRepository {
  final List<Wallet> _wallets = List.from(MockDataService.defaultWallets);

  @override
  Future<List<Wallet>> getAll() async {
    return _wallets;
  }

  @override
  Future<Wallet?> getById(String id) async {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Wallet wallet) async {
    _wallets.add(wallet);
  }

  @override
  Future<void> update(Wallet wallet) async {
    final index = _wallets.indexWhere((w) => w.id == wallet.id);
    if (index != -1) {
      _wallets[index] = wallet;
    }
  }

  @override
  Future<void> delete(String id) async {
    _wallets.removeWhere((w) => w.id == id);
  }

  @override
  Future<void> updateBalance(String id, double amount) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      final wallet = _wallets[index];
      _wallets[index] = wallet.copyWith(balance: wallet.balance + amount);
    }
  }
}
