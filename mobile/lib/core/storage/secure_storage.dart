import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for the local server auth token, last session id, etc.
/// Do not store AI API keys here — plan.md §0 forbids AI keys in the app at all.
class SecureStorage {
  SecureStorage(this._fs);
  final FlutterSecureStorage _fs;

  Future<void> set(String key, String value) => _fs.write(key: key, value: value);
  Future<String?> get(String key) => _fs.read(key: key);
  Future<void> remove(String key) => _fs.delete(key: key);
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));
});
