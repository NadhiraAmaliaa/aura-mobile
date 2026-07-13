import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/connectivity_providers.dart';
import '../../data/attendance_providers.dart';
import '../../data/local/offline_providers.dart';
import '../../data/models/attendance_models.dart';

part 'attendance_locations_provider.g.dart';

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
@riverpod
class AttendanceLocations extends _$AttendanceLocations {
  @override
  Future<List<AttendanceLocationModel>> build() => _load();

  Future<List<AttendanceLocationModel>> _load() async {
    // No transport at all → don't wait on a doomed request; serve the cache.
    final connectivity = await ref
        .read(connectivityProvider)
        .checkConnectivity();
    if (!hasConnectivity(connectivity)) {
      final cached = await _cachedOffices();
      if (cached.isNotEmpty) return cached;
    }

    final result = await ref.read(attendanceRepositoryProvider).locations();
    return switch (result) {
      Success(:final data) => await _cache(data),
      // Token explicitly rejected → surface it (the session must re-auth).
      Failure(:final exception) when exception is UnauthorizedException =>
        throw exception,
      // Unreachable server / timeout / 5xx → fall back to the cached offices.
      Failure(:final exception) => await _cachedOrThrow(exception),
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

  /// The cached offices, or an empty list when nothing is cached / readable.
  Future<List<AttendanceLocationModel>> _cachedOffices() async {
    try {
      final store = await ref.read(officeConfigCacheStoreProvider.future);
      return store.all();
    } on Object {
      return const [];
    }
  }

  /// Serve the cache when present, otherwise re-throw the transient error so a
  /// never-loaded map can show a retry instead of a permanent empty map.
  Future<List<AttendanceLocationModel>> _cachedOrThrow(
    AppException exception,
  ) async {
    final cached = await _cachedOffices();
    if (cached.isNotEmpty) return cached;
    throw exception;
  }
}

/// The office locations to evaluate the geofence against for an attendance
/// capture.
///
/// Capture must NEVER block on the live map or its network retry loop, so this
/// is cache-first and fully decoupled from [attendanceLocationsProvider]: it
/// serves the on-device office cache (refreshed on every successful live load)
/// and resolves instantly offline. Only when the cache is cold (never loaded
/// online) does it attempt a single direct fetch — bounded by the Dio timeouts,
/// never a provider retry loop — and skips even that when there is no transport.
@riverpod
Future<List<AttendanceLocationModel>> geofenceOffices(Ref ref) async {
  final store = await ref.read(officeConfigCacheStoreProvider.future);
  final cached = await store.all();
  if (cached.isNotEmpty) return cached;

  final connectivity = await ref.read(connectivityProvider).checkConnectivity();
  if (!hasConnectivity(connectivity)) return const [];

  final result = await ref.read(attendanceRepositoryProvider).locations();
  return switch (result) {
    Success(:final data) when data.isNotEmpty => await _cacheOffices(ref, data),
    _ => const <AttendanceLocationModel>[],
  };
}

/// Persists the freshly fetched [offices] for the next (possibly offline)
/// capture. Best-effort — a cache write failure must not fail the capture.
Future<List<AttendanceLocationModel>> _cacheOffices(
  Ref ref,
  List<AttendanceLocationModel> offices,
) async {
  try {
    final store = await ref.read(officeConfigCacheStoreProvider.future);
    await store.replaceAll(offices);
  } on Object {
    // Ignore — the fetched list is authoritative; the cache is an optimisation.
  }
  return offices;
}
