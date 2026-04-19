import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/widgets/gradient_card.dart';
import '../../projects/presentation/providers/projects_provider.dart';
import '../../projects/widgets/status_chip.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(RoutePaths.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(RoutePaths.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(context, S.homeActiveProjects),
            projectsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e'),
              data: (items) {
                final running = items.where((p) => p.isRunning || p.isStarting).toList();
                if (running.isEmpty) {
                  return GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Şu an çalışan proje yok',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Projeler sekmesinden bir proje aç ve başlat.',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }
                return SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: running.length,
                    itemBuilder: (_, i) {
                      final p = running[i];
                      return SizedBox(
                        width: 220,
                        child: GradientCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('Port ${p.runningPort ?? p.port}',
                                  style: Theme.of(context).textTheme.bodySmall),
                              const Spacer(),
                              ProjectStatusChip(status: p.status),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _section(context, S.homeQuickActions),
            _grid(context, const [
              (S.fabNewProject, Icons.add_box, RoutePaths.projectNew),
              (S.projectClone, Icons.cloud_download, RoutePaths.projectNew),
              (S.chatNew, Icons.chat_bubble_outline, RoutePaths.chat),
              (S.navTerminal, Icons.terminal, RoutePaths.terminal),
              ('Yedekler', Icons.backup, RoutePaths.backups),
              ('Bildirimler', Icons.notifications, RoutePaths.notifications),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _grid(BuildContext context, List<(String, IconData, String)> entries) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: [
        for (final (label, icon, route) in entries)
          InkWell(
            onTap: () => context.go(route),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
