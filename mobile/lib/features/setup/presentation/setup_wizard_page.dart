import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';

/// Placeholder — Faz 1 replaces this with the 7-step wizard.
class SetupWizardPage extends ConsumerWidget {
  const SetupWizardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.setupWelcomeTitle)),
      body: const Center(child: Text('Kurulum sihirbazı — Faz 1\'de açılacak')),
    );
  }
}
