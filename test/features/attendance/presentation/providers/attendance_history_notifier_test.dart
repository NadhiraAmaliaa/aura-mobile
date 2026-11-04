import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/attendance_month.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_history_month_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_history_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_attendance_date_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../history_test_support.dart';

ProviderContainer _container(
  FakeHistoryRepository repository, {
  List<Override> overrides = const [],
}) => ProviderContainer.test(
  // Settle failures to a stable AsyncError instead of retrying.
  retry: (_, _) => null,
  overrides: [
    attendanceRepositoryProvider.overrideWithValue(repository),
    ...overrides,
  ],
);

/// Keeps [provider] mounted for the test (it is auto-disposed otherwise).
void _keepAlive(
  ProviderContainer container,
  ProviderListenable<Object?> provider,
) {
  final sub = container.listen(provider, (_, _) {});
  addTearDown(sub.close);
}

List<String?> _dates(ProviderContainer container, String month) => [
  for (final item
      in container.read(attendanceHistoryProvider(month)).requireValue.items)
    item.attendanceDate,
];

class _Dashboard extends AttendanceDashboardNotifier {
  @override
  Future<AttendanceDashboardModel> build() async =>
      const AttendanceDashboardModel(
        today: AttendanceTodayModel(
          date: '2026-08-20',
          isWorkingDay: true,
          workHours: WorkHoursModel(),
        ),
        summary: MonthlySummaryModel(month: '2026-08'),
      );
}

