import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class ServerSettingsPage extends StatelessWidget {
  const ServerSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsServer)), body: const Center(child: Text('Sunucu — Faz 10')));
}
