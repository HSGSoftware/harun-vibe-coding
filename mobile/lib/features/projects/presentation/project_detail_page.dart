import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/utils/clipboard.dart';
import '../../../data/repositories_impl/projects_repository_impl.dart';
import '../widgets/env_badge.dart';
import '../widgets/status_chip.dart';
import 'providers/project_detail_provider.dart';
import 'providers/projects_provider.dart';

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectDetailProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(async.valueOrNull?.name ?? 'Proje'),
        actions: [
          IconButton(
            tooltip: 'Loglar',
            icon: const Icon(Icons.subject),
            onPressed: () => context.go(RoutePaths.projectLogs(projectId)),
          ),
          IconButton(
            tooltip: 'Git',
            icon: const Icon(Icons.merge_type),
            onPressed: () => context.go(RoutePaths.projectGit(projectId)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (p) {
          if (p == null) return const Center(child: Text(S.errNotFound));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(children: [EnvBadge(env: p.env), const Spacer(), ProjectStatusChip(status: p.status)]),
              const SizedBox(height: 16),
              SelectableText(p.path, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text('Entry: ${p.entryCmd.isEmpty ? '—' : p.entryCmd}'),
              Text('Port: ${p.runningPort ?? p.port}'),
              if (p.tunnelUrl != null) ...[
                const SizedBox(height: 12),
                _TunnelRow(url: p.tunnelUrl!),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton.icon(
                    icon: Icon(p.isRunning ? Icons.stop : Icons.play_arrow),
                    onPressed: () => ref.read(projectsControllerProvider.notifier).toggleStart(p),
                    label: Text(p.isRunning ? S.stop : S.start),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await ref.read(projectsRepositoryProvider).restart(p.id);
                      ref.invalidate(projectDetailProvider(p.id));
                    },
                    label: const Text(S.restart),
                  ),
                  if (p.tunnelUrl == null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.public),
                      onPressed: () async {
                        await ref.read(projectsRepositoryProvider).startTunnel(p.id);
                        ref.invalidate(projectDetailProvider(p.id));
                      },
                      label: const Text('Tunnel Aç'),
                    )
                  else
                    OutlinedButton.icon(
                      icon: const Icon(Icons.public_off),
                      onPressed: () async {
                        await ref.read(projectsRepositoryProvider).stopTunnel(p.id);
                        ref.invalidate(projectDetailProvider(p.id));
                      },
                      label: const Text('Tunnel Kapat'),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TunnelRow extends StatelessWidget {
  const _TunnelRow({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, color: Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          Expanded(child: SelectableText(url, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12))),
          IconButton(onPressed: () => ClipboardX.copy(url), icon: const Icon(Icons.copy, size: 18)),
        ],
      ),
    );
  }
}
