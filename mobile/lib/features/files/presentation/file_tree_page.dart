import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/widgets/empty_state.dart';
import '../../projects/presentation/providers/projects_provider.dart';
import '../widgets/file_tree_node.dart';
import 'providers/file_tree_provider.dart';

class FileTreePage extends ConsumerWidget {
  const FileTreePage({super.key, this.projectId});
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pid = projectId;
    if (pid == null) {
      final projectsAsync = ref.watch(projectsControllerProvider);
      return Scaffold(
        appBar: AppBar(title: const Text(S.filesTitle)),
        body: projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) => items.isEmpty
              ? const EmptyState(title: S.homeEmpty, icon: Icons.folder_off)
              : ListView(
                  children: [
                    for (final p in items)
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(p.name),
                        subtitle: Text(p.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () => context.go(RoutePaths.filesFor(p.id)),
                      ),
                  ],
                ),
        ),
      );
    }

    final treeAsync = ref.watch(fileTreeProvider(pid));
    return Scaffold(
      appBar: AppBar(title: const Text(S.filesTitle)),
      body: treeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (root) => ListView(
          children: [
            for (final child in root.children)
              FileTreeNode(
                node: child,
                onTapFile: (node) {
                  context.push('${RoutePaths.filesFor(pid)}/edit?path=${Uri.encodeQueryComponent(node.path)}');
                },
              ),
          ],
        ),
      ),
    );
  }
}
