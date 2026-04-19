import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/ws_types.dart';
import '../../../core/l10n/strings_tr.dart';
import '../../../core/network/ws_client.dart';
import '../widgets/arrow_key_pad.dart';
import '../widgets/ctrl_key_row.dart';
import '../widgets/term_tab_bar.dart';
import '../widgets/xterm_view.dart';
import 'providers/terminal_sessions_provider.dart';

class TerminalPage extends HookConsumerWidget {
  const TerminalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(terminalSessionsProvider);
    final activeId = ref.watch(activeTerminalIdProvider);

    useEffect(() {
      Future<void>.microtask(() async {
        final sessions = await ref.read(terminalSessionsProvider.future);
        if (sessions.isEmpty) {
          final s = await ref.read(terminalSessionsProvider.notifier).newTab();
          ref.read(activeTerminalIdProvider.notifier).state = s.id;
        } else if (activeId == null) {
          ref.read(activeTerminalIdProvider.notifier).state = sessions.first.id;
        }
      });
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.navTerminal),
        actions: [
          IconButton(
            tooltip: S.terminalNewTab,
            icon: const Icon(Icons.add),
            onPressed: () async {
              final s = await ref.read(terminalSessionsProvider.notifier).newTab();
              ref.read(activeTerminalIdProvider.notifier).state = s.id;
            },
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (sessions) {
          final id = activeId ?? (sessions.isNotEmpty ? sessions.first.id : null);
          return Column(
            children: [
              TermTabBar(
                sessions: sessions,
                activeId: id,
                onTap: (id) => ref.read(activeTerminalIdProvider.notifier).state = id,
                onClose: (id) => ref.read(terminalSessionsProvider.notifier).close(id),
                onNew: () async {
                  final s = await ref.read(terminalSessionsProvider.notifier).newTab();
                  ref.read(activeTerminalIdProvider.notifier).state = s.id;
                },
              ),
              Expanded(
                child: id == null
                    ? const Center(child: Text('Sekme yok'))
                    : Container(color: Colors.black, child: XtermView(terminalId: id)),
              ),
              if (id != null) ...[
                CtrlKeyRow(
                  onSend: (data) => ref.read(wsClientProvider).send(
                        WsTypes.terminalInput,
                        payload: {'terminal_id': id, 'data': data},
                      ),
                ),
                ArrowKeyPad(
                  onSend: (data) => ref.read(wsClientProvider).send(
                        WsTypes.terminalInput,
                        payload: {'terminal_id': id, 'data': data},
                      ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
