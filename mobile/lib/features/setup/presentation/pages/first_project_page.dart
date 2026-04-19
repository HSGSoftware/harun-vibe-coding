import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/strings_tr.dart';
import '../../widgets/wizard_shell.dart';
import '../providers/step_provider.dart';

class FirstProjectPage extends ConsumerWidget {
  const FirstProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WizardShell(
      stepIndex: 5,
      totalSteps: 7,
      title: S.setupFirstProjectTitle,
      onBack: ref.read(setupStepProvider.notifier).prev,
      onNext: ref.read(setupStepProvider.notifier).next,
      child: Column(
        children: [
          _option(context, icon: Icons.folder_open, title: S.setupFirstProjectEmpty, onTap: () {}),
          const SizedBox(height: 12),
          _option(context, icon: Icons.cloud_download, title: S.setupFirstProjectClone, onTap: () {}),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: ref.read(setupStepProvider.notifier).next,
            child: const Text(S.skip),
          ),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 14),
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
