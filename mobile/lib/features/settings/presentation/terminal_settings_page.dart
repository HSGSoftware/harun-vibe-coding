import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class TerminalSettingsPage extends StatelessWidget {
  const TerminalSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsTerminal)), body: const Center(child: Text('Terminal — Faz 10')));
}
