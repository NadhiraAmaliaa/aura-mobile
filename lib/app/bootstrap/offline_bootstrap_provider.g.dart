// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_bootstrap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Prepares the minimum offline dataset a freshly-authenticated user needs to
/// open the Attendance flow without connectivity:
///
/// - the attendance dashboard (today's state + monthly recap), keyed to the
///   authenticated user;
/// - the office geofence configuration (shared across users).
///
/// The profile/user record is already persisted by [AuthRepository.login] and
/// `me()` (see `cachedUser`), so it is not re-fetched here.
///
/// Readiness is defined as "the minimum dataset is stored for the authenticated
/// user". When it is already cached — e.g. an offline cold start after a prior
/// session — the bootstrap resolves immediately without touching the network.
/// Otherwise it fetches and persists whatever is missing, which requires
/// connectivity; a fresh login while offline therefore surfaces an error that
/// the login/bootstrap stage can present as a retry, instead of silently
/// failing later inside the Attendance flow.
///
/// The bootstrap is strictly scoped to [currentUserIdProvider]: it never reads
/// or writes another user's cache, and it re-runs when the active user changes.

@ProviderFor(OfflineBootstrap)
final offlineBootstrapProvider = OfflineBootstrapProvider._();

/// Prepares the minimum offline dataset a freshly-authenticated user needs to
/// open the Attendance flow without connectivity:
///
/// - the attendance dashboard (today's state + monthly recap), keyed to the
///   authenticated user;
/// - the office geofence configuration (shared across users).
///
/// The profile/user record is already persisted by [AuthRepository.login] and
/// `me()` (see `cachedUser`), so it is not re-fetched here.
///
/// Readiness is defined as "the minimum dataset is stored for the authenticated
/// user". When it is already cached — e.g. an offline cold start after a prior
/// session — the bootstrap resolves immediately without touching the network.
/// Otherwise it fetches and persists whatever is missing, which requires
/// connectivity; a fresh login while offline therefore surfaces an error that
/// the login/bootstrap stage can present as a retry, instead of silently
/// failing later inside the Attendance flow.
///
/// The bootstrap is strictly scoped to [currentUserIdProvider]: it never reads
/// or writes another user's cache, and it re-runs when the active user changes.
final class OfflineBootstrapProvider
    extends $AsyncNotifierProvider<OfflineBootstrap, void> {
  /// Prepares the minimum offline dataset a freshly-authenticated user needs to
  /// open the Attendance flow without connectivity:
  ///
  /// - the attendance dashboard (today's state + monthly recap), keyed to the
  ///   authenticated user;
  /// - the office geofence configuration (shared across users).
  ///
  /// The profile/user record is already persisted by [AuthRepository.login] and
  /// `me()` (see `cachedUser`), so it is not re-fetched here.
  ///
  /// Readiness is defined as "the minimum dataset is stored for the authenticated
  /// user". When it is already cached — e.g. an offline cold start after a prior
  /// session — the bootstrap resolves immediately without touching the network.
  /// Otherwise it fetches and persists whatever is missing, which requires
  /// connectivity; a fresh login while offline therefore surfaces an error that
  /// the login/bootstrap stage can present as a retry, instead of silently
  /// failing later inside the Attendance flow.
  ///
  /// The bootstrap is strictly scoped to [currentUserIdProvider]: it never reads
  /// or writes another user's cache, and it re-runs when the active user changes.
  OfflineBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineBootstrapHash();

  @$internal
  @override
  OfflineBootstrap create() => OfflineBootstrap();
}

String _$offlineBootstrapHash() => r'3b1e3d20f84d6a3b7d7df925c57f83aa54b32ec8';

/// Prepares the minimum offline dataset a freshly-authenticated user needs to
/// open the Attendance flow without connectivity:
///
/// - the attendance dashboard (today's state + monthly recap), keyed to the
///   authenticated user;
/// - the office geofence configuration (shared across users).
///
/// The profile/user record is already persisted by [AuthRepository.login] and
/// `me()` (see `cachedUser`), so it is not re-fetched here.
///
/// Readiness is defined as "the minimum dataset is stored for the authenticated
/// user". When it is already cached — e.g. an offline cold start after a prior
/// session — the bootstrap resolves immediately without touching the network.
/// Otherwise it fetches and persists whatever is missing, which requires
/// connectivity; a fresh login while offline therefore surfaces an error that
/// the login/bootstrap stage can present as a retry, instead of silently
/// failing later inside the Attendance flow.
///
/// The bootstrap is strictly scoped to [currentUserIdProvider]: it never reads
/// or writes another user's cache, and it re-runs when the active user changes.

abstract class _$OfflineBootstrap extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
