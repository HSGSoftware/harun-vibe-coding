import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the Android ServerLifecycleService foreground notification.
class LifecycleBridge {
  LifecycleBridge() : _channel = const MethodChannel('com.harun.vibecoding/service');
  final MethodChannel _channel;

  Future<void> startForeground(String title, String text) {
    return _channel.invokeMethod<void>('startForeground', <String, Object>{'title': title, 'text': text});
  }

  Future<void> stopForeground() => _channel.invokeMethod<void>('stopForeground');

  Future<void> updateForeground(String title, String text) {
    return _channel.invokeMethod<void>('updateForeground', <String, Object>{'title': title, 'text': text});
  }

  Future<void> postNotification({
    required int id,
    required String title,
    required String body,
    required String category,
    String? deepLink,
  }) {
    return _channel.invokeMethod<void>('postNotification', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'deep_link': deepLink,
    });
  }

  Future<void> cancelNotification(int id) {
    return _channel.invokeMethod<void>('cancelNotification', <String, Object>{'id': id});
  }

  Future<void> requestBatteryExempt() => _channel.invokeMethod<void>('requestBatteryExempt');
}

final lifecycleBridgeProvider = Provider<LifecycleBridge>((ref) => LifecycleBridge());
