// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the login form submission.
///
/// Exposed as `AsyncValue<void>`: `loading` while the request is in flight,
/// `error` (carrying an `AppException`) on failure. On success it promotes the
/// global [AuthNotifier] to authenticated, which triggers the router redirect.
/// Kept separate from [AuthNotifier] so a failed login never corrupts the
/// global session state.

@ProviderFor(LoginNotifier)
final loginProvider = LoginNotifierProvider._();

/// Drives the login form submission.
///
/// Exposed as `AsyncValue<void>`: `loading` while the request is in flight,
/// `error` (carrying an `AppException`) on failure. On success it promotes the
/// global [AuthNotifier] to authenticated, which triggers the router redirect.
/// Kept separate from [AuthNotifier] so a failed login never corrupts the
/// global session state.
final class LoginNotifierProvider
    extends $AsyncNotifierProvider<LoginNotifier, void> {
  /// Drives the login form submission.
  ///
  /// Exposed as `AsyncValue<void>`: `loading` while the request is in flight,
  /// `error` (carrying an `AppException`) on failure. On success it promotes the
  /// global [AuthNotifier] to authenticated, which triggers the router redirect.
  /// Kept separate from [AuthNotifier] so a failed login never corrupts the
  /// global session state.
  LoginNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginNotifierHash();

  @$internal
  @override
  LoginNotifier create() => LoginNotifier();
}

String _$loginNotifierHash() => r'8dbe076ed8bb3122ece7eaf1c89ccf0c988dbd15';

/// Drives the login form submission.
///
/// Exposed as `AsyncValue<void>`: `loading` while the request is in flight,
/// `error` (carrying an `AppException`) on failure. On success it promotes the
/// global [AuthNotifier] to authenticated, which triggers the router redirect.
/// Kept separate from [AuthNotifier] so a failed login never corrupts the
/// global session state.

abstract class _$LoginNotifier extends $AsyncNotifier<void> {
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
