import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/ws_types.dart';
import '../../../core/network/ws_client.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/ansi_parser.dart';
import '../../../data/repositories_impl/projects_repository_impl.dart';

class ProjectLogsPage extends HookConsumerWidget {
  const ProjectLogsPage({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = useState<List<String>>(const <String>[]);
    final scrollCtrl = useScrollController();

    useEffect(() {
      Future<void>.microtask(() async {
        final String log = await ref.read(projectsRepositoryProvider).logs(projectId);
        if (log.isNotEmpty) lines.value = log.split('\n');
      });
      final ws = ref.read(wsClientProvider);
      ws.subscribe([WsChannels.events]);
      final StreamSubscription<WsEnvelope> sub = ws.incoming.listen((env) {
        if (env.type != WsTypes.projectLog) return;
        if (env.payload['project_id'] != projectId) return;
        final String line = env.payload['line'] as String? ?? '';
        if (line.isEmpty) return;
        lines.value = [...lines.value, line];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollCtrl.hasClients) {
            scrollCtrl.jumpTo(scrollCtrl.position.maxScrollExtent);
          }
        });
      });
      return sub.cancel;
    }, const []);

    final parser = AnsiParser(defaultStyle: kMonoStyle.copyWith(color: Colors.white));
    return Scaffold(
      appBar: AppBar(title: const Text('Loglar')),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(8),
          itemCount: lines.value.length,
          itemBuilder: (_, i) {
            final spans = parser.parse(lines.value[i]);
            return Text.rich(TextSpan(
              children: [for (final s in spans) TextSpan(text: s.text, style: s.style)],
            ));
          },
        ),
      ),
    );
  }
}
