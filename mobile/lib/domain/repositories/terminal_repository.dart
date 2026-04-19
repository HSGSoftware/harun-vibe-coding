import '../entities/terminal_session.dart';

abstract class TerminalRepository {
  Future<List<TerminalSessionEntity>> list();
  Future<TerminalSessionEntity> create({String? cwd, int cols = 80, int rows = 24});
  Future<void> close(String id);
  Future<void> resize(String id, int cols, int rows);
}
