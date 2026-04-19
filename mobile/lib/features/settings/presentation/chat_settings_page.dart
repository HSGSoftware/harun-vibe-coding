import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class ChatSettingsPage extends StatelessWidget {
  const ChatSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsChat)), body: const Center(child: Text('Sohbet — Faz 10')));
}
