import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ws_types.dart';
import '../../../../core/network/ws_client.dart';
import '../../../../domain/entities/message.dart';

/// Per-conversation streamed state: message list + permission queue + thinking flag.
class ChatStreamState {
  const ChatStreamState({
    this.messages = const [],
    this.pending,
    this.thinking = '',
    this.busy = false,
  });

  final List<ChatMessage> messages;
  final PermissionRequest? pending;
  final String thinking;
  final bool busy;

  ChatStreamState copyWith({
    List<ChatMessage>? messages,
    PermissionRequest? pending,
    bool clearPending = false,
    String? thinking,
    bool? busy,
  }) {
    return ChatStreamState(
      messages: messages ?? this.messages,
      pending: clearPending ? null : (pending ?? this.pending),
      thinking: thinking ?? this.thinking,
      busy: busy ?? this.busy,
    );
  }
}

class ChatStreamController extends FamilyAsyncNotifier<ChatStreamState, String> {
  String? _currentMessageId;

  @override
  Future<ChatStreamState> build(String conversationId) async {
    _attach(conversationId);
    return const ChatStreamState();
  }

  void _attach(String convId) {
    final ws = ref.read(wsClientProvider);
    ws.subscribe([WsChannels.chat]);
    final sub = ws.incoming.listen((env) {
      if (env.channel != WsChannels.chat) return;
      final payload = env.payload;
      if (payload['conversation_id'] != convId) return;
      final cur = state.valueOrNull ?? const ChatStreamState();
      switch (env.type) {
        case WsTypes.chatStart:
          _currentMessageId = payload['message_id'] as String?;
          state = AsyncValue.data(cur.copyWith(
            busy: true,
            thinking: '',
            messages: [
              ...cur.messages,
              ChatMessage(
                id: _currentMessageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
                kind: MessageKind.assistant,
                text: '',
                timestamp: DateTime.now(),
              ),
            ],
          ));
          break;
        case WsTypes.chatText:
          final String delta = payload['delta'] as String? ?? '';
          final list = [...cur.messages];
          if (list.isNotEmpty && list.last.kind == MessageKind.assistant) {
            list[list.length - 1] = list.last.appendText(delta);
          }
          state = AsyncValue.data(cur.copyWith(messages: list));
          break;
        case WsTypes.chatThinking:
          final delta = payload['delta'] as String? ?? '';
          state = AsyncValue.data(cur.copyWith(thinking: cur.thinking + delta));
          break;
        case WsTypes.chatToolCallEnd:
          state = AsyncValue.data(cur.copyWith(messages: [
            ...cur.messages,
            ChatMessage(
              id: payload['tool_use_id'] as String? ?? '',
              kind: MessageKind.toolCall,
              text: '',
              toolUseId: payload['tool_use_id'] as String?,
              toolName: payload['tool_name'] as String?,
              toolInput: (payload['input'] as Map?)?.cast<String, Object?>(),
            ),
          ]));
          break;
        case WsTypes.chatToolResult:
          state = AsyncValue.data(cur.copyWith(messages: [
            ...cur.messages,
            ChatMessage(
              id: 'result-${payload['tool_use_id']}',
              kind: MessageKind.toolResult,
              text: payload['output'] as String? ?? '',
              isError: payload['is_error'] as bool? ?? false,
            ),
          ]));
          break;
        case WsTypes.chatPermissionRequest:
          state = AsyncValue.data(cur.copyWith(
            pending: PermissionRequest(
              toolUseId: payload['tool_use_id'] as String? ?? '',
              toolName: payload['tool_name'] as String? ?? '',
              input: (payload['input'] as Map?)?.cast<String, Object?>() ?? const {},
              dangerLevel: payload['danger_level'] as String? ?? 'medium',
            ),
          ));
          break;
        case WsTypes.chatDone:
          state = AsyncValue.data(cur.copyWith(busy: false, thinking: ''));
          break;
        case WsTypes.chatError:
          state = AsyncValue.data(cur.copyWith(busy: false, messages: [
            ...cur.messages,
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              kind: MessageKind.system,
              text: (payload['message'] as String?) ?? 'Hata',
              isError: true,
            ),
          ]));
          break;
      }
    });
    ref.onDispose(sub.cancel);
  }

  void send(String conversationId, String text) {
    final ws = ref.read(wsClientProvider);
    final cur = state.valueOrNull ?? const ChatStreamState();
    final next = cur.copyWith(messages: [
      ...cur.messages,
      ChatMessage(
        id: 'u-${DateTime.now().microsecondsSinceEpoch}',
        kind: MessageKind.user,
        text: text,
        timestamp: DateTime.now(),
      ),
    ]);
    state = AsyncValue.data(next);
    ws.send(WsTypes.chatInput, payload: {'conversation_id': conversationId, 'text': text});
  }

  void abort(String conversationId) {
    ref.read(wsClientProvider).send(WsTypes.chatAbort, payload: {'conversation_id': conversationId});
  }

  void decide(String conversationId, String toolUseId, bool allow, {bool always = false}) {
    ref.read(wsClientProvider).send(WsTypes.chatToolDecision, payload: {
      'conversation_id': conversationId,
      'tool_use_id': toolUseId,
      'decision': allow ? (always ? 'allow_always' : 'allow') : (always ? 'deny_always' : 'deny'),
    });
    final cur = state.valueOrNull ?? const ChatStreamState();
    state = AsyncValue.data(cur.copyWith(clearPending: true));
  }
}

final chatStreamProvider =
    AsyncNotifierProvider.family<ChatStreamController, ChatStreamState, String>(ChatStreamController.new);
