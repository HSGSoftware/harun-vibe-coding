import 'package:flutter/material.dart';
import '../../../core/l10n/strings_tr.dart';

class ProjectsListPage extends StatelessWidget {
  const ProjectsListPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text(S.projectsTitle)), body: const Center(child: Text('Projeler — Faz 2')));
}
