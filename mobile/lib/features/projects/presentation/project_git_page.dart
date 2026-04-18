import 'package:flutter/material.dart';

class ProjectGitPage extends StatelessWidget {
  const ProjectGitPage({super.key, required this.projectId});
  final String projectId;
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text('Git: $projectId')), body: const Center(child: Text('Git paneli — Faz 7')));
}
