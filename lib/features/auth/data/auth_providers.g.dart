// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Retrofit auth client bound to the shared Dio instance.

@ProviderFor(authApi)
final authApiProvider = AuthApiProvider._();

/// Retrofit auth client bound to the shared Dio instance.

final class AuthApiProvider
    extends $FunctionalProvider<AuthApi, AuthApi, AuthApi>
    with $Provider<AuthApi> {
  /// Retrofit auth client bound to the shared Dio instance.
  AuthApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authApiHash();

  @$internal
  @override
  $ProviderElement<AuthApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthApi create(Ref ref) {
    return authApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthApi>(value),
    );
  }
}

String _$authApiHash() => r'e5df0abb7e1b82b150be8712d09ad476f1abb117';

/// Retrofit lookup client bound to the shared Dio instance.

@ProviderFor(lookupApi)
final lookupApiProvider = LookupApiProvider._();

/// Retrofit lookup client bound to the shared Dio instance.

final class LookupApiProvider
    extends $FunctionalProvider<LookupApi, LookupApi, LookupApi>
    with $Provider<LookupApi> {
  /// Retrofit lookup client bound to the shared Dio instance.
  LookupApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lookupApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lookupApiHash();

  @$internal
  @override
  $ProviderElement<LookupApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LookupApi create(Ref ref) {
    return lookupApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LookupApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LookupApi>(value),
    );
  }
}

String _$lookupApiHash() => r'e6cff67f4362c15c1514615be55b69756fa1e51d';

/// The auth repository seam consumed by the presentation layer.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// The auth repository seam consumed by the presentation layer.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// The auth repository seam consumed by the presentation layer.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'69b31520ebb249456ace82730a1edb90d3231bfd';

/// Reference-data repository for the login screen.

@ProviderFor(lookupRepository)
final lookupRepositoryProvider = LookupRepositoryProvider._();

/// Reference-data repository for the login screen.

final class LookupRepositoryProvider
    extends
        $FunctionalProvider<
          LookupRepository,
          LookupRepository,
          LookupRepository
        >
    with $Provider<LookupRepository> {
  /// Reference-data repository for the login screen.
  LookupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lookupRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lookupRepositoryHash();

  @$internal
  @override
  $ProviderElement<LookupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LookupRepository create(Ref ref) {
    return lookupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LookupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LookupRepository>(value),
    );
  }
}

String _$lookupRepositoryHash() => r'135b021fb25817d220d2352eed4d6e908b410d14';
