import 'package:monefy_note_app/core/datasources/remote/wallet_remote_datasource.dart';
import 'package:monefy_note_app/core/models/wallet.dart';
import 'package:monefy_note_app/core/repositories/wallet_repository.dart';

class RemoteWalletRepository implements WalletRepository {
  final WalletRemoteDatasource _remoteDatasource;

  RemoteWalletRepository(this._remoteDatasource);

  @override
  Future<List<Wallet>> getAll() => _remoteDatasource.getAll();

  @override
  Future<Wallet?> getById(String id) async {
    try {
      return await _remoteDatasource.getById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Wallet wallet) => _remoteDatasource.create(wallet);

  @override
  Future<void> update(Wallet wallet) => _remoteDatasource.update(wallet);

  @override
  Future<void> delete(String id) => _remoteDatasource.delete(id);

  @override
  Future<void> updateBalance(String id, double amount) async {
    // Get current wallet, then update with new balance
    final wallet = await _remoteDatasource.getById(id);
    final newBalance = wallet.balance + amount;
    await _remoteDatasource.update(wallet.copyWith(balance: newBalance));
  }
}
