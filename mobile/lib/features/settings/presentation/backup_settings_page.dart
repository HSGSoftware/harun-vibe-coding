import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class BackupSettingsPage extends StatelessWidget {
  const BackupSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsBackup)), body: const Center(child: Text('Yedekleme — Faz 10')));
}
