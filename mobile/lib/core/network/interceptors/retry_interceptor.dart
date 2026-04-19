import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Retries idempotent requests (GET / HEAD) on network errors with exponential backoff.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, required this.log, this.maxAttempts = 3});
  final Dio dio;
  final Logger log;
  final int maxAttempts;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final bool idempotent = err.requestOptions.method == 'GET' || err.requestOptions.method == 'HEAD';
    final bool transient = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
    if (!idempotent || !transient) {
      handler.next(err);
      return;
    }
    final int attempt = (err.requestOptions.extra['retry_attempt'] as int? ?? 0) + 1;
    if (attempt > maxAttempts) {
      handler.next(err);
      return;
    }
    final Duration delay = Duration(milliseconds: 250 * (1 << (attempt - 1)));
    await Future<void>.delayed(delay);
    try {
      final Response<dynamic> response = await dio.fetch<dynamic>(
        err.requestOptions..extra['retry_attempt'] = attempt,
      );
      handler.resolve(response);
    } catch (retryErr) {
      if (retryErr is DioException) {
        handler.next(retryErr);
      } else {
        handler.next(err);
      }
    }
  }
}
