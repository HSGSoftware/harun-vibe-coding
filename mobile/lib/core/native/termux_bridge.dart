import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dart handle over the Kotlin TermuxBridge. Channel name MUST match §8.3.
class TermuxBridge {
  TermuxBridge() : _channel = const MethodChannel('com.harun.vibecoding/termux');
  final MethodChannel _channel;

  Future<bool> isInstalled() async =>
      await _channel.invokeMethod<bool>('isInstalled') ?? false;

  Future<bool> isAllowExternalAppsSet() async =>
      await _channel.invokeMethod<bool>('isAllowExternalAppsSet') ?? false;

  Future<Map<String, Object?>> runScript({
    required String scriptPath,
    required String workdir,
    bool background = true,
  }) async {
    final Object? res = await _channel.invokeMethod<Object?>('runScript', <String, Object?>{
      'scriptPath': scriptPath,
      'workdir': workdir,
      'background': background,
    });
    return Map<String, Object?>.from(res as Map? ?? const <dynamic, dynamic>{});
  }

  Future<void> openTermux() => _channel.invokeMethod<void>('openTermux');
  Future<void> openPlayStore() => _channel.invokeMethod<void>('openPlayStore');
}

final termuxBridgeProvider = Provider<TermuxBridge>((ref) => TermuxBridge());
