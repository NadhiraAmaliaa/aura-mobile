import 'package:aura_mobile/app/bootstrap/offline_bootstrap_provider.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/dashboard_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/local/office_config_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/auth/presentation/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory dashboard cache keyed by user id, so per-user scoping can be
/// asserted.
class _FakeDashboardCache implements DashboardCacheStore {
  final Map<int, AttendanceDashboardModel> byUser = {};

  @override
  Future<AttendanceDashboardModel?> read(int userId) async => byUser[userId];

  @override
  Future<void> save(int userId, AttendanceDashboardModel dashboard) async {
    byUser[userId] = dashboard;
  }
}

/// In-memory office cache (global — shared across users).
class _FakeOfficeCache implements OfficeConfigCacheStore {
  List<AttendanceLocationModel> offices = const [];

  @override
  Future<List<AttendanceLocationModel>> all() async => offices;

  @override
  Future<void> replaceAll(List<AttendanceLocationModel> offices) async {
    this.offices = offices;
  }
}

/// A repository with scripted `dashboard`/`locations` results and call counts.
class _FakeAttendanceRepository implements AttendanceRepository {
  _FakeAttendanceRepository({
    required this.dashboardResult,
    required this.locationsResult,
  });

  ApiResult<AttendanceDashboardModel> dashboardResult;
  ApiResult<List<AttendanceLocationModel>> locationsResult;
  int dashboardCalls = 0;
  int locationsCalls = 0;

  @override
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month}) async {
    dashboardCalls++;
    return dashboardResult;
  }

  @override
  Future<ApiResult<List<AttendanceLocationModel>>> locations() async {
    locationsCalls++;
    return locationsResult;
  }

  @override
  Future<ApiResult<AttendanceHistoryModel>> history({
    int? page,
    int? perPage,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<AttendanceModel>> syncEvent(AttendanceQueueEntry entry) =>
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

const _offices = [
  AttendanceLocationModel(
    id: 1,
    name: 'Kantor Pusat',
    latitude: -6.2,
    longitude: 106.8,
    radius: 100,
  ),
];

ProviderContainer _container({
  required _FakeAttendanceRepository repository,
  required _FakeDashboardCache dashboardCache,
  required _FakeOfficeCache officeCache,
  int? userId = 7,
}) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      currentUserIdProvider.overrideWithValue(userId),
      attendanceRepositoryProvider.overrideWithValue(repository),
      dashboardCacheStoreProvider.overrideWith((ref) async => dashboardCache),
      officeConfigCacheStoreProvider.overrideWith((ref) async => officeCache),
    ],
  );
}

void main() {
  group('OfflineBootstrap', () {
    test('fetches and persists the minimum dataset for the user', () async {
      final repository = _FakeAttendanceRepository(
        dashboardResult: const Success(_dashboard),
        locationsResult: const Success(_offices),
      );
      final dashboardCache = _FakeDashboardCache();
      final officeCache = _FakeOfficeCache();
      final container = _container(
        repository: repository,
        dashboardCache: dashboardCache,
        officeCache: officeCache,
      );

      await container.read(offlineBootstrapProvider.future);

      expect(dashboardCache.byUser[7], _dashboard);
      expect(officeCache.offices, _offices);
      expect(repository.dashboardCalls, 1);
      expect(repository.locationsCalls, 1);
    });

    test('is a no-op fetch when the dataset is already cached', () async {
      final repository = _FakeAttendanceRepository(
        dashboardResult: Failure(const NetworkException()),
        locationsResult: Failure(const NetworkException()),
      );
      final dashboardCache = _FakeDashboardCache()..byUser[7] = _dashboard;
      final officeCache = _FakeOfficeCache()..offices = _offices;
      final container = _container(
        repository: repository,
        dashboardCache: dashboardCache,
        officeCache: officeCache,
      );

      // Resolves ready without any network — an offline cold start.
      await container.read(offlineBootstrapProvider.future);

      expect(repository.dashboardCalls, 0);
      expect(repository.locationsCalls, 0);
    });

    test('surfaces an error when the dashboard fetch fails', () async {
      final repository = _FakeAttendanceRepository(
        dashboardResult: Failure(const NetworkException()),
        locationsResult: const Success(_offices),
      );
      final container = _container(
        repository: repository,
        dashboardCache: _FakeDashboardCache(),
        officeCache: _FakeOfficeCache(),
      );
      final sub = container.listen(offlineBootstrapProvider, (_, _) {});
      addTearDown(sub.close);

      await expectLater(
        container.read(offlineBootstrapProvider.future),
        throwsA(isA<NetworkException>()),
      );
      expect(container.read(offlineBootstrapProvider).hasError, isTrue);
    });

    test('surfaces an error when the office fetch fails', () async {
      final repository = _FakeAttendanceRepository(
        dashboardResult: const Success(_dashboard),
        locationsResult: Failure(const RequestTimeoutException()),
      );
      final container = _container(
        repository: repository,
        dashboardCache: _FakeDashboardCache(),
        officeCache: _FakeOfficeCache(),
      );
      final sub = container.listen(offlineBootstrapProvider, (_, _) {});
      addTearDown(sub.close);

      await expectLater(
        container.read(offlineBootstrapProvider.future),
        throwsA(isA<RequestTimeoutException>()),
      );
    });

    test('is a ready no-op when unauthenticated', () async {
      final repository = _FakeAttendanceRepository(
        dashboardResult: Failure(const NetworkException()),
        locationsResult: Failure(const NetworkException()),
      );
      final container = _container(
        repository: repository,
        dashboardCache: _FakeDashboardCache(),
        officeCache: _FakeOfficeCache(),
        userId: null,
      );

      await container.read(offlineBootstrapProvider.future);

      expect(repository.dashboardCalls, 0);
      expect(repository.locationsCalls, 0);
      expect(container.read(offlineBootstrapProvider).hasValue, isTrue);
    });

    test('retry re-runs and recovers after a transient failure', () async {
      final repository = _FakeAttendanceRepository(
        dashboardResult: Failure(const NetworkException()),
        locationsResult: const Success(_offices),
      );
      final dashboardCache = _FakeDashboardCache();
      final container = _container(
        repository: repository,
        dashboardCache: dashboardCache,
        officeCache: _FakeOfficeCache(),
      );
      final sub = container.listen(offlineBootstrapProvider, (_, _) {});
      addTearDown(sub.close);

      await expectLater(
        container.read(offlineBootstrapProvider.future),
        throwsA(isA<NetworkException>()),
      );

      // Connectivity restored — the next attempt succeeds.
      repository.dashboardResult = const Success(_dashboard);
      await container.read(offlineBootstrapProvider.notifier).retry();

      expect(container.read(offlineBootstrapProvider).hasError, isFalse);
      expect(dashboardCache.byUser[7], _dashboard);
    });
  });
}
