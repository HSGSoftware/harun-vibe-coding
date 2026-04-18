import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';

import '../../../core/constants/ws_types.dart';
import '../../../core/network/ws_client.dart';

/// xterm.dart view wired to a backend PTY via WebSocket.
/// Input goes out as `terminal.input`; backend pushes `terminal.data` chunks.
class XtermView extends ConsumerStatefulWidget {
  const XtermView({super.key, required this.terminalId});
  final String terminalId;

  @override
  ConsumerState<XtermView> createState() => _XtermViewState();
}

class _XtermViewState extends ConsumerState<XtermView> {
  final Terminal _term = Terminal(maxLines: 10000);
  final TerminalController _ctrl = TerminalController();
  StreamSubscription<WsEnvelope>? _sub;

  @override
  void initState() {
    super.initState();
    final ws = ref.read(wsClientProvider);
    ws.subscribe([WsChannels.terminal]);
    _term.onOutput = (data) {
      ws.send(WsTypes.terminalInput, payload: {
        'terminal_id': widget.terminalId,
        'data': data,
      });
    };
    _term.onResize = (cols, rows, _, __) {
      ws.send(WsTypes.terminalResize, payload: {
        'terminal_id': widget.terminalId,
        'cols': cols,
        'rows': rows,
      });
    };
    _sub = ws.incoming.listen((env) {
      if (env.channel != WsChannels.terminal) return;
      if (env.payload['terminal_id'] != widget.terminalId) return;
      if (env.type == WsTypes.terminalData) {
        final data = env.payload['data'] as String? ?? '';
        _term.write(data);
      } else if (env.type == WsTypes.terminalExit) {
        _term.write('\r\n[Terminal kapandı]\r\n');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TerminalView(
      _term,
      controller: _ctrl,
      autofocus: true,
      backgroundOpacity: 1.0,
      textStyle: const TerminalStyle(
        fontSize: 13,
        fontFamily: 'JetBrainsMono',
      ),
    );
  }
}
