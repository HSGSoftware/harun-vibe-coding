import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class ProjectCreatePage extends StatelessWidget {
  const ProjectCreatePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.projectNew)), body: const Center(child: Text('Yeni proje — Faz 2')));
}
