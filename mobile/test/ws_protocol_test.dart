import 'package:flutter_test/flutter_test.dart';

import 'package:harun_vibe_coding/core/constants/ws_types.dart';

void main() {
  group('WsTypes', () {
    test('chat types are prefixed with chat.', () {
      expect(WsTypes.chatStart.startsWith('chat.'), isTrue);
      expect(WsTypes.chatText.startsWith('chat.'), isTrue);
      expect(WsTypes.chatToolCallStart.startsWith('chat.'), isTrue);
    });
    test('events types are prefixed with events.', () {
      expect(WsTypes.projectStatus.startsWith('events.'), isTrue);
      expect(WsTypes.notification.startsWith('events.'), isTrue);
    });
    test('channel names match backend', () {
      expect(WsChannels.chat, 'chat');
      expect(WsChannels.terminal, 'terminal');
      expect(WsChannels.events, 'events');
      expect(WsChannels.fs, 'fs');
    });
  });
}
