// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_time_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform monotonic clock seam (real native calls in production, faked in
/// tests).

@ProviderFor(platformClock)
final platformClockProvider = PlatformClockProvider._();

/// The platform monotonic clock seam (real native calls in production, faked in
/// tests).

final class PlatformClockProvider
    extends $FunctionalProvider<PlatformClock, PlatformClock, PlatformClock>
    with $Provider<PlatformClock> {
  /// The platform monotonic clock seam (real native calls in production, faked in
  /// tests).
  PlatformClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformClockHash();

  @$internal
  @override
  $ProviderElement<PlatformClock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlatformClock create(Ref ref) {
    return platformClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlatformClock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlatformClock>(value),
    );
  }
}

String _$platformClockHash() => r'2efd7aeb45a8943672b93def20ee7c3876daa6a5';

/// The trusted time service, wired to the platform clock and the shared
/// database. Kept alive for the app's lifetime.

@ProviderFor(trustedTimeService)
final trustedTimeServiceProvider = TrustedTimeServiceProvider._();

/// The trusted time service, wired to the platform clock and the shared
/// database. Kept alive for the app's lifetime.

final class TrustedTimeServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrustedTimeService>,
          TrustedTimeService,
          FutureOr<TrustedTimeService>
        >
    with
        $FutureModifier<TrustedTimeService>,
        $FutureProvider<TrustedTimeService> {
  /// The trusted time service, wired to the platform clock and the shared
  /// database. Kept alive for the app's lifetime.
  TrustedTimeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedTimeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedTimeServiceHash();

  @$internal
  @override
  $FutureProviderElement<TrustedTimeService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrustedTimeService> create(Ref ref) {
    return trustedTimeService(ref);
  }
}

String _$trustedTimeServiceHash() =>
    r'8ac966e5c571a269ce50905be50426ebe850e6be';
