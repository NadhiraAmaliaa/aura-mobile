import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/dashboard_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/current_user_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Connectivity stub — reports a fixed transport so the notifier's offline
/// short-circuit is deterministic.
class _FakeConnectivity implements Connectivity {
  _FakeConnectivity({required this.connected});

  final bool connected;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      connected ? [ConnectivityResult.wifi] : [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

/// In-memory dashboard cache keyed by user id, so cross-account isolation can
/// be exercised. A positional seed is stored for the default test user (7).
class _FakeDashboardCache implements DashboardCacheStore {
  _FakeDashboardCache([AttendanceDashboardModel? seedForUser7]) {
    if (seedForUser7 != null) _byUser[7] = seedForUser7;
  }

  final Map<int, AttendanceDashboardModel> _byUser = {};
  int saves = 0;

  @override
  Future<AttendanceDashboardModel?> read(int userId) async => _byUser[userId];

  @override
  Future<void> save(int userId, AttendanceDashboardModel dashboard) async {
    _byUser[userId] = dashboard;
    saves++;
  }
}

/// A repository whose `dashboard` returns a scripted result and counts calls.
class _FakeAttendanceRepository implements AttendanceRepository {
  _FakeAttendanceRepository(this.dashboardResult);

  ApiResult<AttendanceDashboardModel> dashboardResult;
  int dashboardCalls = 0;

  @override
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month}) async {
    dashboardCalls++;
    return dashboardResult;
  }

  @override
  Future<ApiResult<AttendanceHistoryModel>> history({
    int? page,
    int? perPage,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<AttendanceModel>> syncEvent(AttendanceQueueEntry entry) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<AttendanceLocationModel>>> locations() =>
      throw UnimplementedError();
}

const _dashboard = AttendanceDashboardModel(
  today: AttendanceTodayModel(
    date: '2026-07-12',
    isWorkingDay: true,
    workHours: WorkHoursModel(start: '08:00', end: '17:00'),
  ),
  summary: MonthlySummaryModel(month: '2026-07'),
);

ProviderContainer _container({
  required bool connected,
  required _FakeAttendanceRepository repository,
  required _FakeDashboardCache cache,
  int userId = 7,
}) {
  return ProviderContainer.test(
    // Disable Riverpod's default error-retry so a failed load settles to a
    // stable AsyncError instead of looping through AsyncLoading(retrying).
    retry: (_, _) => null,
    overrides: [
      currentUserIdProvider.overrideWithValue(userId),
      connectivityProvider.overrideWithValue(
        _FakeConnectivity(connected: connected),
      ),
      attendanceRepositoryProvider.overrideWithValue(repository),
      dashboardCacheStoreProvider.overrideWith((ref) async => cache),
    ],
  );
}

void main() {
  group('AttendanceDashboardNotifier offline resilience', () {
    test('serves fresh data and caches it when online', () async {
      final repository = _FakeAttendanceRepository(const Success(_dashboard));
      final cache = _FakeDashboardCache();
      final container = _container(
        connected: true,
        repository: repository,
        cache: cache,
      );

      final data = await container.read(attendanceDashboardProvider.future);

      expect(data, _dashboard);
      expect(repository.dashboardCalls, 1);
      expect(cache.saves, 1);
    });

    test(
      'serves the cached snapshot without a network call when offline',
      () async {
        final repository = _FakeAttendanceRepository(
          Failure(const NetworkException()),
        );
        final cache = _FakeDashboardCache(_dashboard);
        final container = _container(
          connected: false,
          repository: repository,
          cache: cache,
        );

        final data = await container.read(attendanceDashboardProvider.future);

        expect(data, _dashboard);
        // Offline short-circuit: the doomed request is never attempted.
        expect(repository.dashboardCalls, 0);
      },
    );

    test(
      'falls back to cache when connected but the server is unreachable',
      () async {
        final repository = _FakeAttendanceRepository(
          Failure(const RequestTimeoutException()),
        );
        final cache = _FakeDashboardCache(_dashboard);
        final container = _container(
          connected: true,
          repository: repository,
          cache: cache,
        );

        final data = await container.read(attendanceDashboardProvider.future);

        expect(data, _dashboard);
        expect(repository.dashboardCalls, 1);
      },
    );

    test(
      'surfaces an explicit 401 as an error even if a cache exists',
      () async {
        final repository = _FakeAttendanceRepository(
          Failure(const UnauthorizedException()),
        );
        final cache = _FakeDashboardCache(_dashboard);
        final container = _container(
          connected: true,
          repository: repository,
          cache: cache,
        );
        // Keep the provider mounted so its error survives autoDispose.
        final sub = container.listen(attendanceDashboardProvider, (_, _) {});
        addTearDown(sub.close);
        await pumpEventQueue();

        final state = container.read(attendanceDashboardProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<UnauthorizedException>());
      },
    );

    test(
      'completes with an error (never loads forever) offline with no cache',
      () async {
        final repository = _FakeAttendanceRepository(
          Failure(const NetworkException()),
        );
        final cache = _FakeDashboardCache();
        final container = _container(
          connected: false,
          repository: repository,
          cache: cache,
        );
        // Keep the provider mounted so its error survives autoDispose.
        final sub = container.listen(attendanceDashboardProvider, (_, _) {});
        addTearDown(sub.close);

        // Proves the load resolves to a surfaced error instead of spinning
        // forever — the screen can show a retry, never an endless spinner.
        await expectLater(
          container.read(attendanceDashboardProvider.future),
          throwsA(isA<NetworkException>()),
        );
        final state = container.read(attendanceDashboardProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isA<NetworkException>());
      },
    );

    test(
      'never renders another user\'s cached snapshot offline (shows empty '
      'state instead)',
      () async {
        // Only user 7 has a cached snapshot...
        final repository = _FakeAttendanceRepository(
          Failure(const NetworkException()),
        );
        final cache = _FakeDashboardCache(_dashboard);
        // ...but user 8 is the one signed in and offline.
        final container = _container(
          connected: false,
          repository: repository,
          cache: cache,
          userId: 8,
        );
        final sub = container.listen(attendanceDashboardProvider, (_, _) {});
        addTearDown(sub.close);

        // Account 8 must see a surfaced "offline data unavailable" error, never
        // account 7's cached attendance.
        await expectLater(
          container.read(attendanceDashboardProvider.future),
          throwsA(isA<NetworkException>()),
        );
      },
    );
  });
}
