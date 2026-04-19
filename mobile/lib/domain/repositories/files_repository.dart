import '../entities/file_node.dart';

abstract class FilesRepository {
  Future<FileNode> tree(String projectId, {String path = '/', int depth = 3});
  Future<FileContent> read(String projectId, String path);
  Future<void> write(String projectId, String path, String content, {bool createDirs = false});
  Future<void> create(String projectId, String path, {bool isDir = false});
  Future<void> delete(String projectId, String path);
  Future<void> rename(String projectId, String oldPath, String newPath);
  Future<List<Map<String, Object?>>> search(String projectId, String query, {bool caseSensitive = false, bool regex = false, String? glob});
}
