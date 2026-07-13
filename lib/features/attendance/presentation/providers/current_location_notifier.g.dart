// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_location_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the "get my current location" flow for attendance.
///
/// Starts [CurrentLocationState.idle] so no permission prompt appears until the
/// user explicitly taps to fetch. Slice 4 (check-in) reads the resolved
/// [GeoPosition] from the [LocationReady] state.

@ProviderFor(CurrentLocation)
final currentLocationProvider = CurrentLocationProvider._();

/// Drives the "get my current location" flow for attendance.
///
/// Starts [CurrentLocationState.idle] so no permission prompt appears until the
/// user explicitly taps to fetch. Slice 4 (check-in) reads the resolved
/// [GeoPosition] from the [LocationReady] state.
final class CurrentLocationProvider
    extends $NotifierProvider<CurrentLocation, CurrentLocationState> {
  /// Drives the "get my current location" flow for attendance.
  ///
  /// Starts [CurrentLocationState.idle] so no permission prompt appears until the
  /// user explicitly taps to fetch. Slice 4 (check-in) reads the resolved
  /// [GeoPosition] from the [LocationReady] state.
  CurrentLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLocationHash();

  @$internal
  @override
  CurrentLocation create() => CurrentLocation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrentLocationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrentLocationState>(value),
    );
  }
}

String _$currentLocationHash() => r'4fa204d09d94d41e37f6cb4a16ed97a756fa7cf4';

/// Drives the "get my current location" flow for attendance.
///
/// Starts [CurrentLocationState.idle] so no permission prompt appears until the
/// user explicitly taps to fetch. Slice 4 (check-in) reads the resolved
/// [GeoPosition] from the [LocationReady] state.

abstract class _$CurrentLocation extends $Notifier<CurrentLocationState> {
  CurrentLocationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CurrentLocationState, CurrentLocationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CurrentLocationState, CurrentLocationState>,
              CurrentLocationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
