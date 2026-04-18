import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Converts Dio errors and generic exceptions to the repository-facing
/// [AppException] hierarchy.
AppException mapError(Object err) {
  if (err is AppException) return err;
  if (err is DioException) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final int? code = err.response?.statusCode;
        if (code == 401 || code == 403) return const AuthException();
        if (code == 404) return const NotFoundException();
        return ServerException(code ?? 0, err.response?.data?.toString() ?? err.message ?? '');
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownException(err.message ?? 'unknown');
    }
  }
  return UnknownException(err.toString());
}
