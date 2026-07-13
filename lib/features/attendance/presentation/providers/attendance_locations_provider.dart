import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import '../../data/local/offline_providers.dart';
import '../../data/models/attendance_models.dart';

part 'attendance_locations_provider.g.dart';

/// The active office locations for WFO geofence pre-validation.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. On failure the typed `AppException` is surfaced through
/// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).
///
/// A successful load is mirrored into the on-device office cache so an offline
/// capture can still freeze the geofence snapshot (see [geofenceOffices]).
@riverpod
class AttendanceLocations extends _$AttendanceLocations {
  @override
  Future<List<AttendanceLocationModel>> build() => _load();

  Future<List<AttendanceLocationModel>> _load() async {
    final result = await ref.read(attendanceRepositoryProvider).locations();

    return switch (result) {
      Success(:final data) => await _cache(data),
      Failure(:final exception) => throw exception,
    };
  }

  Future<List<AttendanceLocationModel>> _cache(
    List<AttendanceLocationModel> offices,
  ) async {
    // Best-effort: a cache write failure must not break the live locations load.
    try {
      final store = await ref.read(officeConfigCacheStoreProvider.future);
      await store.replaceAll(offices);
    } on Object {
      // Ignore — the live list is authoritative; the cache is an optimisation.
    }
    return offices;
  }
}

/// The office locations to evaluate the geofence against, resilient to being
/// offline: the live list when it loads, otherwise the on-device cache.
@riverpod
Future<List<AttendanceLocationModel>> geofenceOffices(Ref ref) async {
  try {
    // A one-shot read (not watch): a transient locations failure must not
    // rebuild — and dispose — this load mid-flight while it falls back below.
    final live = await ref.read(attendanceLocationsProvider.future);
    if (live.isNotEmpty) return live;
  } on Object {
    // Fall through to the cache when the network is unavailable.
  }
  final store = await ref.read(officeConfigCacheStoreProvider.future);
  return store.all();
}
