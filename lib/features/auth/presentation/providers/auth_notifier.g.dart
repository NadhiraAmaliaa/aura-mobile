// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global session ViewModel.
///
/// `build()` resolves the session on cold start (reads the stored token and
/// validates it via `/auth/me`). The surrounding [AsyncValue] models the
/// resolving phase, so the router can show a splash while `loading`. Login and
/// logout flip the resolved [AuthState].
///
/// Offline resilience: a transient validation failure (no network, timeout,
/// unreachable server, 5xx) must NOT drop a previously authenticated user. The
/// session is restored from the on-device user cache in that case; only an
/// explicit `401` (invalid/expired token) clears the session and requires a new
/// login.

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// Global session ViewModel.
///
/// `build()` resolves the session on cold start (reads the stored token and
/// validates it via `/auth/me`). The surrounding [AsyncValue] models the
/// resolving phase, so the router can show a splash while `loading`. Login and
/// logout flip the resolved [AuthState].
///
/// Offline resilience: a transient validation failure (no network, timeout,
/// unreachable server, 5xx) must NOT drop a previously authenticated user. The
/// session is restored from the on-device user cache in that case; only an
/// explicit `401` (invalid/expired token) clears the session and requires a new
/// login.
final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
  /// Global session ViewModel.
  ///
  /// `build()` resolves the session on cold start (reads the stored token and
  /// validates it via `/auth/me`). The surrounding [AsyncValue] models the
  /// resolving phase, so the router can show a splash while `loading`. Login and
  /// logout flip the resolved [AuthState].
  ///
  /// Offline resilience: a transient validation failure (no network, timeout,
  /// unreachable server, 5xx) must NOT drop a previously authenticated user. The
  /// session is restored from the on-device user cache in that case; only an
  /// explicit `401` (invalid/expired token) clears the session and requires a new
  /// login.
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();
}

String _$authNotifierHash() => r'8ead2ca059efa8fea938cce94b6ae29a61361de1';

/// Global session ViewModel.
///
/// `build()` resolves the session on cold start (reads the stored token and
/// validates it via `/auth/me`). The surrounding [AsyncValue] models the
/// resolving phase, so the router can show a splash while `loading`. Login and
/// logout flip the resolved [AuthState].
///
/// Offline resilience: a transient validation failure (no network, timeout,
/// unreachable server, 5xx) must NOT drop a previously authenticated user. The
/// session is restored from the on-device user cache in that case; only an
/// explicit `401` (invalid/expired token) clears the session and requires a new
/// login.

abstract class _$AuthNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
