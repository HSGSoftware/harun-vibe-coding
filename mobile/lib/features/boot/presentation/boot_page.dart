import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';

/// Boot / splash screen. Faz 1 wires health-check polling + Termux launch.
class BootPage extends ConsumerWidget {
  const BootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 72, color: Color(0xFF5468FF)),
            const SizedBox(height: 16),
            Text(S.appName, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(S.bootStarting, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            const SizedBox(width: 120, child: LinearProgressIndicator(minHeight: 3)),
          ],
        ),
      ),
    );
  }
}
