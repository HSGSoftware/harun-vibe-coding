/// Logical message kinds rendered in the chat list.
enum MessageKind { user, assistant, toolCall, toolResult, system }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.kind,
    required this.text,
    this.toolUseId,
    this.toolName,
    this.toolInput,
    this.isError = false,
    this.timestamp,
  });

  final String id;
  final MessageKind kind;
  final String text;
  final String? toolUseId;
  final String? toolName;
  final Map<String, Object?>? toolInput;
  final bool isError;
  final DateTime? timestamp;

  ChatMessage appendText(String delta) {
    return ChatMessage(
      id: id,
      kind: kind,
      text: text + delta,
      toolUseId: toolUseId,
      toolName: toolName,
      toolInput: toolInput,
      isError: isError,
      timestamp: timestamp,
    );
  }
}

class PermissionRequest {
  const PermissionRequest({
    required this.toolUseId,
    required this.toolName,
    required this.input,
    this.dangerLevel = 'medium',
  });
  final String toolUseId;
  final String toolName;
  final Map<String, Object?> input;
  final String dangerLevel;
}
