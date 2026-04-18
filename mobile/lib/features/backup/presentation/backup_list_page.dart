import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/entities/backup.dart';

final backupListProvider = FutureProvider.autoDispose<List<BackupEntity>>((ref) async {
  final res = await ref.read(apiClientProvider).get<Map<String, dynamic>>(ApiPaths.backups);
  final raw = (res.data?['backups'] as List?) ?? const [];
  return raw.map((e) => BackupEntity.fromJson(Map<String, dynamic>.from(e as Map))).toList();
});

class BackupListPage extends ConsumerWidget {
  const BackupListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(backupListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Yedekler')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'Henüz yedek alınmadı', icon: Icons.backup_outlined)
            : ListView.separated(
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final b = items[i];
                  return ListTile(
                    leading: Icon(b.type == 'git_checkpoint' ? Icons.history : Icons.folder_zip),
                    title: Text(b.note?.isNotEmpty == true ? b.note! : b.type),
                    subtitle: Text([
                      if (b.createdAt != null) Formatters.relative(b.createdAt!),
                      if (b.sizeBytes > 0) Formatters.bytes(b.sizeBytes),
                      if (b.commitHash != null) b.commitHash!.substring(0, 7),
                    ].join(' · ')),
                  );
                },
              ),
      ),
    );
  }
}
