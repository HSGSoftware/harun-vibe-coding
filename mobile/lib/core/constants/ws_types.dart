/// WebSocket message type + channel constants. Must match plan.md §6 and the
/// backend `ws` package.
class WsChannels {
  const WsChannels._();
  static const String chat = 'chat';
  static const String terminal = 'terminal';
  static const String events = 'events';
  static const String fs = 'fs';
  static const String aiEvents = 'ai_events';
  static const String control = 'control';
}

class WsTypes {
  const WsTypes._();

  // Control
  static const String subscribe = 'subscribe';
  static const String unsubscribe = 'unsubscribe';
  static const String ping = 'ping';
  static const String pong = 'control.pong';
  static const String resume = 'resume';

  // Chat (server -> client)
  static const String chatStart = 'chat.start';
  static const String chatThinking = 'chat.thinking';
  static const String chatText = 'chat.text';
  static const String chatToolCallStart = 'chat.tool_call_start';
  static const String chatToolInputDelta = 'chat.tool_input_delta';
  static const String chatToolCallEnd = 'chat.tool_call_end';
  static const String chatPermissionRequest = 'chat.permission_request';
  static const String chatToolResult = 'chat.tool_result';
  static const String chatDone = 'chat.done';
  static const String chatError = 'chat.error';

  // Chat (client -> server)
  static const String chatInput = 'chat.input';
  static const String chatAbort = 'chat.abort';
  static const String chatToolDecision = 'chat.tool_decision';

  // Terminal
  static const String terminalAttach = 'terminal.attach';
  static const String terminalInput = 'terminal.input';
  static const String terminalResize = 'terminal.resize';
  static const String terminalData = 'terminal.data';
  static const String terminalExit = 'terminal.exit';

  // Events
  static const String projectStatus = 'events.project_status';
  static const String projectLog = 'events.project_log';
  static const String tunnelReady = 'events.tunnel_ready';
  static const String backupCreated = 'events.backup_created';
  static const String backupFailed = 'events.backup_failed';
  static const String notification = 'events.notification';
  static const String setupRequired = 'events.setup_required';

  // FS
  static const String fsChange = 'fs.change';
}
