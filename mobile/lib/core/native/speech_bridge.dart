import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Android SpeechRecognizer bridge. Events stream partial/final results.
class SpeechBridge {
  SpeechBridge()
      : _method = const MethodChannel('com.harun.vibecoding/speech'),
        _events = const EventChannel('com.harun.vibecoding/speech_events');

  final MethodChannel _method;
  final EventChannel _events;

  Future<bool> isAvailable() async =>
      await _method.invokeMethod<bool>('isAvailable') ?? false;

  Future<void> start({String locale = 'tr-TR'}) {
    return _method.invokeMethod<void>('start', <String, Object>{'locale': locale});
  }

  Future<void> stop() => _method.invokeMethod<void>('stop');
  Future<void> cancel() => _method.invokeMethod<void>('cancel');

  Stream<SpeechEvent> events() {
    return _events.receiveBroadcastStream().map((raw) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(raw as Map);
      return SpeechEvent(kind: m['kind'] as String? ?? '', text: m['text'] as String?);
    });
  }
}

class SpeechEvent {
  const SpeechEvent({required this.kind, this.text});
  final String kind;
  final String? text;
}

final speechBridgeProvider = Provider<SpeechBridge>((ref) => SpeechBridge());
