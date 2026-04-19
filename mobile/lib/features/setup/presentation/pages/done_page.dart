import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/strings_tr.dart';
import '../../../../core/router/route_paths.dart';
import '../../widgets/wizard_shell.dart';
import '../providers/setup_controller.dart';
import '../providers/step_provider.dart';

class DonePage extends ConsumerWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WizardShell(
      stepIndex: 6,
      totalSteps: 7,
      title: S.setupDoneTitle,
      nextLabel: S.setupGoToApp,
      onBack: ref.read(setupStepProvider.notifier).prev,
      onNext: () async {
        await ref.read(setupControllerProvider.notifier).complete();
        if (!context.mounted) return;
        context.go(RoutePaths.home);
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 96, color: Color(0xFF5468FF)),
            const SizedBox(height: 16),
            Text(S.setupDoneSubtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
