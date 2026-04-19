import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/ai_keys_page.dart';
import 'pages/done_page.dart';
import 'pages/first_project_page.dart';
import 'pages/permissions_page.dart';
import 'pages/preferences_page.dart';
import 'pages/termux_check_page.dart';
import 'pages/welcome_page.dart';
import 'providers/step_provider.dart';

class SetupWizardPage extends ConsumerWidget {
  const SetupWizardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int step = ref.watch(setupStepProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(
        key: ValueKey<int>(step),
        child: switch (step) {
          0 => const WelcomePage(),
          1 => const TermuxCheckPage(),
          2 => const PermissionsPage(),
          3 => const AiKeysPage(),
          4 => const PreferencesPage(),
          5 => const FirstProjectPage(),
          6 => const DonePage(),
          _ => const WelcomePage(),
        },
      ),
    );
  }
}
