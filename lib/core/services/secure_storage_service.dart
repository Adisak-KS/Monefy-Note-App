import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _keySecurityCredential = 'security_credential';
  static const _keyPatternData = 'pattern_data';

  // Singleton
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Hash the credential using SHA-256
  String _hashCredential(String credential) {
    final bytes = utf8.encode(credential);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Save security credential (PIN or Password)
  Future<void> saveSecurityCredential(String credential) async {
    final hashedCredential = _hashCredential(credential);
    await _storage.write(key: _keySecurityCredential, value: hashedCredential);
  }

  /// Verify security credential
  Future<bool> verifyCredential(String credential) async {
    final storedHash = await _storage.read(key: _keySecurityCredential);
    if (storedHash == null) return false;

    final inputHash = _hashCredential(credential);
    return storedHash == inputHash;
  }

  /// Save pattern data (as comma-separated dot indices)
  Future<void> savePatternCredential(List<int> pattern) async {
    final patternString = pattern.join(',');
    final hashedPattern = _hashCredential(patternString);
    await _storage.write(key: _keyPatternData, value: hashedPattern);
  }

  /// Verify pattern credential
  Future<bool> verifyPatternCredential(List<int> pattern) async {
    final storedHash = await _storage.read(key: _keyPatternData);
    if (storedHash == null) return false;

    final patternString = pattern.join(',');
    final inputHash = _hashCredential(patternString);
    return storedHash == inputHash;
  }

  /// Clear all security credentials
  Future<void> clearCredentials() async {
    await _storage.delete(key: _keySecurityCredential);
    await _storage.delete(key: _keyPatternData);
  }

  /// Check if any credential is stored
  Future<bool> hasCredential() async {
    final pin = await _storage.read(key: _keySecurityCredential);
    final pattern = await _storage.read(key: _keyPatternData);
    return pin != null || pattern != null;
  }
}
