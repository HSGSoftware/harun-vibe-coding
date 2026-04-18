import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_paths.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/file_node.dart';
import '../../domain/repositories/files_repository.dart';

class FilesRepositoryImpl implements FilesRepository {
  FilesRepositoryImpl(this._api);
  final ApiClient _api;

  @override
  Future<FileNode> tree(String projectId, {String path = '/', int depth = 3}) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        ApiPaths.files(projectId),
        query: {'path': path, 'depth': '$depth'},
      );
      final raw = Map<String, dynamic>.from(res.data?['tree'] as Map? ?? const {});
      return FileNode.fromJson(raw);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<FileContent> read(String projectId, String path) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        ApiPaths.file(projectId),
        query: {'path': path},
      );
      return FileContent.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> write(String projectId, String path, String content, {bool createDirs = false}) async {
    try {
      await _api.put<Map<String, dynamic>>(
        ApiPaths.file(projectId),
        body: {'path': path, 'content': content, 'create_dirs': createDirs},
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> create(String projectId, String path, {bool isDir = false}) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiPaths.fileNew(projectId),
        body: {'path': path, 'is_dir': isDir},
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> delete(String projectId, String path) async {
    try {
      await _api.delete<Map<String, dynamic>>(
        ApiPaths.file(projectId),
        body: {'path': path},
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> rename(String projectId, String oldPath, String newPath) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiPaths.fileRename(projectId),
        body: {'old_path': oldPath, 'new_path': newPath},
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Map<String, Object?>>> search(
    String projectId,
    String query, {
    bool caseSensitive = false,
    bool regex = false,
    String? glob,
  }) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        ApiPaths.search(projectId),
        query: {
          'q': query,
          'case': caseSensitive ? '1' : '0',
          'regex': regex ? '1' : '0',
          if (glob != null) 'glob': glob,
        },
      );
      final list = (res.data?['results'] as List?) ?? const [];
      return list.map((e) => Map<String, Object?>.from(e as Map)).toList();
    } catch (e) {
      throw mapError(e);
    }
  }
}

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepositoryImpl(ref.watch(apiClientProvider));
});
