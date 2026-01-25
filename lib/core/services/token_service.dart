import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenService()
    : _storage = const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  // Save Tokens
  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Get Tokens
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  // Check if logged in
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // Clear tokens on logout
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // Check if token is expiring soon (within 60 seconds)
  bool isTokenExpiringSoon(String token) {
    try {
      final expiry = _decodeTokenExpiry(token);
      final now = DateTime.now();
      return expiry.difference(now).inSeconds < 60;
    } catch (_) {
      return true; // Assume expired if can't decode
    }
  }

  // Decode JWT expiry without verification
  DateTime _decodeTokenExpiry(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid token');

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );

    final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
    final exp = payloadMap['exp'] as int;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }
}
