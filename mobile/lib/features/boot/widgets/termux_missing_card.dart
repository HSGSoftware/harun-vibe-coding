import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/native/termux_bridge.dart';

class TermuxMissingCard extends ConsumerWidget {
  const TermuxMissingCard({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.read(termuxBridgeProvider);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text(S.bootTermuxMissing, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Termux, sunucunun çalıştığı terminaldir. Kurulum için F-Droid\'i kullan.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(onPressed: bridge.openPlayStore, child: const Text('F-Droid\'de Aç')),
              FilledButton(onPressed: onRetry, child: const Text(S.bootCheckAgain)),
            ],
          ),
        ],
      ),
    );
  }
}
