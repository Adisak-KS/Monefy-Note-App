import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/wallet.dart';
import '../../services/mock_data_service.dart';
import '../wallet_repository.dart';

/// Local implementation of WalletRepository using SharedPreferences
class LocalWalletRepository implements WalletRepository {
  static const _key = 'local_wallets';
  final SharedPreferences _prefs;

  LocalWalletRepository(this._prefs);

  /// Initialize with default data if empty
  Future<void> initialize() async {
    final existing = _prefs.getString(_key);
    if (existing == null) {
      // Initialize with default wallets
      await _saveAll(MockDataService.defaultWallets);
    }
  }

  Future<void> _saveAll(List<Wallet> wallets) async {
    final jsonList = wallets.map((w) => w.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<Wallet>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Wallet.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Wallet?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Wallet wallet) async {
    final all = await getAll();
    all.add(wallet);
    await _saveAll(all);
  }

  @override
  Future<void> update(Wallet wallet) async {
    final all = await getAll();
    final index = all.indexWhere((w) => w.id == wallet.id);
    if (index != -1) {
      all[index] = wallet;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((w) => w.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> updateBalance(String id, double amount) async {
    final all = await getAll();
    final index = all.indexWhere((w) => w.id == id);
    if (index != -1) {
      final wallet = all[index];
      all[index] = wallet.copyWith(balance: wallet.balance + amount);
      await _saveAll(all);
    }
  }
}
