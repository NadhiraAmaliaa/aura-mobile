// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Retrofit device-token client bound to the shared Dio instance (so the
/// bearer token is attached by the existing AuthInterceptor).

@ProviderFor(deviceTokenApi)
final deviceTokenApiProvider = DeviceTokenApiProvider._();

/// Retrofit device-token client bound to the shared Dio instance (so the
/// bearer token is attached by the existing AuthInterceptor).

final class DeviceTokenApiProvider
    extends $FunctionalProvider<DeviceTokenApi, DeviceTokenApi, DeviceTokenApi>
    with $Provider<DeviceTokenApi> {
  /// Retrofit device-token client bound to the shared Dio instance (so the
  /// bearer token is attached by the existing AuthInterceptor).
  DeviceTokenApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTokenApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTokenApiHash();

  @$internal
  @override
  $ProviderElement<DeviceTokenApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceTokenApi create(Ref ref) {
    return deviceTokenApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceTokenApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceTokenApi>(value),
    );
  }
}

String _$deviceTokenApiHash() => r'72f2dcc7608ddc46e9cd1d98b9e7864f72533cfe';

/// The device-token repository seam consumed by the registrar.

@ProviderFor(deviceTokenRepository)
final deviceTokenRepositoryProvider = DeviceTokenRepositoryProvider._();

/// The device-token repository seam consumed by the registrar.

final class DeviceTokenRepositoryProvider
    extends
        $FunctionalProvider<
          DeviceTokenRepository,
          DeviceTokenRepository,
          DeviceTokenRepository
        >
    with $Provider<DeviceTokenRepository> {
  /// The device-token repository seam consumed by the registrar.
  DeviceTokenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTokenRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTokenRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeviceTokenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceTokenRepository create(Ref ref) {
    return deviceTokenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceTokenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceTokenRepository>(value),
    );
  }
}

String _$deviceTokenRepositoryHash() =>
    r'd5e2ee98d131cd014d2db7f23f0c34136f252f06';
