/// Typed error surface used by repositories so UIs can pattern-match the cause
/// instead of parsing DioException internals.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => '$runtimeType($message)';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'network']);
}

class ServerException extends AppException {
  const ServerException(this.statusCode, String body) : super(body);
  final int statusCode;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'not_found']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'unauthorized']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'unknown']);
}
