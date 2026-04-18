import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import '../constants/ws_types.dart';
import 'api_client.dart';

/// Connection state for UI indicators.
enum WsStatus { idle, connecting, connected, disconnected, error }

/// Single long-lived WebSocket. Feature layers reach streams via [WsChannel].
/// Reconnect is exponential-backoff; after reconnect the client emits a `resume`
/// control message with the last known envelope id (see plan.md §6.6).
class WsClient {
  WsClient({required this.config, required this.log});

  final AppConfig config;
  final Logger log;
  final Uuid _uuid = const Uuid();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _backoff = 0;
  bool _stopped = false;
  String? _lastEnvelopeId;

  final StreamController<WsEnvelope> _in = StreamController<WsEnvelope>.broadcast();
  final StreamController<WsStatus> _status = StreamController<WsStatus>.broadcast();

  Stream<WsEnvelope> get incoming => _in.stream;
  Stream<WsStatus> get status => _status.stream;

  Future<void> connect() async {
    _stopped = false;
    _status.add(WsStatus.connecting);
    final Uri uri = Uri.parse(_withToken(config.wsUrl));
    try {
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (Object err, StackTrace st) {
          log.w('ws error: $err');
          _scheduleReconnect();
        },
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
      _status.add(WsStatus.connected);
      _backoff = 0;
      _startPing();
      if (_lastEnvelopeId != null) {
        send(WsTypes.resume, payload: {'from_id': _lastEnvelopeId});
      }
    } catch (e) {
      log.w('ws connect failed: $e');
      _status.add(WsStatus.error);
      _scheduleReconnect();
    }
  }

  void subscribe(List<String> channels) {
    send(WsTypes.subscribe, payload: {'channels': channels});
  }

  void unsubscribe(List<String> channels) {
    send(WsTypes.unsubscribe, payload: {'channels': channels});
  }

  void send(String type, {Object? payload}) {
    final ch = _channel;
    if (ch == null) {
      log.w('ws send dropped (no channel): $type');
      return;
    }
    final Map<String, Object?> frame = {
      'type': type,
      if (payload != null) 'payload': payload,
      'id': _uuid.v4(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    ch.sink.add(jsonEncode(frame));
  }

  Future<void> close() async {
    _stopped = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _status.add(WsStatus.disconnected);
  }

  void _onMessage(Object? data) {
    if (data is! String) return;
    try {
      final Map<String, dynamic> raw = jsonDecode(data) as Map<String, dynamic>;
      final env = WsEnvelope(
        channel: raw['channel'] as String? ?? '',
        type: raw['type'] as String? ?? '',
        id: raw['id'] as String? ?? '',
        timestamp: (raw['timestamp'] as num?)?.toInt() ?? 0,
        payload: (raw['payload'] as Map<String, dynamic>?) ?? const {},
      );
      if (env.id.isNotEmpty) _lastEnvelopeId = env.id;
      _in.add(env);
    } catch (e) {
      log.w('ws parse failed: $e');
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      send(WsTypes.ping, payload: {'t': DateTime.now().millisecondsSinceEpoch});
    });
  }

  void _scheduleReconnect() {
    if (_stopped) return;
    _pingTimer?.cancel();
    _status.add(WsStatus.disconnected);
    _backoff = (_backoff == 0) ? 500 : (_backoff * 2).clamp(500, 15000);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: _backoff), connect);
  }

  String _withToken(String url) {
    if (config.authToken.isEmpty) return url;
    final Uri uri = Uri.parse(url);
    final Map<String, String> qp = Map.of(uri.queryParameters);
    qp['token'] = config.authToken;
    return uri.replace(queryParameters: qp).toString();
  }
}

class WsEnvelope {
  const WsEnvelope({
    required this.channel,
    required this.type,
    required this.id,
    required this.timestamp,
    required this.payload,
  });

  final String channel;
  final String type;
  final String id;
  final int timestamp;
  final Map<String, dynamic> payload;
}

final wsClientProvider = Provider<WsClient>((ref) {
  final WsClient client = WsClient(
    config: ref.watch(appConfigProvider),
    log: ref.watch(apiLoggerProvider),
  );
  ref.onDispose(() => unawaited(client.close()));
  return client;
});
