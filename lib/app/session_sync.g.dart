// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-level glue that drives the offline attendance queue from the *session*,
/// not from any screen.
///
/// The queue lives in sqflite and therefore survives logout. Whenever the user
/// becomes authenticated — a fresh login, a cold-start session restore, or a
/// re-login after logging out — any events left pending are flushed, so a
/// capture made offline before logging out syncs automatically on the next
/// authenticated launch without having to open the attendance page.
///
/// While a session is active the queue controller is also kept alive, so its
/// own connectivity-regain flush stays armed everywhere in the app. Nothing is
/// touched (and the database is not opened) until there is an authenticated
/// session, keeping the login screen and cold start cheap.

@ProviderFor(sessionQueueSync)
final sessionQueueSyncProvider = SessionQueueSyncProvider._();

/// App-level glue that drives the offline attendance queue from the *session*,
/// not from any screen.
///
/// The queue lives in sqflite and therefore survives logout. Whenever the user
/// becomes authenticated — a fresh login, a cold-start session restore, or a
/// re-login after logging out — any events left pending are flushed, so a
/// capture made offline before logging out syncs automatically on the next
/// authenticated launch without having to open the attendance page.
///
/// While a session is active the queue controller is also kept alive, so its
/// own connectivity-regain flush stays armed everywhere in the app. Nothing is
/// touched (and the database is not opened) until there is an authenticated
/// session, keeping the login screen and cold start cheap.

final class SessionQueueSyncProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// App-level glue that drives the offline attendance queue from the *session*,
  /// not from any screen.
  ///
  /// The queue lives in sqflite and therefore survives logout. Whenever the user
  /// becomes authenticated — a fresh login, a cold-start session restore, or a
  /// re-login after logging out — any events left pending are flushed, so a
  /// capture made offline before logging out syncs automatically on the next
  /// authenticated launch without having to open the attendance page.
  ///
  /// While a session is active the queue controller is also kept alive, so its
  /// own connectivity-regain flush stays armed everywhere in the app. Nothing is
  /// touched (and the database is not opened) until there is an authenticated
  /// session, keeping the login screen and cold start cheap.
  SessionQueueSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionQueueSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionQueueSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return sessionQueueSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$sessionQueueSyncHash() => r'1411949faff01356152a6717463b29790312ab98';
