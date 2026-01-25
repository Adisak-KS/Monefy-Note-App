import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');

      case DioExceptionType.badResponse:
        return _handleBadResponse(err.response);

      default:
        return UnknownException(err.message ?? 'Unknown error');
    }
  }

  ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;
    final message = data?['message'] ?? 'Unknown error';

    switch (statusCode) {
      case 400:
        return ValidationException(
          message,
          details: data?['error']?['details'],
        );
      case 401:
        return AuthException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 429:
        return RateLimitException(message);
      default:
        return ServerException(message);
    }
  }
}
