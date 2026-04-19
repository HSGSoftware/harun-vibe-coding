import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../domain/entities/cli_status.dart';
import '../../../features/setup/presentation/providers/setup_controller.dart';

class AiSettingsPage extends ConsumerWidget {
  const AiSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(setupControllerProvider);
    final data = async.valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.settingsAi),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(setupControllerProvider.notifier).refreshDetection(),
          ),
        ],
      ),
      body: ListView(
        children: [
          _row(context, 'Claude', data?.detection?.claude),
          _row(context, 'Gemini', data?.detection?.gemini),
        ],
      ),
    );
  }

  Widget _row(BuildContext ctx, String title, CliStatus? s) {
    final scheme = Theme.of(ctx).colorScheme;
    final (String label, Color color) = s == null
        ? ('Bilinmiyor', scheme.onSurfaceVariant)
        : s.state == CliState.ready
            ? ('Bağlı', const Color(0xFF22C55E))
            : s.state == CliState.loggedOut
                ? ('Giriş gerekli', const Color(0xFFF59E0B))
                : ('Kurulu değil', scheme.error);
    return ListTile(
      leading: Icon(Icons.smart_toy, color: color),
      title: Text(title),
      subtitle: Text([
        label,
        if (s?.version != null) s!.version!,
      ].join(' · ')),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
