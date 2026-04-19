import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsAdvanced)), body: const Center(child: Text('Gelişmiş — Faz 10')));
}
