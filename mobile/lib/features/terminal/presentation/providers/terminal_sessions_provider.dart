import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories_impl/terminal_repository_impl.dart';
import '../../../../domain/entities/terminal_session.dart';

class TerminalSessionsController extends AsyncNotifier<List<TerminalSessionEntity>> {
  @override
  Future<List<TerminalSessionEntity>> build() async {
    return ref.read(terminalRepositoryProvider).list();
  }

  Future<TerminalSessionEntity> newTab({String? cwd}) async {
    final repo = ref.read(terminalRepositoryProvider);
    final s = await repo.create(cwd: cwd);
    final current = state.valueOrNull ?? const <TerminalSessionEntity>[];
    state = AsyncValue.data([...current, s]);
    return s;
  }

  Future<void> close(String id) async {
    await ref.read(terminalRepositoryProvider).close(id);
    final current = state.valueOrNull ?? const <TerminalSessionEntity>[];
    state = AsyncValue.data(current.where((t) => t.id != id).toList());
  }
}

final terminalSessionsProvider =
    AsyncNotifierProvider<TerminalSessionsController, List<TerminalSessionEntity>>(TerminalSessionsController.new);

final activeTerminalIdProvider = StateProvider<String?>((_) => null);
