import 'package:flutter/material.dart';

class BackupDetailPage extends StatelessWidget {
  const BackupDetailPage({super.key, required this.backupId});
  final String backupId;
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text('Yedek: $backupId')), body: const Center(child: Text('Yedek detay — Faz 7')));
}
