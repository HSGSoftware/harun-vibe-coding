import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_paths.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/projects_repository.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl(this._api);
  final ApiClient _api;

  @override
  Future<List<ProjectEntity>> list() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.projects);
      final raw = (res.data?['projects'] as List?) ?? const [];
      return raw
          .map((e) => ProjectEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ProjectEntity?> get(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.project(id));
      return res.data == null ? null : ProjectEntity.fromJson(res.data!);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ProjectEntity> create({
    required String name,
    String? env,
    int? port,
    String? entryCmd,
    String? group,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(ApiPaths.projects, body: {
        'name': name,
        if (env != null) 'env': env,
        if (port != null) 'port': port,
        if (entryCmd != null) 'entry_cmd': entryCmd,
        if (group != null) 'group': group,
        'source': 'empty',
      });
      return ProjectEntity.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ProjectEntity> update(String id, Map<String, Object?> patch) async {
    try {
      final res = await _api.patch<Map<String, dynamic>>(ApiPaths.project(id), body: patch);
      return ProjectEntity.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> delete(String id, {bool keepFiles = true}) async {
    try {
      await _api.delete<Map<String, dynamic>>(
        ApiPaths.project(id),
        query: {'keep_files': keepFiles ? '1' : '0'},
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> start(String id) async {
    try {
      await _api.post<Map<String, dynamic>>(ApiPaths.projectStart(id));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> stop(String id) async {
    try {
      await _api.post<Map<String, dynamic>>(ApiPaths.projectStop(id));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> restart(String id) async {
    try {
      await _api.post<Map<String, dynamic>>(ApiPaths.projectRestart(id));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<String> logs(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.projectLogs(id));
      return res.data?['logs'] as String? ?? '';
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Map<String, Object?>> startTunnel(String id) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(ApiPaths.tunnelStart(id));
      return Map<String, Object?>.from(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> stopTunnel(String id) async {
    try {
      await _api.post<Map<String, dynamic>>(ApiPaths.tunnelStop(id));
    } catch (e) {
      throw mapError(e);
    }
  }
}

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepositoryImpl(ref.watch(apiClientProvider));
});
