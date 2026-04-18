import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories_impl/files_repository_impl.dart';
import '../../../../domain/entities/file_node.dart';

final fileTreeProvider = FutureProvider.family<FileNode, String>((ref, projectId) async {
  return ref.read(filesRepositoryProvider).tree(projectId, depth: 4);
});
