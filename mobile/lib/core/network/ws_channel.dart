import 'dart:async';

import '../constants/ws_types.dart';
import 'ws_client.dart';

/// Filters envelopes by channel + optional type prefix. Features subscribe here
/// instead of reading [WsClient.incoming] directly so they never see unrelated
/// traffic.
class WsChannel {
  WsChannel(this._client, this.channel);

  final WsClient _client;
  final String channel;

  Stream<WsEnvelope> stream({String? typePrefix}) {
    _client.subscribe([channel]);
    return _client.incoming.where((env) {
      if (env.channel != channel) return false;
      if (typePrefix != null && !env.type.startsWith(typePrefix)) return false;
      return true;
    });
  }

  void send(String type, Object? payload) => _client.send(type, payload: payload);

  void detach() => _client.unsubscribe([channel]);
}

/// Convenience constructors for each logical channel.
extension WsClientChannels on WsClient {
  WsChannel chatChannel() => WsChannel(this, WsChannels.chat);
  WsChannel terminalChannel() => WsChannel(this, WsChannels.terminal);
  WsChannel eventsChannel() => WsChannel(this, WsChannels.events);
  WsChannel fsChannel() => WsChannel(this, WsChannels.fs);
  WsChannel aiEventsChannel() => WsChannel(this, WsChannels.aiEvents);
}
