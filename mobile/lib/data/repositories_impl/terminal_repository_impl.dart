import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_paths.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/terminal_session.dart';
import '../../domain/repositories/terminal_repository.dart';

class TerminalRepositoryImpl implements TerminalRepository {
  TerminalRepositoryImpl(this._api);
  final ApiClient _api;

  @override
  Future<List<TerminalSessionEntity>> list() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.terminals);
      final list = (res.data?['terminals'] as List?) ?? const [];
      return list
          .map((e) => TerminalSessionEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<TerminalSessionEntity> create({String? cwd, int cols = 80, int rows = 24}) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiPaths.terminals,
        body: {'cwd': cwd ?? '', 'cols': cols, 'rows': rows},
      );
      return TerminalSessionEntity.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> close(String id) async {
    try {
      await _api.delete<Map<String, dynamic>>(ApiPaths.terminal(id));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> resize(String id, int cols, int rows) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiPaths.terminalResize(id),
        body: {'cols': cols, 'rows': rows},
      );
    } catch (e) {
      throw mapError(e);
    }
  }
}

final terminalRepositoryProvider = Provider<TerminalRepository>((ref) {
  return TerminalRepositoryImpl(ref.watch(apiClientProvider));
});
