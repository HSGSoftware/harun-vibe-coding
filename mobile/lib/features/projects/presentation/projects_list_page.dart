import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../widgets/project_card.dart';
import 'providers/projects_provider.dart';

class ProjectsListPage extends ConsumerWidget {
  const ProjectsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.projectsTitle),
        actions: [
          IconButton(
            onPressed: () => context.go(RoutePaths.projectNew),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsControllerProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyState(title: S.homeEmpty, icon: Icons.folder_off),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final p = items[i];
                return ProjectCard(
                  project: p,
                  onTap: () => context.go(RoutePaths.projectDetail(p.id)),
                  onToggleStart: () => ref.read(projectsControllerProvider.notifier).toggleStart(p),
                  onLongPress: () async {
                    final confirmed = await showConfirmationSheet(
                      context: context,
                      title: 'Projeyi sil?',
                      body: '"${p.name}" veritabanından kaldırılacak. Dosyalar diskte kalır.',
                      destructive: true,
                      confirmLabel: S.remove,
                    );
                    if (confirmed) {
                      await ref.read(projectsControllerProvider.notifier).delete(p);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
