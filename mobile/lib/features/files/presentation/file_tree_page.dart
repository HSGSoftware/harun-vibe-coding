import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class FileTreePage extends StatelessWidget {
  const FileTreePage({super.key, this.projectId});
  final String? projectId;
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.filesTitle)), body: const Center(child: Text('Dosya ağacı — Faz 3')));
}
