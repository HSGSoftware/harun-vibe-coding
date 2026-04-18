import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lifecycle_bridge.dart';

/// Thin wrapper that maps domain notifications onto the native service call.
class NotificationBridge {
  NotificationBridge(this._lifecycle);
  final LifecycleBridge _lifecycle;

  Future<void> post({
    required int id,
    required String title,
    required String body,
    String category = 'system',
    String? deepLink,
  }) {
    return _lifecycle.postNotification(
      id: id,
      title: title,
      body: body,
      category: category,
      deepLink: deepLink,
    );
  }

  Future<void> cancel(int id) => _lifecycle.cancelNotification(id);
}

final notificationBridgeProvider = Provider<NotificationBridge>((ref) {
  return NotificationBridge(ref.watch(lifecycleBridgeProvider));
});
