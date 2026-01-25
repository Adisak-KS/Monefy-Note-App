import 'package:dio/dio.dart';
import '../constants/api_endpoint.dart';
import '../services/token_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;

  AuthInterceptor(this._tokenService, this._dio);

  // Endpoints ที่ไม่ต้องใช้ token
  static const _publicEndpoints = [
    ApiEndpoint.signIn,
    ApiEndpoint.signUp,
    ApiEndpoint.refresh,
    ApiEndpoint.forgotPassword,
    ApiEndpoint.resetPassword,
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ข้าม auth header สำหรับ public endpoints
    final isPublic = _publicEndpoints.any((e) => options.path.contains(e));
    if (isPublic) {
      return handler.next(options);
    }

    // แนบ token
    final accessToken = await _tokenService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ถ้า 401 → ลอง refresh token
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry request เดิม
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (_) {
        // Refresh failed → clear tokens
        await _tokenService.clearTokens();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiEndpoint.refresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data['data'];
      await _tokenService.saveToken(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final accessToken = await _tokenService.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
