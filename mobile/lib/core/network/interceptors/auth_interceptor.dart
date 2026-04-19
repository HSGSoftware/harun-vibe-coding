import 'package:dio/dio.dart';

/// Injects the shared X-Harun-Token header (set by the server at first boot).
/// The token is supplied via a callback so rotation is picked up without
/// rebuilding the interceptor chain.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._token);
  final String Function() _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String t = _token();
    if (t.isNotEmpty) {
      options.headers['X-Harun-Token'] = t;
    }
    handler.next(options);
  }
}