void main() {
  group('AttendanceHistoryNotifier', () {
    test('loads the first page of the requested month', () async {
      final repository = FakeHistoryRepository(
        recordsByMonth: {'2026-09': monthRecords('2026-09', 3)},
      );
      final container = _container(repository);
      _keepAlive(container, attendanceHistoryProvider('2026-09'));

      final state = await container.read(
        attendanceHistoryProvider('2026-09').future,
      );

      expect(repository.historyCalls, [(month: '2026-09', page: 1)]);
      expect(state.items, hasLength(3));
      expect(state.pagination?.total, 3);
      expect(state.hasMore, isFalse);
    });

    test('appends the next page of the same month', () async {
      final repository = FakeHistoryRepository(
        recordsByMonth: {'2026-09': monthRecords('2026-09', 20)},
      );
      final container = _container(repository);
      _keepAlive(container, attendanceHistoryProvider('2026-09'));
      await container.read(attendanceHistoryProvider('2026-09').future);

      await container
          .read(attendanceHistoryProvider('2026-09').notifier)
          .loadMore();

      final state = container
          .read(attendanceHistoryProvider('2026-09'))
          .requireValue;
      expect(repository.historyCalls, [
        (month: '2026-09', page: 1),
        (month: '2026-09', page: 2),
      ]);
      expect(state.items, hasLength(20));
      expect(state.hasMore, isFalse);
      expect(_dates(container, '2026-09').first, '2026-09-20');
      expect(_dates(container, '2026-09').last, '2026-09-01');

      // Nothing left to fetch.
      await container
          .read(attendanceHistoryProvider('2026-09').notifier)
          .loadMore();
      expect(repository.historyCalls, hasLength(2));
    });

    test(
      'a late page of the previous month never reaches the new month',
      () async {
        final repository = FakeHistoryRepository(
          recordsByMonth: {
            '2026-09': monthRecords('2026-09', 20),
            '2026-08': monthRecords('2026-08', 2),
          },
        )..hold = true;
        final container = _container(repository);

        // September is shown and its second page is in flight...
        final september = container.listen(
          attendanceHistoryProvider('2026-09'),
          (_, _) {},
        );
        repository.releaseHistory('2026-09', 1);
        await container.read(attendanceHistoryProvider('2026-09').future);
        final pending = container
            .read(attendanceHistoryProvider('2026-09').notifier)
            .loadMore();

        // ...when the user switches to August: September is no longer watched.
        _keepAlive(container, attendanceHistoryProvider('2026-08'));
        september.close();
        await pumpEventQueue();
        repository.releaseHistory('2026-08', 1);
        await container.read(attendanceHistoryProvider('2026-08').future);

        // The stale September page arrives last and is dropped without error.
        repository.releaseHistory('2026-09', 2);
        await pending;

        expect(_dates(container, '2026-08'), ['2026-08-02', '2026-08-01']);
      },
    );

    test('a refresh supersedes an in-flight next page', () async {
      final repository = FakeHistoryRepository(
        recordsByMonth: {'2026-09': monthRecords('2026-09', 20)},
      )..hold = true;
      final container = _container(repository);
      _keepAlive(container, attendanceHistoryProvider('2026-09'));
      final notifier = container.read(
        attendanceHistoryProvider('2026-09').notifier,
      );
      repository.releaseHistory('2026-09', 1);
      await container.read(attendanceHistoryProvider('2026-09').future);

      final loadMore = notifier.loadMore();
      final refresh = notifier.refresh();

      // The old page 2 lands after the refresh started: it must not append.
      repository.releaseHistory('2026-09', 2);
      await loadMore;
      expect(
        container.read(attendanceHistoryProvider('2026-09')).isLoading,
        isTrue,
      );

      repository.releaseHistory('2026-09', 1);
      await refresh;
      final state = container
          .read(attendanceHistoryProvider('2026-09'))
          .requireValue;
      expect(state.items, hasLength(15));
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
    });

    test('does not request a next page while a refresh is loading', () async {
      final repository = FakeHistoryRepository(
        recordsByMonth: {'2026-09': monthRecords('2026-09', 20)},
      )..hold = true;
      final container = _container(repository);
      _keepAlive(container, attendanceHistoryProvider('2026-09'));
      final notifier = container.read(
        attendanceHistoryProvider('2026-09').notifier,
      );
      repository.releaseHistory('2026-09', 1);
      await container.read(attendanceHistoryProvider('2026-09').future);

      final refresh = notifier.refresh();
      // The loading state still carries the old list, which has more pages.
      await notifier.loadMore();
      expect(repository.historyCalls.where((call) => call.page == 2), isEmpty);

      repository.releaseHistory('2026-09', 1);
      await refresh;
      expect(
        container.read(attendanceHistoryProvider('2026-09')).requireValue.items,
        hasLength(15),
      );
    });

    test('an older refresh finishing last is dropped', () async {
      final repository = FakeHistoryRepository(
        recordsByMonth: {'2026-09': monthRecords('2026-09', 3)},
      )..hold = true;
      final container = _container(repository);
      _keepAlive(container, attendanceHistoryProvider('2026-09'));
      final notifier = container.read(
        attendanceHistoryProvider('2026-09').notifier,
      );
      repository.releaseHistory('2026-09', 1);
      await container.read(attendanceHistoryProvider('2026-09').future);

      final older = notifier.refresh();
      final newer = notifier.refresh();
      repository.releaseHistory(
        '2026-09',
        1,
        repository.historyPage('2026-09', 1),
      ); // older call
      repository.releaseHistory(
        '2026-09',
        1,
        Success(
          AttendanceHistoryModel(
            items: [historyRecord('2026-09-04')],
            pagination: const PaginationModel(total: 1),
          ),
        ),
      ); // newer call
      await Future.wait([older, newer]);

      expect(_dates(container, '2026-09'), ['2026-09-04']);
    });

    test(
      'a failed next page keeps the records and waits for a retry',
      () async {
        final repository = FakeHistoryRepository(
          recordsByMonth: {'2026-09': monthRecords('2026-09', 20)},
        )..historyFailures['2026-09#2'] = const NetworkException();
        final container = _container(repository);
        _keepAlive(container, attendanceHistoryProvider('2026-09'));
        final notifier = container.read(
          attendanceHistoryProvider('2026-09').notifier,
        );
        await container.read(attendanceHistoryProvider('2026-09').future);

        await notifier.loadMore();
        var state = container
            .read(attendanceHistoryProvider('2026-09'))
            .requireValue;
        expect(state.items, hasLength(15));
        expect(state.loadMoreFailed, isTrue);
        expect(state.canLoadMore, isFalse);

        // Scrolling again does not hammer the failing page.
        await notifier.loadMore();
        expect(repository.historyCalls, hasLength(2));

        repository.historyFailures.clear();
        await notifier.retryLoadMore();
        state = container
            .read(attendanceHistoryProvider('2026-09'))
            .requireValue;
        expect(state.items, hasLength(20));
        expect(state.loadMoreFailed, isFalse);
        expect(repository.historyCalls.last, (month: '2026-09', page: 2));
      },
    );

    test('rejects a page holding records of another month', () async {
      final repository = FakeHistoryRepository(
        recordsByMonth: {
          // A backend ignoring `month` would answer with mixed months.
          '2026-09': [historyRecord('2026-09-01'), historyRecord('2026-08-31')],
        },
      );
      final container = _container(repository);
      _keepAlive(container, attendanceHistoryProvider('2026-09'));

      await expectLater(
        container.read(attendanceHistoryProvider('2026-09').future),
        throwsA(same(attendanceMonthMismatch)),
      );
    });

    test('surfaces a first-page failure as an error', () async {
      final repository = FakeHistoryRepository()
        ..historyFailures['2026-09#1'] = const NetworkException();
      final container = _container(repository);
      _keepAlive(container, attendanceHistoryProvider('2026-09'));

      await expectLater(
        container.read(attendanceHistoryProvider('2026-09').future),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('attendanceMonthSummaryProvider', () {
    test('reads the recap of the requested month from the dashboard', () async {
      const recap = MonthlySummaryModel(
        month: '2026-09',
        hadir: 14,
        tidakAbsen: 2,
      );
      final repository = FakeHistoryRepository(
        summaryByMonth: {'2026-09': recap},
      );
      final container = _container(repository);
      _keepAlive(container, attendanceMonthSummaryProvider('2026-09'));

      final summary = await container.read(
        attendanceMonthSummaryProvider('2026-09').future,
      );

      expect(repository.dashboardCalls, ['2026-09']);
      expect(summary, recap);
    });

    test('rejects a recap for a different month', () async {
      final repository = FakeHistoryRepository(
        summaryByMonth: {
          '2026-09': const MonthlySummaryModel(month: '2026-10'),
        },
      );
      final container = _container(repository);
      _keepAlive(container, attendanceMonthSummaryProvider('2026-09'));

      await expectLater(
        container.read(attendanceMonthSummaryProvider('2026-09').future),
        throwsA(same(attendanceMonthMismatch)),
      );
    });
  });

  group('selected month', () {
    test('starts at the trusted month and can be switched', () {
      final container = _container(
        FakeHistoryRepository(),
        overrides: [
          trustedAttendanceDateProvider.overrideWithValue(
            const AsyncData('2026-09-18'),
          ),
        ],
      );
      // Mounted by the dashboard below the history screen.
      _keepAlive(container, trustedAttendanceDateProvider);
      _keepAlive(container, attendanceHistoryMonthProvider);

      expect(container.read(attendanceHistoryMonthProvider), '2026-09');

      container.read(attendanceHistoryMonthProvider.notifier).select('2026-07');
      expect(container.read(attendanceHistoryMonthProvider), '2026-07');
    });

    test('falls back to the live dashboard month', () async {
      final container = _container(
        FakeHistoryRepository(),
        overrides: [attendanceDashboardProvider.overrideWith(_Dashboard.new)],
      );
      _keepAlive(container, attendanceDashboardProvider);
      await container.read(attendanceDashboardProvider.future);

      expect(container.read(attendanceHistoryLatestMonthProvider), '2026-08');
    });

    test('never starts a dashboard fetch of its own', () {
      final repository = FakeHistoryRepository();
      final container = _container(repository);

      expect(
        container.read(attendanceHistoryLatestMonthProvider),
        attendanceMonthKey(DateTime.now()),
      );
      expect(container.exists(attendanceDashboardProvider), isFalse);
      expect(repository.dashboardCalls, isEmpty);
    });
  });
}
