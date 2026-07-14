import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_result.dart';
import '../../features/attendance/data/attendance_providers.dart';
import '../../features/attendance/data/local/offline_providers.dart';
import '../../features/auth/presentation/providers/current_user_provider.dart';

part 'offline_bootstrap_provider.g.dart';

/// Prepares the minimum offline dataset a freshly-authenticated user needs to
/// open the Attendance flow without connectivity:
///
/// - the attendance dashboard (today's state + monthly recap), keyed to the
///   authenticated user;
/// - the office geofence configuration (shared across users).
///
/// The profile/user record is already persisted by [AuthRepository.login] and
/// `me()` (see `cachedUser`), so it is not re-fetched here.
///
/// Readiness is defined as "the minimum dataset is stored for the authenticated
/// user". When it is already cached — e.g. an offline cold start after a prior
/// session — the bootstrap resolves immediately without touching the network.
/// Otherwise it fetches and persists whatever is missing, which requires
/// connectivity; a fresh login while offline therefore surfaces an error that
/// the login/bootstrap stage can present as a retry, instead of silently
/// failing later inside the Attendance flow.
///
/// The bootstrap is strictly scoped to [currentUserIdProvider]: it never reads
/// or writes another user's cache, and it re-runs when the active user changes.
@Riverpod(keepAlive: true)
class OfflineBootstrap extends _$OfflineBootstrap {
  @override
  Future<void> build() async {
    final userId = ref.watch(currentUserIdProvider);
    // Unauthenticated: nothing to prepare. The router keeps the user on login.
    if (userId == null) return;
    await _prepare(userId);
  }

  /// Re-runs the bootstrap for the current user after a failure.
  Future<void> retry() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _prepare(userId));
  }

  Future<void> _prepare(int userId) async {
    await _ensureDashboard(userId);
    await _ensureOffices();
  }

  /// Fetches and stores the attendance dashboard for [userId] unless it is
  /// already cached for that user.
  Future<void> _ensureDashboard(int userId) async {
    final cache = await ref.read(dashboardCacheStoreProvider.future);
    if (await cache.read(userId) != null) return;

    final result = await ref.read(attendanceRepositoryProvider).dashboard();
    switch (result) {
      case Success(:final data):
        await cache.save(userId, data);
      case Failure(:final exception):
        throw exception;
    }
  }

  /// Fetches and stores the office geofence configuration unless it has already
  /// been synced. The office cache is intentionally shared across users.
  ///
  /// Readiness is "the configuration has been fetched successfully at least
  /// once", NOT "there is at least one office": a successful empty response is
  /// valid data (the admin has configured no active location) and must complete
  /// the bootstrap so the user can enter the app, where the Attendance flow then
  /// surfaces the "no locations" warning and blocks WFO. A genuinely
  /// never-synced cache with an unreachable backend still throws, so the
  /// login/bootstrap stage can offer a retry.
  Future<void> _ensureOffices() async {
    final store = await ref.read(officeConfigCacheStoreProvider.future);
    if (await store.isInitialized()) return;

    final result = await ref.read(attendanceRepositoryProvider).locations();
    switch (result) {
      case Success(:final data):
        await store.replaceAll(data);
      case Failure(:final exception):
        throw exception;
    }
  }
}
