import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs_storage.dart';

/// Ephemeral JSON cache over SharedPreferences. Not a DB — keep entries small
/// (project list snapshot, recent conversations). For large binaries use files.
class CacheStorage {
  CacheStorage(this._prefs);
  final PrefsStorage _prefs;

  Future<void> putJson(String key, Map<String, Object?> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  Map<String, Object?>? readJson(String key) {
    final String? raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, Object?>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String key) => _prefs.remove(key);
}

final cacheStorageProvider = FutureProvider<CacheStorage>((ref) async {
  final PrefsStorage prefs = await ref.watch(prefsStorageProvider.future);
  return CacheStorage(prefs);
});
