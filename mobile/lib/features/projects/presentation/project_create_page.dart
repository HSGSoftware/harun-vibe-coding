import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/strings_tr.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories_impl/projects_repository_impl.dart';
import 'providers/projects_provider.dart';

class ProjectCreatePage extends ConsumerStatefulWidget {
  const ProjectCreatePage({super.key});

  @override
  ConsumerState<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends ConsumerState<ProjectCreatePage> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '3000');
  final _entryCtrl = TextEditingController();
  String _env = 'nodejs';
  bool _busy = false;

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(projectsRepositoryProvider);
      await repo.create(
        name: _nameCtrl.text.trim(),
        env: _env,
        port: int.tryParse(_portCtrl.text) ?? 3000,
        entryCmd: _entryCtrl.text.trim().isEmpty ? null : _entryCtrl.text.trim(),
      );
      await ref.read(projectsControllerProvider.notifier).refresh();
      if (!mounted) return;
      context.go(RoutePaths.projects);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.projectNew)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Proje adı'),
              validator: Validators.projectName,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _env,
              items: const [
                DropdownMenuItem(value: 'nodejs', child: Text('Node.js')),
                DropdownMenuItem(value: 'flutter', child: Text('Flutter')),
                DropdownMenuItem(value: 'python', child: Text('Python')),
                DropdownMenuItem(value: 'go', child: Text('Go')),
                DropdownMenuItem(value: 'vite', child: Text('Vite')),
                DropdownMenuItem(value: 'nextjs', child: Text('Next.js')),
                DropdownMenuItem(value: 'generic', child: Text('Diğer')),
              ],
              onChanged: (v) => setState(() => _env = v ?? 'nodejs'),
              decoration: const InputDecoration(labelText: 'Ortam'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _portCtrl,
              decoration: const InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
              validator: Validators.port,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _entryCtrl,
              decoration: const InputDecoration(
                labelText: 'Başlangıç komutu (opsiyonel)',
                hintText: 'npm run dev',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
