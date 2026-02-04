import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/models/auth_token.dart';
import 'package:monefy_note_app/core/models/user.dart';
import 'package:monefy_note_app/core/network/dio_client.dart';

abstract class AuthRemoteDatasource {
  Future<({User user, AuthTokens tokens})> signUp({
    required String email,
    required String password,
    required String name,
    String? username,
  });

  Future<({User user, AuthTokens tokens})> signIn({
    required String emailOrUsername,
    required String password,
  });

  Future<AuthTokens> refreshToken(String refreshToken);
  Future<void> signOut(String? refreshToken);
  Future<User> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDatasource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<({User user, AuthTokens tokens})> signUp({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoint.signUp,
      data: {
        'email': email,
        'password': password,
        'name': name,
        if (username != null) 'username': username,
      },
    );

    final data = response.data['data'];
    return (
      user: User.fromJson(data['user']),
      tokens: AuthTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      ),
    );
  }

  @override
  Future<({User user, AuthTokens tokens})> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoint.signIn,
      data: {'emailOrUsername': emailOrUsername, 'password': password},
    );

    final data = response.data['data'];
    return (
      user: User.fromJson(data['user']),
      tokens: AuthTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      ),
    );
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      ApiEndpoint.refresh,
      data: {'refreshToken': refreshToken},
    );

    final data = response.data['data'];
    return AuthTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  @override
  Future<void> signOut(String? refreshToken) async {
    await _dioClient.post(
      ApiEndpoint.signOut,
      data: refreshToken != null ? {'refreshToken': refreshToken} : null,
    );
  }

  @override
  Future<User> getCurrentUser() async {
    final response = await _dioClient.get(ApiEndpoint.me);
    return User.fromJson(response.data['data']);
  }
}
