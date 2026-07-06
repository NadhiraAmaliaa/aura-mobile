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

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// Global session ViewModel.
///
/// `build()` resolves the session on cold start (reads the stored token and
/// validates it via `/auth/me`). The surrounding [AsyncValue] models the
/// resolving phase, so the router can show a splash while `loading`. Login and
/// logout flip the resolved [AuthState].
final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
  /// Global session ViewModel.
  ///
  /// `build()` resolves the session on cold start (reads the stored token and
  /// validates it via `/auth/me`). The surrounding [AsyncValue] models the
  /// resolving phase, so the router can show a splash while `loading`. Login and
  /// logout flip the resolved [AuthState].
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

String _$authNotifierHash() => r'8071ba460e7ce8338a0b901a568c4064f82ea707';

/// Global session ViewModel.
///
/// `build()` resolves the session on cold start (reads the stored token and
/// validates it via `/auth/me`). The surrounding [AsyncValue] models the
/// resolving phase, so the router can show a splash while `loading`. Login and
/// logout flip the resolved [AuthState].

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
