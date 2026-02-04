import 'dart:convert';

import 'package:monefy_note_app/core/datasources/remote/auth_remote_datasource.dart';
import 'package:monefy_note_app/core/models/user.dart';
import 'package:monefy_note_app/core/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AuthRemoteDatasource _remoteDataSource;
  final TokenService _tokenService;
  final SharedPreferences _prefs;

  static const _userKey = 'current_user';
  static const _isLoggedInKey = 'is_logged_in';

  AuthRepository(this._remoteDataSource, this._tokenService, this._prefs);

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    final result = await _remoteDataSource.signUp(
      email: email,
      password: password,
      name: name,
      username: username,
    );

    await _saveAuthState(result.user, result.tokens);
    return result.user;
  }

  Future<User> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    final result = await _remoteDataSource.signIn(
      emailOrUsername: emailOrUsername,
      password: password,
    );

    await _saveAuthState(result.user, result.tokens);
    return result.user;
  }

  Future<void> signOut() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      await _remoteDataSource.signOut(refreshToken);
    } catch (_) {
      // Ingore error, clear local state anyway
    } finally {
      await _clearAuthState();
    }
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<User> refreshCurrentUser() async {
    final user = await _remoteDataSource.getCurrentUser();
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> _saveAuthState(User user, dynamic tokens) async {
    await _tokenService.saveToken(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> _clearAuthState() async {
    await _tokenService.clearTokens();
    await _prefs.remove(_userKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }
}
