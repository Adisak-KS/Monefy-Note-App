import '../../models/custom_wallet_type.dart';
import '../custom_wallet_type_repository.dart';

class MockCustomWalletTypeRepository implements CustomWalletTypeRepository {
  final List<CustomWalletType> _types = [];

  @override
  Future<List<CustomWalletType>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_types);
  }

  @override
  Future<CustomWalletType?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _types.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(CustomWalletType type) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _types.add(type.copyWith(createdAt: DateTime.now()));
  }

  @override
  Future<void> update(CustomWalletType type) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _types.indexWhere((t) => t.id == type.id);
    if (index != -1) {
      _types[index] = type;
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _types.removeWhere((t) => t.id == id);
  }
}
