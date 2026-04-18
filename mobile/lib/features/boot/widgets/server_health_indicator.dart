import 'package:flutter/material.dart';

import '../../../core/l10n/strings_tr.dart';
import '../presentation/boot_controller.dart';

class ServerHealthIndicator extends StatelessWidget {
  const ServerHealthIndicator({super.key, required this.phase, required this.progress});
  final BootPhase phase;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (phase) {
      BootPhase.starting => (Colors.amber, S.bootStarting),
      BootPhase.connecting => (Colors.amber, S.bootConnecting),
      BootPhase.ready => (Colors.green, S.bootReady),
      BootPhase.termuxMissing => (Colors.red, S.bootTermuxMissing),
      BootPhase.failed => (Colors.red, S.serverError),
    };
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: 160,
          child: LinearProgressIndicator(value: progress == 0 ? null : progress, minHeight: 3),
        ),
      ],
    );
  }
}
