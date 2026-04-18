import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings_tr.dart';
import '../../network/ws_client.dart';

/// Bottom strip of the FAB menu: server status, running project count, pending
/// notifications. Feature providers can feed counts via dedicated providers.
final activeProjectsCountProvider = StateProvider<int>((_) => 0);
final pendingNotificationsProvider = StateProvider<int>((_) => 0);

class FabStatusFooter extends ConsumerWidget {
  const FabStatusFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WsClient ws = ref.watch(wsClientProvider);
    return StreamBuilder<WsStatus>(
      stream: ws.status,
      initialData: WsStatus.idle,
      builder: (_, snap) {
        final WsStatus status = snap.data ?? WsStatus.idle;
        final Color dot = switch (status) {
          WsStatus.connected => const Color(0xFF22C55E),
          WsStatus.connecting => const Color(0xFFF59E0B),
          WsStatus.idle || WsStatus.disconnected || WsStatus.error => const Color(0xFFEF4444),
        };
        final String label = switch (status) {
          WsStatus.connected => S.serverRunning,
          WsStatus.connecting => S.connecting,
          _ => S.serverError,
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              _badge(context, ref.watch(activeProjectsCountProvider), icon: Icons.play_arrow),
              const SizedBox(width: 8),
              _badge(context, ref.watch(pendingNotificationsProvider), icon: Icons.notifications),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(BuildContext ctx, int count, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text('$count', style: Theme.of(ctx).textTheme.labelSmall),
      ],
    );
  }
}
