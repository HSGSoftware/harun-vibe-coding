import 'package:flutter/material.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key, required this.projectId, required this.path});
  final String projectId;
  final String path;
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text(path)), body: const Center(child: Text('Monaco editor — Faz 3')));
}
