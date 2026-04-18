import 'package:flutter/material.dart';

class ProjectLogsPage extends StatelessWidget {
  const ProjectLogsPage({super.key, required this.projectId});
  final String projectId;
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text('Log: $projectId')), body: const Center(child: Text('Loglar — Faz 2')));
}
