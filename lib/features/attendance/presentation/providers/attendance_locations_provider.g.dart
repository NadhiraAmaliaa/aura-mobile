// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_locations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active office locations for WFO geofence pre-validation, used to render
/// the map.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. Offline-resilient like the dashboard: when the backend is
/// unreachable (no network / timeout / 5xx) the on-device office cache is served
/// so the map still renders instead of spinning forever. Only an explicit `401`
/// surfaces as an error; a truly empty state (never loaded online) surfaces the
/// transient error so the map can offer "Coba Lagi".
///
/// A successful load is mirrored into the on-device office cache so an offline
/// capture can still freeze the geofence snapshot (see [geofenceOffices]).

@ProviderFor(AttendanceLocations)
final attendanceLocationsProvider = AttendanceLocationsProvider._();

/// The active office locations for WFO geofence pre-validation, used to render
/// the map.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. Offline-resilient like the dashboard: when the backend is
/// unreachable (no network / timeout / 5xx) the on-device office cache is served
/// so the map still renders instead of spinning forever. Only an explicit `401`
/// surfaces as an error; a truly empty state (never loaded online) surfaces the
/// transient error so the map can offer "Coba Lagi".
///
/// A successful load is mirrored into the on-device office cache so an offline
/// capture can still freeze the geofence snapshot (see [geofenceOffices]).
final class AttendanceLocationsProvider
    extends
        $AsyncNotifierProvider<
          AttendanceLocations,
          List<AttendanceLocationModel>
        > {
  /// The active office locations for WFO geofence pre-validation, used to render
  /// the map.
  ///
  /// Loaded lazily — the check-in screen only watches this once the user selects
  /// the WFO work mode. Offline-resilient like the dashboard: when the backend is
  /// unreachable (no network / timeout / 5xx) the on-device office cache is served
  /// so the map still renders instead of spinning forever. Only an explicit `401`
  /// surfaces as an error; a truly empty state (never loaded online) surfaces the
  /// transient error so the map can offer "Coba Lagi".
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
    r'5c9cc51358e9c5c1b397272ae91799d7b3dbc9fc';

/// The active office locations for WFO geofence pre-validation, used to render
/// the map.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. Offline-resilient like the dashboard: when the backend is
/// unreachable (no network / timeout / 5xx) the on-device office cache is served
/// so the map still renders instead of spinning forever. Only an explicit `401`
/// surfaces as an error; a truly empty state (never loaded online) surfaces the
/// transient error so the map can offer "Coba Lagi".
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

/// The office locations to evaluate the geofence against for an attendance
/// capture.
///
/// The backend is authoritative for the active-office set: when the device has
/// transport, this performs a single bounded fetch (Dio timeouts, never a
/// provider retry loop) and treats the result as the truth. A successful but
/// empty response means the admin has removed every active office — it CLEARS
/// the stale cache and resolves to an empty list so the caller surfaces the
/// "no locations configured" state and blocks a WFO capture, rather than
/// silently validating against phantom offices from an old cache.
///
/// Only when the backend is unreachable (no transport, timeout, 5xx, or an
/// auth failure) does it fall back to the most recently cached office config,
/// so an offline capture can still freeze the geofence snapshot it last knew.

@ProviderFor(geofenceOffices)
final geofenceOfficesProvider = GeofenceOfficesProvider._();

/// The office locations to evaluate the geofence against for an attendance
/// capture.
///
/// The backend is authoritative for the active-office set: when the device has
/// transport, this performs a single bounded fetch (Dio timeouts, never a
/// provider retry loop) and treats the result as the truth. A successful but
/// empty response means the admin has removed every active office — it CLEARS
/// the stale cache and resolves to an empty list so the caller surfaces the
/// "no locations configured" state and blocks a WFO capture, rather than
/// silently validating against phantom offices from an old cache.
///
/// Only when the backend is unreachable (no transport, timeout, 5xx, or an
/// auth failure) does it fall back to the most recently cached office config,
/// so an offline capture can still freeze the geofence snapshot it last knew.

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
  /// The office locations to evaluate the geofence against for an attendance
  /// capture.
  ///
  /// The backend is authoritative for the active-office set: when the device has
  /// transport, this performs a single bounded fetch (Dio timeouts, never a
  /// provider retry loop) and treats the result as the truth. A successful but
  /// empty response means the admin has removed every active office — it CLEARS
  /// the stale cache and resolves to an empty list so the caller surfaces the
  /// "no locations configured" state and blocks a WFO capture, rather than
  /// silently validating against phantom offices from an old cache.
  ///
  /// Only when the backend is unreachable (no transport, timeout, 5xx, or an
  /// auth failure) does it fall back to the most recently cached office config,
  /// so an offline capture can still freeze the geofence snapshot it last knew.
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

String _$geofenceOfficesHash() => r'c4864d67b32d2ae465dc350c7f523a7a5790b2f3';
