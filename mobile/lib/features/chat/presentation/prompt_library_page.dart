import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/clipboard.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/entities/prompt_entry.dart';

final promptsProvider = FutureProvider.autoDispose<List<PromptEntry>>((ref) async {
  final res = await ref.read(apiClientProvider).get<Map<String, dynamic>>(ApiPaths.aiPrompts);
  final raw = (res.data?['prompts'] as List?) ?? const [];
  return raw.map((e) => PromptEntry.fromJson(Map<String, dynamic>.from(e as Map))).toList();
});

class PromptLibraryPage extends ConsumerWidget {
  const PromptLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(promptsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Promptlar')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'Henüz prompt eklemedin', icon: Icons.bookmarks_outlined)
            : ListView.separated(
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final p = items[i];
                  return ListTile(
                    title: Text(p.title),
                    subtitle: Text(p.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        ClipboardX.copy(p.content);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kopyalandı')),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
