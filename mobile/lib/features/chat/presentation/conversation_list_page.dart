import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/repositories_impl/chat_repository_impl.dart';
import '../../../domain/entities/conversation.dart';

final conversationListProvider =
    FutureProvider.autoDispose<List<ConversationEntity>>((ref) async {
  return ref.read(chatRepositoryProvider).list();
});

class ConversationListPage extends ConsumerWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(conversationListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbetler')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'Sohbet yok', icon: Icons.chat_bubble_outline)
            : ListView.separated(
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final c = items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(c.provider.isNotEmpty ? c.provider[0].toUpperCase() : '?'),
                    ),
                    title: Text(c.title),
                    subtitle: Text('${c.provider} · ${c.model}'),
                    onTap: () => context.go(RoutePaths.chatSession(c.id)),
                  );
                },
              ),
      ),
    );
  }
}
