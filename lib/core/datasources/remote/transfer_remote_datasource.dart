import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/network/dio_client.dart';

abstract class TransferRemoteDatasource {
  Future<void> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  });
}

class TransferRemoteDatasourceImpl implements TransferRemoteDatasource {
  final DioClient _dioClient;

  TransferRemoteDatasourceImpl(this._dioClient);

  @override
  Future<void> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  }) async {
    await _dioClient.post(
      ApiEndpoint.transfers,
      data: {
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'amount': amount,
        if (description != null) 'description': description,
      },
    );
  }
}
