import 'package:injectable/injectable.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../network/dio_client.dart';
import '../repositories/auth_repository.dart';
import '../services/token_service.dart';
import 'repository_module.dart';

@module
abstract class AuthModule {
  @lazySingleton
  TokenService get tokenService => TokenService();

  @lazySingleton
  DioClient get dioClient => DioClient(tokenService);

  @lazySingleton
  AuthRemoteDatasource get authRemoteDatasource =>
      AuthRemoteDataSourceImpl(dioClient);

  @lazySingleton
  AuthRepository get authRepository => AuthRepository(
        authRemoteDatasource,
        tokenService,
        sharedPreferencesInstance,
      );
}
