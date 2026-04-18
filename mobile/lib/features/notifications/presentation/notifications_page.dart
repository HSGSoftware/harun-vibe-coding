import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/entities/notification.dart';

final notificationListProvider =
    FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
  final res = await ref.read(apiClientProvider).get<Map<String, dynamic>>(ApiPaths.notifications);
  final raw = (res.data?['notifications'] as List?) ?? const [];
  return raw.map((e) => NotificationEntity.fromJson(Map<String, dynamic>.from(e as Map))).toList();
});

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            tooltip: 'Tümünü okundu',
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await ref.read(apiClientProvider).post<Map<String, dynamic>>(ApiPaths.notificationReadAll);
              ref.invalidate(notificationListProvider);
            },
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'Bildirim yok', icon: Icons.notifications_none)
            : ListView.separated(
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final n = items[i];
                  return ListTile(
                    leading: Icon(_iconFor(n.category), color: _colorFor(n.importance, context)),
                    title: Text(n.title,
                        style: TextStyle(fontWeight: n.read ? FontWeight.w400 : FontWeight.w600)),
                    subtitle: Text([
                      n.body,
                      if (n.createdAt != null) Formatters.relative(n.createdAt!),
                    ].where((s) => s.isNotEmpty).join(' · ')),
                    onTap: () async {
                      await ref.read(apiClientProvider).post<Map<String, dynamic>>(ApiPaths.notificationRead(n.id));
                      ref.invalidate(notificationListProvider);
                      if (n.deepLink != null && context.mounted) {
                        context.go(n.deepLink!);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'ai_response':
      case 'ai_permission':
        return Icons.smart_toy;
      case 'server_error':
        return Icons.error_outline;
      case 'tunnel':
        return Icons.public;
      case 'backup':
        return Icons.backup;
      default:
        return Icons.notifications;
    }
  }

  Color _colorFor(String imp, BuildContext ctx) {
    switch (imp) {
      case 'high':
        return Theme.of(ctx).colorScheme.error;
      case 'low':
        return Theme.of(ctx).colorScheme.onSurfaceVariant;
      default:
        return Theme.of(ctx).colorScheme.primary;
    }
  }
}
