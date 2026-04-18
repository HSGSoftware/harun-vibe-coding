import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.settingsNotifications)), body: const Center(child: Text('Bildirimler — Faz 10')));
}
