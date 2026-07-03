import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin, typed wrapper over [FlutterSecureStorage].
///
/// Keeps the rest of the app decoupled from the plugin and gives us one place
/// to configure platform options. See the architecture doc §11.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  /// Wipes all secure values (used on logout).
  Future<void> clear() => _storage.deleteAll();
}
