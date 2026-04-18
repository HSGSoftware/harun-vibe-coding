import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'termux_bridge.dart';

/// Kicks off the Termux-hosted Go binary by sending a RUN_COMMAND intent
/// to Termux's RunCommandService. See plan.md §8.3.
class ServerLauncher {
  ServerLauncher(this._termux);
  final TermuxBridge _termux;

  static const String defaultScriptPath =
      '/data/data/com.termux/files/home/.harun-vibe/start.sh';
  static const String defaultWorkdir =
      '/data/data/com.termux/files/home/.harun-vibe';

  Future<bool> start({
    String scriptPath = defaultScriptPath,
    String workdir = defaultWorkdir,
  }) async {
    final Map<String, Object?> result = await _termux.runScript(
      scriptPath: scriptPath,
      workdir: workdir,
      background: true,
    );
    return (result['dispatched'] as bool?) ?? false;
  }
}

final serverLauncherProvider = Provider<ServerLauncher>((ref) {
  return ServerLauncher(ref.watch(termuxBridgeProvider));
});
