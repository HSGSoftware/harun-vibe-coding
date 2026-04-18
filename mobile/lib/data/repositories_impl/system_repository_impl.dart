import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_paths.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/system_info.dart';
import '../../domain/repositories/system_repository.dart';

class SystemRepositoryImpl implements SystemRepository {
  SystemRepositoryImpl(this._api);
  final ApiClient _api;

  @override
  Future<bool> health() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.health);
      return res.data?['ok'] as bool? ?? false;
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<SystemInfo> info() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.systemInfo);
      return SystemInfo.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<SystemStats> stats() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.systemStats);
      return SystemStats.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }
}

final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepositoryImpl(ref.watch(apiClientProvider));
});
