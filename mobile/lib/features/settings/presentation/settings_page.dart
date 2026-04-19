import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/router/route_paths.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const List<_Entry> _entries = [
    _Entry(S.settingsAppearance, Icons.palette, RoutePaths.settingsAppearance),
    _Entry(S.settingsEditor, Icons.edit_note, RoutePaths.settingsEditor),
    _Entry(S.settingsTerminal, Icons.terminal, RoutePaths.settingsTerminal),
    _Entry(S.settingsChat, Icons.chat, RoutePaths.settingsChat),
    _Entry(S.settingsBackup, Icons.backup, RoutePaths.settingsBackup),
    _Entry(S.settingsNotifications, Icons.notifications, RoutePaths.settingsNotifications),
    _Entry(S.settingsAi, Icons.smart_toy, RoutePaths.settingsAi),
    _Entry(S.settingsServer, Icons.dns, RoutePaths.settingsServer),
    _Entry(S.settingsAdvanced, Icons.tune, RoutePaths.settingsAdvanced),
    _Entry(S.settingsAbout, Icons.info_outline, RoutePaths.settingsAbout),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsTitle)),
      body: ListView.separated(
        itemCount: _entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final e = _entries[i];
          return ListTile(
            leading: Icon(e.icon),
            title: Text(e.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(e.path),
          );
        },
      ),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.icon, this.path);
  final String title;
  final IconData icon;
  final String path;
}
