import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories_impl/projects_repository_impl.dart';
import '../../../../domain/entities/project.dart';

final projectDetailProvider =
    FutureProvider.family<ProjectEntity?, String>((ref, id) async {
  return ref.read(projectsRepositoryProvider).get(id);
});
