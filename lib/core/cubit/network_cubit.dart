import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monefy_note_app/core/services/network_service.dart';

class NetworkCubit extends Cubit<NetworkStatus> {
  NetworkCubit() : super(NetworkService.instance.currentStatus) {
    _subscription = NetworkService.instance.networkStatusStream.listen((status) {
      emit(status);
    });
  }

  StreamSubscription<NetworkStatus>? _subscription;

  bool get isOnline => state == NetworkStatus.online;
  bool get isOffline => state == NetworkStatus.offline;

  Future<void> checkConnection() async {
    final isConnected = await NetworkService.instance.isConnected();
    emit(isConnected ? NetworkStatus.online : NetworkStatus.offline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
