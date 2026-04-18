import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/ws_client.dart';
import '../../../../data/repositories_impl/setup_repository_impl.dart';
import '../../../../domain/entities/cli_status.dart';

class SetupData {
  const SetupData({this.detection, this.cliLog = const [], this.authUrl});
  final CliDetection? detection;
  final List<String> cliLog;
  final String? authUrl;

  SetupData copyWith({CliDetection? detection, List<String>? cliLog, String? authUrl}) {
    return SetupData(
      detection: detection ?? this.detection,
      cliLog: cliLog ?? this.cliLog,
      authUrl: authUrl ?? this.authUrl,
    );
  }
}

class SetupController extends AsyncNotifier<SetupData> {
  @override
  Future<SetupData> build() async {
    _listenCliEvents();
    final detection = await _safeDetect();
    return SetupData(detection: detection);
  }

  Future<CliDetection?> _safeDetect() async {
    try {
      return await ref.read(setupRepositoryProvider).detectCli();
    } catch (_) {
      return null;
    }
  }

  Future<void> refreshDetection() async {
    state = const AsyncValue.loading();
    final detection = await _safeDetect();
    state = AsyncValue.data((state.valueOrNull ?? const SetupData()).copyWith(detection: detection, authUrl: null));
  }

  Future<void> installCli(String provider) async {
    await ref.read(setupRepositoryProvider).installCli(provider);
  }

  Future<void> loginCli(String provider) async {
    await ref.read(setupRepositoryProvider).loginCli(provider);
    state = AsyncValue.data((state.valueOrNull ?? const SetupData()).copyWith(cliLog: const [], authUrl: null));
  }

  Future<void> logoutCli(String provider) async {
    await ref.read(setupRepositoryProvider).logoutCli(provider);
    await refreshDetection();
  }

  Future<bool> testCli(String provider) async {
    return ref.read(setupRepositoryProvider).testCli(provider);
  }

  Future<void> complete() async {
    await ref.read(setupRepositoryProvider).complete();
  }

  void _listenCliEvents() {
    final ws = ref.read(wsClientProvider);
    ws.subscribe(['events']);
    final sub = ws.incoming.listen((env) {
      if (env.type != 'events.cli_task') return;
      final String line = env.payload['line'] as String? ?? '';
      final String? authUrl = env.payload['auth_url'] as String?;
      final completed = env.payload['completed'] as bool? ?? false;
      final existing = state.valueOrNull ?? const SetupData();
      final logs = [...existing.cliLog, if (line.isNotEmpty) line];
      state = AsyncValue.data(existing.copyWith(cliLog: logs, authUrl: authUrl ?? existing.authUrl));
      if (completed) {
        refreshDetection();
      }
    });
    ref.onDispose(sub.cancel);
  }
}

final setupControllerProvider =
    AsyncNotifierProvider<SetupController, SetupData>(SetupController.new);
