// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_locations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active office locations for WFO geofence pre-validation.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. On failure the typed `AppException` is surfaced through
/// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).
///
/// A successful load is mirrored into the on-device office cache so an offline
/// capture can still freeze the geofence snapshot (see [geofenceOffices]).

@ProviderFor(AttendanceLocations)
final attendanceLocationsProvider = AttendanceLocationsProvider._();

/// The active office locations for WFO geofence pre-validation.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. On failure the typed `AppException` is surfaced through
/// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).
///
/// A successful load is mirrored into the on-device office cache so an offline
/// capture can still freeze the geofence snapshot (see [geofenceOffices]).
final class AttendanceLocationsProvider
    extends
        $AsyncNotifierProvider<
          AttendanceLocations,
          List<AttendanceLocationModel>
        > {
  /// The active office locations for WFO geofence pre-validation.
  ///
  /// Loaded lazily — the check-in screen only watches this once the user selects
  /// the WFO work mode. On failure the typed `AppException` is surfaced through
  /// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).
  ///
  /// A successful load is mirrored into the on-device office cache so an offline
  /// capture can still freeze the geofence snapshot (see [geofenceOffices]).
  AttendanceLocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceLocationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceLocationsHash();

  @$internal
  @override
  AttendanceLocations create() => AttendanceLocations();
}

String _$attendanceLocationsHash() =>
    r'4b9254738e4c6ea76db089e991db3085e0bf9db2';

/// The active office locations for WFO geofence pre-validation.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. On failure the typed `AppException` is surfaced through
/// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).
///
/// A successful load is mirrored into the on-device office cache so an offline
/// capture can still freeze the geofence snapshot (see [geofenceOffices]).

abstract class _$AttendanceLocations
    extends $AsyncNotifier<List<AttendanceLocationModel>> {
  FutureOr<List<AttendanceLocationModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AttendanceLocationModel>>,
              List<AttendanceLocationModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AttendanceLocationModel>>,
                List<AttendanceLocationModel>
              >,
              AsyncValue<List<AttendanceLocationModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The office locations to evaluate the geofence against, resilient to being
/// offline: the live list when it loads, otherwise the on-device cache.

@ProviderFor(geofenceOffices)
final geofenceOfficesProvider = GeofenceOfficesProvider._();

/// The office locations to evaluate the geofence against, resilient to being
/// offline: the live list when it loads, otherwise the on-device cache.

final class GeofenceOfficesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AttendanceLocationModel>>,
          List<AttendanceLocationModel>,
          FutureOr<List<AttendanceLocationModel>>
        >
    with
        $FutureModifier<List<AttendanceLocationModel>>,
        $FutureProvider<List<AttendanceLocationModel>> {
  /// The office locations to evaluate the geofence against, resilient to being
  /// offline: the live list when it loads, otherwise the on-device cache.
  GeofenceOfficesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geofenceOfficesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geofenceOfficesHash();

  @$internal
  @override
  $FutureProviderElement<List<AttendanceLocationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AttendanceLocationModel>> create(Ref ref) {
    return geofenceOffices(ref);
  }
}

String _$geofenceOfficesHash() => r'122385ae1a7c6d6098e6e015a4b2239d19b2e0b3';
