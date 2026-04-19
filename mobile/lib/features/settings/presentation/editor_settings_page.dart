import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class EditorSettingsPage extends StatelessWidget {
  const EditorSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsEditor)), body: const Center(child: Text('Editör — Faz 10')));
}
