import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/models/custom_wallet_type.dart';
import '../../../../../core/repositories/custom_wallet_type_repository.dart';
import 'custom_wallet_type_state.dart';

@injectable
class CustomWalletTypeCubit extends Cubit<CustomWalletTypeState> {
  final CustomWalletTypeRepository _repository;

  CustomWalletTypeCubit(this._repository)
      : super(const CustomWalletTypeInitial());

  Future<void> loadTypes() async {
    emit(const CustomWalletTypeLoading());

    try {
      final types = await _repository.getAll();
      emit(CustomWalletTypeLoaded(types: types));
    } catch (e) {
      emit(CustomWalletTypeError(e.toString()));
    }
  }

  Future<void> addType(CustomWalletType type) async {
    if (state is! CustomWalletTypeLoaded) return;

    try {
      await _repository.add(type);
      await _refreshTypes();
    } catch (e) {
      emit(CustomWalletTypeError(e.toString()));
    }
  }

  Future<void> updateType(CustomWalletType type) async {
    if (state is! CustomWalletTypeLoaded) return;

    try {
      await _repository.update(type);
      await _refreshTypes();
    } catch (e) {
      emit(CustomWalletTypeError(e.toString()));
    }
  }

  Future<void> deleteType(String id) async {
    if (state is! CustomWalletTypeLoaded) return;

    try {
      await _repository.delete(id);
      await _refreshTypes();
    } catch (e) {
      emit(CustomWalletTypeError(e.toString()));
    }
  }

  Future<void> _refreshTypes() async {
    try {
      final types = await _repository.getAll();
      emit(CustomWalletTypeLoaded(types: types));
    } catch (e) {
      emit(CustomWalletTypeError(e.toString()));
    }
  }
}
