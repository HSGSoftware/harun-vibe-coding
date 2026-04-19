import 'package:flutter/material.dart';

import '../../../core/l10n/strings_tr.dart';

class RetryPanel extends StatelessWidget {
  const RetryPanel({super.key, required this.onRetry, required this.onOpenTermux});
  final VoidCallback onRetry;
  final VoidCallback onOpenTermux;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(S.serverError, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(onPressed: onOpenTermux, icon: const Icon(Icons.terminal), label: const Text(S.bootOpenTermux)),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text(S.retry)),
          ],
        ),
      ],
    );
  }
}
