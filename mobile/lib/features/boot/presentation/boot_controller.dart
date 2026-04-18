import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/native/server_launcher.dart';
import '../../../core/native/termux_bridge.dart';
import '../../../core/network/ws_client.dart';
import '../../../data/repositories_impl/setup_repository_impl.dart';
import '../../../data/repositories_impl/system_repository_impl.dart';

enum BootPhase { starting, connecting, ready, termuxMissing, failed }

class BootState {
  const BootState({this.phase = BootPhase.starting, this.progress = 0, this.error});
  final BootPhase phase;
  final double progress; // 0..1
  final String? error;

  BootState copyWith({BootPhase? phase, double? progress, String? error}) =>
      BootState(phase: phase ?? this.phase, progress: progress ?? this.progress, error: error);
}

class BootController extends AsyncNotifier<BootState> {
  Timer? _poll;
  int _attempts = 0;
  static const int _maxAttempts = 60; // 60 x 500ms = 30s

  @override
  Future<BootState> build() async {
    ref.onDispose(() => _poll?.cancel());
    return const BootState();
  }

  Future<BootState> run() async {
    state = const AsyncValue.data(BootState(phase: BootPhase.starting));
    // 1) Quick probe — server already alive?
    if (await _probeHealth()) {
      return _transitionToReady();
    }
    // 2) Termux check + launch
    final TermuxBridge termux = ref.read(termuxBridgeProvider);
    if (!await termux.isInstalled()) {
      final next = const BootState(phase: BootPhase.termuxMissing);
      state = AsyncValue.data(next);
      return next;
    }
    await ref.read(serverLauncherProvider).start();
    // 3) Poll every 500ms up to 30s
    _attempts = 0;
    final Completer<BootState> completer = Completer<BootState>();
    _poll = Timer.periodic(const Duration(milliseconds: 500), (t) async {
      _attempts++;
      state = AsyncValue.data(BootState(
        phase: BootPhase.connecting,
        progress: _attempts / _maxAttempts,
      ));
      if (await _probeHealth()) {
        t.cancel();
        completer.complete(_transitionToReady());
      } else if (_attempts >= _maxAttempts) {
        t.cancel();
        final next = const BootState(phase: BootPhase.failed, error: 'timeout');
        state = AsyncValue.data(next);
        completer.complete(next);
      }
    });
    return completer.future;
  }

  Future<bool> _probeHealth() async {
    try {
      return await ref.read(systemRepositoryProvider).health();
    } catch (_) {
      return false;
    }
  }

  BootState _transitionToReady() {
    final ws = ref.read(wsClientProvider);
    unawaited(ws.connect());
    const next = BootState(phase: BootPhase.ready, progress: 1);
    state = const AsyncValue.data(next);
    return next;
  }

  Future<bool> setupCompleted() async {
    try {
      final st = await ref.read(setupRepositoryProvider).status();
      return st.completed;
    } catch (_) {
      return false;
    }
  }
}

final bootControllerProvider =
    AsyncNotifierProvider<BootController, BootState>(BootController.new);
