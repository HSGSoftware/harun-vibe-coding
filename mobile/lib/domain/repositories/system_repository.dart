import '../entities/system_info.dart';

abstract class SystemRepository {
  Future<bool> health();
  Future<SystemInfo> info();
  Future<SystemStats> stats();
}
