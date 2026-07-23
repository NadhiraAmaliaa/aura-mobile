// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_registrar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session-lifetime side effect that keeps the backend's copy of this device's
/// FCM token in sync with Firebase.
///
/// Armed once by the root widget (the same pattern as the offline-queue session
/// sync). It stays inert while the session is resolving or unauthenticated;
/// once authenticated it registers the current token and re-registers whenever
/// FCM rotates it. Failures never block login or startup — they are logged in
/// debug and (for unexpected errors) reported to Sentry inside the repository,
/// then simply retried on the next arm or refresh. On logout it clears only the
/// local "already registered" marker; the Firebase token itself is left intact.

@ProviderFor(DeviceTokenRegistrar)
final deviceTokenRegistrarProvider = DeviceTokenRegistrarProvider._();

/// Session-lifetime side effect that keeps the backend's copy of this device's
/// FCM token in sync with Firebase.
///
/// Armed once by the root widget (the same pattern as the offline-queue session
/// sync). It stays inert while the session is resolving or unauthenticated;
/// once authenticated it registers the current token and re-registers whenever
/// FCM rotates it. Failures never block login or startup — they are logged in
/// debug and (for unexpected errors) reported to Sentry inside the repository,
/// then simply retried on the next arm or refresh. On logout it clears only the
/// local "already registered" marker; the Firebase token itself is left intact.
final class DeviceTokenRegistrarProvider
    extends $AsyncNotifierProvider<DeviceTokenRegistrar, void> {
  /// Session-lifetime side effect that keeps the backend's copy of this device's
  /// FCM token in sync with Firebase.
  ///
  /// Armed once by the root widget (the same pattern as the offline-queue session
  /// sync). It stays inert while the session is resolving or unauthenticated;
  /// once authenticated it registers the current token and re-registers whenever
  /// FCM rotates it. Failures never block login or startup — they are logged in
  /// debug and (for unexpected errors) reported to Sentry inside the repository,
  /// then simply retried on the next arm or refresh. On logout it clears only the
  /// local "already registered" marker; the Firebase token itself is left intact.
  DeviceTokenRegistrarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTokenRegistrarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTokenRegistrarHash();

  @$internal
  @override
  DeviceTokenRegistrar create() => DeviceTokenRegistrar();
}

String _$deviceTokenRegistrarHash() =>
    r'68ed055af65571e04ec02486ac6a0594de51ddd8';

/// Session-lifetime side effect that keeps the backend's copy of this device's
/// FCM token in sync with Firebase.
///
/// Armed once by the root widget (the same pattern as the offline-queue session
/// sync). It stays inert while the session is resolving or unauthenticated;
/// once authenticated it registers the current token and re-registers whenever
/// FCM rotates it. Failures never block login or startup — they are logged in
/// debug and (for unexpected errors) reported to Sentry inside the repository,
/// then simply retried on the next arm or refresh. On logout it clears only the
/// local "already registered" marker; the Firebase token itself is left intact.

abstract class _$DeviceTokenRegistrar extends $AsyncNotifier<void> {
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
