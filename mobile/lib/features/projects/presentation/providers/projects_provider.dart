import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories_impl/projects_repository_impl.dart';
import '../../../../domain/entities/project.dart';

class ProjectsController extends AsyncNotifier<List<ProjectEntity>> {
  @override
  Future<List<ProjectEntity>> build() async {
    return ref.read(projectsRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(projectsRepositoryProvider).list());
  }

  Future<void> toggleStart(ProjectEntity p) async {
    final repo = ref.read(projectsRepositoryProvider);
    if (p.isRunning || p.isStarting) {
      await repo.stop(p.id);
    } else {
      await repo.start(p.id);
    }
    await refresh();
  }

  Future<void> delete(ProjectEntity p, {bool keepFiles = true}) async {
    await ref.read(projectsRepositoryProvider).delete(p.id, keepFiles: keepFiles);
    await refresh();
  }
}

final projectsControllerProvider =
    AsyncNotifierProvider<ProjectsController, List<ProjectEntity>>(ProjectsController.new);
