/// Keys used for values persisted in secure storage.
///
/// Centralized so there are no stringly-typed duplicates across the app.
abstract final class StorageKeys {
  /// Sanctum personal-access token (bearer).
  static const String accessToken = 'access_token';
}
