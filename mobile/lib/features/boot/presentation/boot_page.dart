import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/native/termux_bridge.dart';
import '../../../core/router/route_paths.dart';
import '../widgets/retry_panel.dart';
import '../widgets/server_health_indicator.dart';
import '../widgets/termux_missing_card.dart';
import 'boot_controller.dart';

class BootPage extends HookConsumerWidget {
  const BootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future<void>.microtask(() async {
        final BootController ctrl = ref.read(bootControllerProvider.notifier);
        final BootState result = await ctrl.run();
        if (!context.mounted) return;
        if (result.phase == BootPhase.ready) {
          final bool done = await ctrl.setupCompleted();
          if (!context.mounted) return;
          context.go(done ? RoutePaths.home : RoutePaths.setup);
        }
      });
      return null;
    }, const []);

    final AsyncValue<BootState> async = ref.watch(bootControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: async.when(
          loading: () => const SizedBox.shrink(),
          error: (err, _) => Center(child: Text('$err')),
          data: (BootState st) => _body(context, ref, st),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, BootState st) {
    switch (st.phase) {
      case BootPhase.termuxMissing:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logo(context),
            TermuxMissingCard(onRetry: () => ref.read(bootControllerProvider.notifier).run()),
          ],
        );
      case BootPhase.failed:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logo(context),
            const SizedBox(height: 24),
            RetryPanel(
              onRetry: () => ref.read(bootControllerProvider.notifier).run(),
              onOpenTermux: () => ref.read(termuxBridgeProvider).openTermux(),
            ),
          ],
        );
      case BootPhase.ready:
      case BootPhase.starting:
      case BootPhase.connecting:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _logo(context),
              const SizedBox(height: 24),
              ServerHealthIndicator(phase: st.phase, progress: st.progress),
            ],
          ),
        );
    }
  }

  Widget _logo(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.bolt, size: 72, color: Color(0xFF5468FF)),
        const SizedBox(height: 16),
        Text(S.appName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('v0.1.0', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
