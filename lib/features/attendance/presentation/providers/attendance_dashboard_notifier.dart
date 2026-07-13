import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/connectivity_providers.dart';
import '../../data/attendance_providers.dart';
import '../../data/local/dashboard_cache_store.dart';
import '../../data/local/offline_providers.dart';
import '../../data/models/attendance_models.dart';

part 'attendance_dashboard_notifier.g.dart';

/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. A successful load is cached on-device;
/// when the backend is unreachable (offline / timeout / 5xx) the cached
/// snapshot is served so the screen stays usable instead of erroring or
/// spinning forever. Only an explicit `401` surfaces as an error — a transient
/// failure must never look like a broken session.
@riverpod
class AttendanceDashboardNotifier extends _$AttendanceDashboardNotifier {
  @override
  Future<AttendanceDashboardModel> build() => _load();

  /// Re-fetch the dashboard, showing a loading state while it refreshes.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<AttendanceDashboardModel> _load() async {
    final cache = await ref.read(dashboardCacheStoreProvider.future);

    // Offline short-circuit: when there is no transport at all, don't wait on a
    // doomed request (and its timeout) — render the cached snapshot at once.
    final connectivity = await ref
        .read(connectivityProvider)
        .checkConnectivity();
    if (!hasConnectivity(connectivity)) {
      final cached = await cache.read();
      if (cached != null) return cached;
    }

    final result = await ref.read(attendanceRepositoryProvider).dashboard();
    return switch (result) {
      Success(:final data) => await _cache(cache, data),
      // Session actually rejected → surface it so the UI can react/re-auth.
      Failure(:final exception) when exception is UnauthorizedException =>
        throw exception,
      // Unreachable server / timeout / 5xx → fall back to the last snapshot.
      Failure(:final exception) => await cache.read() ?? (throw exception),
    };
  }

  Future<AttendanceDashboardModel> _cache(
    DashboardCacheStore cache,
    AttendanceDashboardModel data,
  ) async {
    // Best-effort: a cache write failure must not break the live load.
    try {
      await cache.save(data);
    } on Object {
      // Ignore — the live payload is authoritative; the cache is an optimisation.
    }
    return data;
  }
}
