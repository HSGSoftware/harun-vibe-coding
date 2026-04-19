import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/dynamic_theme.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  static const List<Color> _accentSwatch = [
    AppColors.accent,
    AppColors.purple,
    AppColors.cyan,
    AppColors.success,
    AppColors.warning,
    AppColors.magenta,
    AppColors.danger,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsAppearance)),
      body: ListView(
        children: [
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Vurgu rengi', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in _accentSwatch)
                  InkResponse(
                    onTap: () => ref.read(themeControllerProvider.notifier).setAccent(c),
                    radius: 28,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.accent.value == c.value
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
