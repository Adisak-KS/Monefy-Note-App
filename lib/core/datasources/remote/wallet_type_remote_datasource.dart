import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/models/custom_wallet_type.dart';
import 'package:monefy_note_app/core/network/dio_client.dart';

abstract class WalletTypeRemoteDatasource {
  Future<List<CustomWalletType>> getAll();
  Future<CustomWalletType> getById(String id);
  Future<CustomWalletType> create(CustomWalletType type);
  Future<CustomWalletType> update(CustomWalletType type);
  Future<void> delete(String id);
}

class WalletTypeRemoteDatasourceImpl implements WalletTypeRemoteDatasource {
  final DioClient _dioClient;

  WalletTypeRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<CustomWalletType>> getAll() async {
    final response = await _dioClient.get(ApiEndpoint.walletTypes);
    final data = response.data['data'] as List;
    return data.map((json) => CustomWalletType.fromJson(json)).toList();
  }

  @override
  Future<CustomWalletType> getById(String id) async {
    final response = await _dioClient.get(ApiEndpoint.walletType(id));
    return CustomWalletType.fromJson(response.data['data']);
  }

  @override
  Future<CustomWalletType> create(CustomWalletType type) async {
    final response = await _dioClient.post(
      ApiEndpoint.walletTypes,
      data: {
        'name': type.name,
        'iconName': type.iconName,
        'colorHex': type.colorHex,
        'isLiability': type.isLiability,
      },
    );
    return CustomWalletType.fromJson(response.data['data']);
  }

  @override
  Future<CustomWalletType> update(CustomWalletType type) async {
    final response = await _dioClient.put(
      ApiEndpoint.walletType(type.id),
      data: {
        'name': type.name,
        'iconName': type.iconName,
        'colorHex': type.colorHex,
        'isLiability': type.isLiability,
      },
    );
    return CustomWalletType.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(String id) async {
    await _dioClient.delete(ApiEndpoint.walletType(id));
  }
}
