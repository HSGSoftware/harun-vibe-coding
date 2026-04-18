import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class AiSettingsPage extends StatelessWidget {
  const AiSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsAi)), body: const Center(child: Text('AI CLI ayarları — Faz 10')));
}
