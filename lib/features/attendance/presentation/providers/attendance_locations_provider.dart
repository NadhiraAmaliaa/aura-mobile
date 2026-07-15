import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/connectivity_providers.dart';
import '../../data/attendance_providers.dart';
import '../../data/local/office_config_cache_store.dart';
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
@riverpod
Future<List<AttendanceLocationModel>> geofenceOffices(Ref ref) async {
  // Capture every dependency synchronously, before the first await. This
  // provider is auto-dispose and is read transiently (ref.read(...future)), so
  // it can be disposed mid-build once the read completes. Touching `ref` after
  // an await would then throw "Cannot use Ref after it has been disposed".
  // Reading the dependencies up front means the async work below only uses the
  // captured objects, never `ref`.
  final storeFuture = ref.read(officeConfigCacheStoreProvider.future);
  final connectivity = ref.read(connectivityProvider);
  final repository = ref.read(attendanceRepositoryProvider);

  final store = await storeFuture;

  // No transport at all → the server is unreachable; the last cached config is
  // the best (and only) source. Skip the doomed request entirely.
  final status = await connectivity.checkConnectivity();
  if (!hasConnectivity(status)) return store.all();

  // Online → the server decides. A successful (even empty) response replaces
  // the cache; only a genuine failure falls back to the cached offices.
  final result = await repository.locations();
  return switch (result) {
    Success(:final data) => await _cacheOffices(store, data),
    Failure() => await store.all(),
  };
}

/// Persists the freshly fetched [offices] for the next (possibly offline)
/// capture. Best-effort — a cache write failure must not fail the capture.
Future<List<AttendanceLocationModel>> _cacheOffices(
  OfficeConfigCacheStore store,
  List<AttendanceLocationModel> offices,
) async {
  try {
    await store.replaceAll(offices);
  } on Object {
    // Ignore — the fetched list is authoritative; the cache is an optimisation.
  }
  return offices;
}
