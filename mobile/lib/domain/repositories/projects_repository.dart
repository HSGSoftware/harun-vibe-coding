import '../entities/project.dart';

abstract class ProjectsRepository {
  Future<List<ProjectEntity>> list();
  Future<ProjectEntity?> get(String id);
  Future<ProjectEntity> create({required String name, String? env, int? port, String? entryCmd, String? group});
  Future<ProjectEntity> update(String id, Map<String, Object?> patch);
  Future<void> delete(String id, {bool keepFiles = true});
  Future<void> start(String id);
  Future<void> stop(String id);
  Future<void> restart(String id);
  Future<String> logs(String id);
  Future<Map<String, Object?>> startTunnel(String id);
  Future<void> stopTunnel(String id);
}
