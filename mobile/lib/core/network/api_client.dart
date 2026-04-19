import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Thin Dio wrapper. Features never touch Dio directly — they go through a
/// repository which holds an [ApiClient].
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return _dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {Object? body, Map<String, dynamic>? query}) {
    return _dio.post<T>(path, data: body, queryParameters: query);
  }

  Future<Response<T>> put<T>(String path, {Object? body}) {
    return _dio.put<T>(path, data: body);
  }

  Future<Response<T>> patch<T>(String path, {Object? body}) {
    return _dio.patch<T>(path, data: body);
  }

  Future<Response<T>> delete<T>(String path, {Object? body, Map<String, dynamic>? query}) {
    return _dio.delete<T>(path, data: body, queryParameters: query);
  }

  Dio get raw => _dio;
}

final appConfigProvider = StateProvider<AppConfig>((ref) => AppConfig.defaults());

final apiLoggerProvider = Provider<Logger>((ref) => Logger(printer: PrettyPrinter(methodCount: 0)));

final apiClientProvider = Provider<ApiClient>((ref) {
  final AppConfig cfg = ref.watch(appConfigProvider);
  final Logger log = ref.watch(apiLoggerProvider);
  final Dio dio = Dio(BaseOptions(
    baseUrl: cfg.serverBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.addAll([
    AuthInterceptor(() => cfg.authToken),
    RetryInterceptor(dio: dio, log: log),
    LoggingInterceptor(log: log, enabled: cfg.isDebug),
  ]);
  return ApiClient(dio);
});
