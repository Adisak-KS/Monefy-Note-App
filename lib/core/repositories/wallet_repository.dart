import '../models/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAll();
  Future<Wallet?> getById(String id);
  Future<void> add(Wallet wallet);
  Future<void> update(Wallet wallet);
  Future<void> delete(String id);
  Future<void> updateBalance(String id, double amount);
}
