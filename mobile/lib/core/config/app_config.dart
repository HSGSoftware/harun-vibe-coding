import 'package:flutter/foundation.dart';

/// Runtime configuration injected by [main] once native bridges have resolved
/// the Termux host + server token. Immutable once published to Riverpod.
@immutable
class AppConfig {
  const AppConfig({
    required this.serverBaseUrl,
    required this.wsUrl,
    required this.authToken,
    required this.isDebug,
  });

  final String serverBaseUrl;
  final String wsUrl;
  final String authToken;
  final bool isDebug;

  factory AppConfig.defaults() {
    return const AppConfig(
      serverBaseUrl: 'http://127.0.0.1:8080',
      wsUrl: 'ws://127.0.0.1:8080/ws',
      authToken: '',
      isDebug: kDebugMode,
    );
  }

  AppConfig copyWith({String? serverBaseUrl, String? wsUrl, String? authToken}) {
    return AppConfig(
      serverBaseUrl: serverBaseUrl ?? this.serverBaseUrl,
      wsUrl: wsUrl ?? this.wsUrl,
      authToken: authToken ?? this.authToken,
      isDebug: isDebug,
    );
  }
}
