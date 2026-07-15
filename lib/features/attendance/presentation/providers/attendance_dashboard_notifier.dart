import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/connectivity_providers.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/attendance_providers.dart';
import '../../data/local/dashboard_cache_store.dart';
import '../../data/local/offline_providers.dart';
import '../../data/models/attendance_models.dart';

part 'attendance_dashboard_notifier.g.dart';

/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. A successful load is cached on-device
/// under the current user; when the backend is unreachable (offline / timeout /
/// 5xx) that user's cached snapshot is served so the screen stays usable instead
/// of erroring or spinning forever. Only an explicit `401` surfaces as an error
/// — a transient failure must never look like a broken session.
///
/// The cache is scoped to the authenticated user ([currentUserIdProvider]): a
/// user switch reloads against the new owner, so account B never renders account
/// A's cached attendance. A user with no cache of their own falls through to the
/// transient error (proper "offline data unavailable" state), never another
/// user's data.
@riverpod
class AttendanceDashboardNotifier extends _$AttendanceDashboardNotifier {
  @override
  Future<AttendanceDashboardModel> build() => _load();

  /// Re-fetch the dashboard, showing a loading state while it refreshes.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Re-fetch the dashboard *in place*, without a loading flash: the current
  /// snapshot stays on screen and is swapped only when the refresh actually
  /// produces data. A failed refresh (offline / timeout / transient) leaves the
  /// last good snapshot untouched, so a background resume/reconnect refresh
  /// never wipes usable data or flickers a spinner. An explicit `401` is handled
  /// globally by the auth interceptor, so it is intentionally not surfaced here.
  Future<void> silentRefresh() async {
    final refreshed = await AsyncValue.guard(_load);
    if (refreshed is AsyncData<AttendanceDashboardModel>) {
      state = refreshed;
    }
  }

  Future<AttendanceDashboardModel> _load() async {
    final userId = ref.watch(currentUserIdProvider);
    final cache = await ref.read(dashboardCacheStoreProvider.future);

    // Offline short-circuit: when there is no transport at all, don't wait on a
    // doomed request (and its timeout) — render this user's cached snapshot at
    // once when we have one.
    final connectivity = await ref
        .read(connectivityProvider)
        .checkConnectivity();
    if (!hasConnectivity(connectivity)) {
      final cached = userId == null ? null : await cache.read(userId);
      if (cached != null) return cached;
    }

    final result = await ref.read(attendanceRepositoryProvider).dashboard();
    return switch (result) {
      Success(:final data) => await _cache(cache, userId, data),
      // Session actually rejected → surface it so the UI can react/re-auth.
      Failure(:final exception) when exception is UnauthorizedException =>
        throw exception,
      // Unreachable server / timeout / 5xx → fall back to this user's snapshot.
      Failure(:final exception) =>
        (userId == null ? null : await cache.read(userId)) ?? (throw exception),
    };
  }

  Future<AttendanceDashboardModel> _cache(
    DashboardCacheStore cache,
    int? userId,
    AttendanceDashboardModel data,
  ) async {
    // Best-effort: a cache write failure must not break the live load. Only
    // cache when we know the owner.
    if (userId != null) {
      try {
        await cache.save(userId, data);
      } on Object {
        // Ignore — the live payload is authoritative; the cache is an optimisation.
      }
    }
    return data;
  }
}
