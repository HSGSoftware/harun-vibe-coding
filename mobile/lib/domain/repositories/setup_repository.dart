import '../entities/cli_status.dart';
import '../entities/setup_state.dart';

abstract class SetupRepository {
  Future<SetupStateEntity> status();
  Future<CliDetection> detectCli();
  Future<String> installCli(String provider); // returns task_id
  Future<String> loginCli(String provider);   // returns task_id
  Future<void> logoutCli(String provider);
  Future<bool> testCli(String provider);
  Future<void> savePreferences(Map<String, Object?> prefs);
  Future<void> complete();
  Future<void> reset();
}
