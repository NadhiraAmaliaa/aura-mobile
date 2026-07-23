/// Keys used for values persisted in secure storage.
///
/// Centralized so there are no stringly-typed duplicates across the app.
abstract final class StorageKeys {
  /// Sanctum personal-access token (bearer).
  static const String accessToken = 'access_token';

  /// Last authenticated user profile (JSON), used to restore the session
  /// offline after at least one successful online login.
  static const String cachedUser = 'cached_user';

  /// The FCM registration token most recently confirmed-registered with the
  /// backend. Used to skip re-sending an unchanged token; cleared on logout.
  static const String registeredFcmToken = 'registered_fcm_token';
}
