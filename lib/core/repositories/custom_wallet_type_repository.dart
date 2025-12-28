import '../models/custom_wallet_type.dart';

abstract class CustomWalletTypeRepository {
  Future<List<CustomWalletType>> getAll();
  Future<CustomWalletType?> getById(String id);
  Future<void> add(CustomWalletType type);
  Future<void> update(CustomWalletType type);
  Future<void> delete(String id);
}
