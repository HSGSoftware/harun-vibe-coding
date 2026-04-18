import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsAppearance)), body: const Center(child: Text('Görünüm — Faz 10')));
}
