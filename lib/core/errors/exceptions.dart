abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class AuthException extends ApiException {
  AuthException(super.message);
}

class ValidationException extends ApiException {
  final List<dynamic>? details;
  ValidationException(super.message, {this.details});
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ConflictException extends ApiException {
  ConflictException(super.message);
}

class RateLimitException extends ApiException {
  RateLimitException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class UnknownException extends ApiException {
  UnknownException(super.message);
}
