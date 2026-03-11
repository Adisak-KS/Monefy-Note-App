import 'package:monefy_note_app/core/datasources/remote/wallet_type_remote_datasource.dart';
import 'package:monefy_note_app/core/models/custom_wallet_type.dart';
import 'package:monefy_note_app/core/repositories/custom_wallet_type_repository.dart';

class RemoteCustomWalletTypeRepository implements CustomWalletTypeRepository {
  final WalletTypeRemoteDatasource _remoteDatasource;

  RemoteCustomWalletTypeRepository(this._remoteDatasource);

  @override
  Future<List<CustomWalletType>> getAll() => _remoteDatasource.getAll();

  @override
  Future<CustomWalletType?> getById(String id) async {
    try {
      return await _remoteDatasource.getById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(CustomWalletType type) => _remoteDatasource.create(type);

  @override
  Future<void> update(CustomWalletType type) => _remoteDatasource.update(type);

  @override
  Future<void> delete(String id) => _remoteDatasource.delete(id);
}
