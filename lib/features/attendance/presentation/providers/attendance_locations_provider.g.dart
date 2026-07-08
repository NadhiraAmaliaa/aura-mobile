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

@ProviderFor(AttendanceLocations)
final attendanceLocationsProvider = AttendanceLocationsProvider._();

/// The active office locations for WFO geofence pre-validation.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. On failure the typed `AppException` is surfaced through
/// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).
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
    r'510463f5a096d5956f4cce63014b4a1fabc2a429';

/// The active office locations for WFO geofence pre-validation.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. On failure the typed `AppException` is surfaced through
/// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).

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
