// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The singleton [FirebaseMessaging] instance. Isolated behind a provider so it
/// can be overridden with a fake in tests.

@ProviderFor(firebaseMessaging)
final firebaseMessagingProvider = FirebaseMessagingProvider._();

/// The singleton [FirebaseMessaging] instance. Isolated behind a provider so it
/// can be overridden with a fake in tests.

final class FirebaseMessagingProvider
    extends
        $FunctionalProvider<
          FirebaseMessaging,
          FirebaseMessaging,
          FirebaseMessaging
        >
    with $Provider<FirebaseMessaging> {
  /// The singleton [FirebaseMessaging] instance. Isolated behind a provider so it
  /// can be overridden with a fake in tests.
  FirebaseMessagingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseMessagingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseMessagingHash();

  @$internal
  @override
  $ProviderElement<FirebaseMessaging> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseMessaging create(Ref ref) {
    return firebaseMessaging(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseMessaging value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseMessaging>(value),
    );
  }
}

String _$firebaseMessagingHash() => r'6765ce963b9b8c50186b5132356d60eb68265741';

/// The app's FCM service. Its stream subscriptions are cancelled when the
/// container is disposed.

@ProviderFor(fcmService)
final fcmServiceProvider = FcmServiceProvider._();

/// The app's FCM service. Its stream subscriptions are cancelled when the
/// container is disposed.

final class FcmServiceProvider
    extends $FunctionalProvider<FcmService, FcmService, FcmService>
    with $Provider<FcmService> {
  /// The app's FCM service. Its stream subscriptions are cancelled when the
  /// container is disposed.
  FcmServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmServiceHash();

  @$internal
  @override
  $ProviderElement<FcmService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FcmService create(Ref ref) {
    return fcmService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FcmService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FcmService>(value),
    );
  }
}

String _$fcmServiceHash() => r'43d24eaefdff67f836029a55a2cb3971776efaaf';

/// App-lifetime arming hook: initializes the foreground FCM lifecycle exactly
/// once.
///
/// Watched by the root widget so permission handling, token logging and the
/// message listeners are wired for the whole app session, independent of any
/// screen being open.

@ProviderFor(fcmBootstrap)
final fcmBootstrapProvider = FcmBootstrapProvider._();

/// App-lifetime arming hook: initializes the foreground FCM lifecycle exactly
/// once.
///
/// Watched by the root widget so permission handling, token logging and the
/// message listeners are wired for the whole app session, independent of any
/// screen being open.

final class FcmBootstrapProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// App-lifetime arming hook: initializes the foreground FCM lifecycle exactly
  /// once.
  ///
  /// Watched by the root widget so permission handling, token logging and the
  /// message listeners are wired for the whole app session, independent of any
  /// screen being open.
  FcmBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmBootstrapHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return fcmBootstrap(ref);
  }
}

String _$fcmBootstrapHash() => r'62448549f24f3dd0d8108b6ef5b4e34d66ce0644';
