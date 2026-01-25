import 'package:dio/dio.dart';
import 'package:monefy_note_app/core/constants/api_endpoint.dart';
import 'package:monefy_note_app/core/network/auth_interceptor.dart';
import 'package:monefy_note_app/core/network/error_interceptor.dart';
import 'package:monefy_note_app/core/services/token_service.dart';

class DioClient {
  late final Dio _dio;
  final TokenService _tokenService;

  DioClient(this._tokenService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoint.baseUrl,
        connectTimeout: ApiEndpoint.connectTimeOut,
        receiveTimeout: ApiEndpoint.receiveTime,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_tokenService, _dio),
      ErrorInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  // POST request
  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  // PUT request
  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  // DELETE request
  Future<Response<T>> delete<T>(String path) {
    return _dio.delete(path);
  }
}
