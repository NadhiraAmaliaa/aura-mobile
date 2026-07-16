// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Retrofit leave client bound to the shared Dio instance.

@ProviderFor(leaveApi)
final leaveApiProvider = LeaveApiProvider._();

/// Retrofit leave client bound to the shared Dio instance.

final class LeaveApiProvider
    extends $FunctionalProvider<LeaveApi, LeaveApi, LeaveApi>
    with $Provider<LeaveApi> {
  /// Retrofit leave client bound to the shared Dio instance.
  LeaveApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveApiHash();

  @$internal
  @override
  $ProviderElement<LeaveApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LeaveApi create(Ref ref) {
    return leaveApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeaveApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeaveApi>(value),
    );
  }
}

String _$leaveApiHash() => r'a8c6e95f38e09f8b1e80ad36d41f126210b55600';

/// The leave repository seam consumed by the presentation layer.

@ProviderFor(leaveRepository)
final leaveRepositoryProvider = LeaveRepositoryProvider._();

/// The leave repository seam consumed by the presentation layer.

final class LeaveRepositoryProvider
    extends
        $FunctionalProvider<LeaveRepository, LeaveRepository, LeaveRepository>
    with $Provider<LeaveRepository> {
  /// The leave repository seam consumed by the presentation layer.
  LeaveRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveRepositoryHash();

  @$internal
  @override
  $ProviderElement<LeaveRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LeaveRepository create(Ref ref) {
    return leaveRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeaveRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeaveRepository>(value),
    );
  }
}

String _$leaveRepositoryHash() => r'cd697e518970d8d513dacfaf97ed375285dec2da';
