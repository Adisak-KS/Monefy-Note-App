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
    final currentState = state;
    if (currentState is! CustomWalletTypeLoaded) return;

    // Optimistic: add to list immediately
    emit(CustomWalletTypeLoaded(types: [...currentState.types, type]));

    try {
      await _repository.add(type);
      await _refreshTypes();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> updateType(CustomWalletType type) async {
    final currentState = state;
    if (currentState is! CustomWalletTypeLoaded) return;

    // Optimistic: replace in list immediately
    final optimisticTypes = currentState.types
        .map((t) => t.id == type.id ? type : t)
        .toList();
    emit(CustomWalletTypeLoaded(types: optimisticTypes));

    try {
      await _repository.update(type);
      await _refreshTypes();
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> deleteType(String id) async {
    final currentState = state;
    if (currentState is! CustomWalletTypeLoaded) return;

    // Optimistic: remove from list immediately
    final optimisticTypes = currentState.types
        .where((t) => t.id != id)
        .toList();
    emit(CustomWalletTypeLoaded(types: optimisticTypes));

    try {
      await _repository.delete(id);
    } catch (e) {
      emit(currentState);
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
