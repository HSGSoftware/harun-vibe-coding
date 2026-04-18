import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories_impl/files_repository_impl.dart';
import '../widgets/monaco_editor.dart';
import 'providers/file_content_provider.dart';

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key, required this.projectId, required this.path});
  final String projectId;
  final String path;

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  String? _currentContent;
  bool _dirty = false;
  bool _saving = false;

  Future<void> _save() async {
    final content = _currentContent;
    if (content == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(filesRepositoryProvider).write(widget.projectId, widget.path, content);
      setState(() => _dirty = false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(fileContentProvider(FileContentArgs(projectId: widget.projectId, path: widget.path)));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path, style: Theme.of(context).textTheme.titleMedium),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(onPressed: _dirty ? _save : null, icon: const Icon(Icons.save_rounded)),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (file) => MonacoEditor(
          initialContent: file.content,
          language: file.language,
          onChanged: (v) {
            _currentContent = v;
            if (!_dirty) setState(() => _dirty = true);
          },
          onSave: _save,
        ),
      ),
    );
  }
}
