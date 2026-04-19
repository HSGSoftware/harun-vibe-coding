import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories_impl/files_repository_impl.dart';
import '../../../../domain/entities/file_node.dart';

class FileContentArgs {
  const FileContentArgs({required this.projectId, required this.path});
  final String projectId;
  final String path;
  @override
  bool operator ==(Object o) => o is FileContentArgs && o.projectId == projectId && o.path == path;
  @override
  int get hashCode => Object.hash(projectId, path);
}

final fileContentProvider = FutureProvider.family<FileContent, FileContentArgs>((ref, args) async {
  return ref.read(filesRepositoryProvider).read(args.projectId, args.path);
});
