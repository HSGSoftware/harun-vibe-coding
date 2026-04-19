import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/strings_tr.dart';
import '../../../../core/theme/dynamic_theme.dart';
import '../../widgets/wizard_shell.dart';
import '../providers/step_provider.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    return WizardShell(
      stepIndex: 4,
      totalSteps: 7,
      title: S.setupPrefsTitle,
      onBack: ref.read(setupStepProvider.notifier).prev,
      onNext: ref.read(setupStepProvider.notifier).next,
      child: ListView(
        children: [
          Text('Tema', style: Theme.of(context).textTheme.titleMedium),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.dark,
            groupValue: theme.mode,
            onChanged: (v) => ref.read(themeControllerProvider.notifier).setMode(v!),
            title: const Text('Dark'),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.amoled,
            groupValue: theme.mode,
            onChanged: (v) => ref.read(themeControllerProvider.notifier).setMode(v!),
            title: const Text('AMOLED Siyah'),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.system,
            groupValue: theme.mode,
            onChanged: (v) => ref.read(themeControllerProvider.notifier).setMode(v!),
            title: const Text('Sistem'),
          ),
          const Divider(),
          const SwitchListTile(value: true, onChanged: null, title: Text('Otomatik yedekleme')),
          const SwitchListTile(value: true, onChanged: null, title: Text('Bildirim sesi')),
          const SwitchListTile(value: true, onChanged: null, title: Text('Titreşim')),
        ],
      ),
    );
  }
}
