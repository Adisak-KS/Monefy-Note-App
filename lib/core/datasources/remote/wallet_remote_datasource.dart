import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/models/wallet.dart';
import 'package:monefy_note_app/core/network/dio_client.dart';

abstract class WalletRemoteDatasource {
  Future<List<Wallet>> getAll();
  Future<Wallet> getById(String id);
  Future<Wallet> create(Wallet wallet);
  Future<Wallet> update(Wallet wallet);
  Future<void> delete(String id);
  Future<Wallet> updateBalance(String id, double amount);
}

class WalletRemoteDatasourceImpl implements WalletRemoteDatasource {
  final DioClient _dioClient;

  WalletRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<Wallet>> getAll() async {
    final response = await _dioClient.get(ApiEndpoint.wallets);
    final data = response.data['data'] as List;
    return data.map((json) => Wallet.fromJson(json)).toList();
  }

  @override
  Future<Wallet> getById(String id) async {
    final response = await _dioClient.get(ApiEndpoint.wallet(id));
    return Wallet.fromJson(response.data['data']);
  }

  @override
  Future<Wallet> create(Wallet wallet) async {
    final response = await _dioClient.post(
      ApiEndpoint.wallets,
      data: wallet.toJson()..remove('id'),
    );
    return Wallet.fromJson(response.data['data']);
  }

  @override
  Future<Wallet> update(Wallet wallet) async {
    final response = await _dioClient.put(
      ApiEndpoint.wallet(wallet.id),
      data: wallet.toJson()..remove('id'),
    );
    return Wallet.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(String id) async {
    await _dioClient.delete(ApiEndpoint.wallet(id));
  }

  @override
  Future<Wallet> updateBalance(String id, double amount) async {
    final response = await _dioClient.put(
      ApiEndpoint.wallet(id),
      data: {'balance': amount},
    );
    return Wallet.fromJson(response.data['data']);
  }
}
