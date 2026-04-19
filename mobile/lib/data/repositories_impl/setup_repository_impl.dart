import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_paths.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/cli_status.dart';
import '../../domain/entities/setup_state.dart';
import '../../domain/repositories/setup_repository.dart';

class SetupRepositoryImpl implements SetupRepository {
  SetupRepositoryImpl(this._api);
  final ApiClient _api;

  @override
  Future<SetupStateEntity> status() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.setupStatus);
      return SetupStateEntity.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<CliDetection> detectCli() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiPaths.setupCliDetect);
      return CliDetection.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<String> installCli(String provider) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiPaths.setupCliInstall,
        body: {'provider': provider},
      );
      return res.data?['task_id'] as String? ?? '';
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<String> loginCli(String provider) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiPaths.setupCliLogin,
        body: {'provider': provider},
      );
      return res.data?['task_id'] as String? ?? '';
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> logoutCli(String provider) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiPaths.setupCliLogout,
        body: {'provider': provider},
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<bool> testCli(String provider) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiPaths.setupCliTest,
        body: {'provider': provider},
      );
      return res.data?['ok'] as bool? ?? false;
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> savePreferences(Map<String, Object?> prefs) async {
    try {
      await _api.post<Map<String, dynamic>>(ApiPaths.setupPreferences, body: prefs);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> complete() async {
    try {
      await _api.post<Map<String, dynamic>>(ApiPaths.setupComplete);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> reset() async {
    try {
      await _api.post<Map<String, dynamic>>(ApiPaths.setupReset);
    } catch (e) {
      throw mapError(e);
    }
  }
}

final setupRepositoryProvider = Provider<SetupRepository>((ref) {
  return SetupRepositoryImpl(ref.watch(apiClientProvider));
});
