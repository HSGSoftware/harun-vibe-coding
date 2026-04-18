import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/strings_tr.dart';
import '../../widgets/wizard_shell.dart';
import '../providers/step_provider.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WizardShell(
      stepIndex: 0,
      totalSteps: 7,
      title: S.setupWelcomeTitle,
      nextLabel: S.setupStart,
      onBack: null,
      onNext: () => ref.read(setupStepProvider.notifier).next(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt, size: 96, color: Color(0xFF5468FF)),
          const SizedBox(height: 20),
          Text(S.setupWelcomeBody, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text(S.skip)),
        ],
      ),
    );
  }
}
