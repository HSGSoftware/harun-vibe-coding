import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight key/value cache for UI settings. Sensitive values go to
/// [SecureStorage] instead.
class PrefsStorage {
  PrefsStorage(this._prefs);
  final SharedPreferences _prefs;

  Future<void> setString(String key, String value) async => _prefs.setString(key, value);
  Future<void> setBool(String key, bool value) async => _prefs.setBool(key, value);
  Future<void> setInt(String key, int value) async => _prefs.setInt(key, value);

  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);

  Future<void> remove(String key) async => _prefs.remove(key);
}

final prefsStorageProvider = FutureProvider<PrefsStorage>((ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return PrefsStorage(prefs);
});
