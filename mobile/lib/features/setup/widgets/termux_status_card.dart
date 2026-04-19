import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/native/termux_bridge.dart';

enum TermuxStatus { missing, needsConfig, ready }

class TermuxStatusCard extends ConsumerWidget {
  const TermuxStatusCard({super.key, required this.status, this.onRetry});
  final TermuxStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termux = ref.read(termuxBridgeProvider);
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case TermuxStatus.missing:
        return _card(
          context,
          color: scheme.error,
          icon: Icons.error_outline,
          title: S.setupTermuxMissing,
          body: 'Termux, uygulamanın çekirdeğini çalıştıran ücretsiz bir terminaldir. F-Droid\'den kurabilirsin.',
          actions: [
            OutlinedButton(onPressed: termux.openPlayStore, child: const Text('F-Droid')),
            FilledButton(onPressed: onRetry, child: const Text(S.bootCheckAgain)),
          ],
        );
      case TermuxStatus.needsConfig:
        return _card(
          context,
          color: const Color(0xFFF59E0B),
          icon: Icons.warning_amber_outlined,
          title: S.setupTermuxNotConfigured,
          body: S.setupAllowExternalHelp,
          actions: [
            OutlinedButton(onPressed: termux.openTermux, child: const Text('Termux\'u Aç')),
            FilledButton(onPressed: onRetry, child: const Text('Tüm adımları yaptım')),
          ],
        );
      case TermuxStatus.ready:
        return _card(
          context,
          color: const Color(0xFF22C55E),
          icon: Icons.check_circle_outline,
          title: S.setupTermuxReady,
          body: 'Sunucu otomatik ayağa kalkmaya hazır.',
        );
    }
  }

  Widget _card(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String body,
    List<Widget> actions = const [],
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 12),
          Text(body),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}
