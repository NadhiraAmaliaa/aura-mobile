import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/core/database/database_providers.dart';
import 'package:aura_mobile/core/device/device_time_providers.dart';
import 'package:aura_mobile/core/device/trusted_time_providers.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/core/providers/core_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_queue_controller.dart';
import 'package:aura_mobile/features/auth/presentation/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../post_sync_refresh_test_support.dart';

/// Regression tests for an attendance event that syncs successfully but whose
/// follow-up dashboard refresh (GET /attendance/dashboard) times out.
///
/// Everything from the queue controller down to the HTTP boundary is
/// production code: AttendanceQueueController, AttendanceSyncService,
/// AttendanceRepositoryImpl, the Retrofit AttendanceApi on Dio,
/// AttendanceDashboardNotifier with its cache fallback, and the sqflite queue
/// and dashboard-cache stores (through sqflite_common_ffi). Only the HTTP
/// transport, the trusted clock, connectivity and the signed-in user are faked.
///
/// Each "precondition" test proves the scenario really happened (the backend
/// recorded the event, the refresh really timed out). The other tests assert
/// the behaviour the app should have; a failure there is the bug.

typedef _Scenario = ({
  ProviderContainer container,
  FakeAttendanceBackend backend,
  SteppedTrustedTime clock,
  AttendanceQueueEntry synced,
});

/// Opens Presensi against the production providers: the queue controller is
/// built and the dashboard is loaded (and cached) from [backend]'s first
/// dashboard reply, with a listener keeping it mounted like the open screen.
Future<ProviderContainer> _openPresensi(
  FakeAttendanceBackend backend,
  SteppedTrustedTime clock,
) async {
  final db = await openAppDatabase(
    factory: databaseFactoryFfi,
    path: inMemoryDatabasePath,
  );
  addTearDown(db.close);

  final container = ProviderContainer.test(
    // A failed load settles at once instead of retrying. The cache-fallback
    // path under test never throws, so this does not change its outcome.
    retry: (_, _) => null,
    overrides: [
      currentUserIdProvider.overrideWithValue(scenarioUserId),
      appDatabaseProvider.overrideWith((ref) async => db),
      dioProvider.overrideWithValue(dioFor(backend)),
      connectivityProvider.overrideWithValue(OnlineConnectivity()),
      deviceTimeSettingsProvider.overrideWithValue(
        const AutomaticClockSettings(),
      ),
      trustedTimeServiceProvider.overrideWith((ref) async => clock),
    ],
  );
  container.listen(attendanceDashboardProvider, (_, _) {});
  await container.read(attendanceQueueControllerProvider.future);
  await container.read(attendanceDashboardProvider.future);
  return container;
}

/// Captures [type] as the Presensi screen does for a WFH action: the fresh
/// fix's coordinates, no office, and the dashboard's current `today` snapshot
/// (the screen's `_todaySnapshot()`).
Future<AttendanceQueueEntry> _capture(
  ProviderContainer container,
  AttendanceEventType type,
) {
  final today = switch (container.read(attendanceDashboardProvider)) {
    AsyncData(:final value) => value.today,
    _ => null,
  };
  return container
      .read(attendanceQueueControllerProvider.notifier)
      .capture(
        type: type,
        workMode: type == AttendanceEventType.checkIn ? 'wfh' : null,
        latitude: scenarioLatitude,
        longitude: scenarioLongitude,
        today: today,
      );
}

/// Presensi was opened before today's check-in (the dashboard loaded and was
/// cached with no record), the 08:00 WFH Check In synced and the backend
/// returned the created record, then the follow-up dashboard refresh timed out.
Future<_Scenario> _checkInSyncedThenRefreshTimesOut() async {
  final backend = FakeAttendanceBackend()
    ..dashboardReplies.addAll([dashboardJson(), null])
    ..checkInRecord = attendanceRecordJson();
  final clock = SteppedTrustedTime(scenarioAt(7, 55));
  final container = await _openPresensi(backend, clock);

  clock.instant = scenarioAt(8);
  final synced = await _capture(container, AttendanceEventType.checkIn);
  // capture() invalidated the dashboard; let that refresh run to completion.
  await container.read(attendanceDashboardProvider.future);

  return (container: container, backend: backend, clock: clock, synced: synced);
}

/// Presensi was opened after the 08:00 check-in (cached with that record), the
/// 17:00 Check Out synced and the backend returned the record with
/// `check_out_time` 17:00, then the follow-up dashboard refresh timed out.
Future<_Scenario> _checkOutSyncedThenRefreshTimesOut() async {
  final backend = FakeAttendanceBackend()
    ..dashboardReplies.addAll([
      dashboardJson(attendance: attendanceRecordJson()),
      null,
    ])
    ..checkOutRecord = attendanceRecordJson(checkOutTime: '17:00');
  final clock = SteppedTrustedTime(scenarioAt(16, 55));
  final container = await _openPresensi(backend, clock);

  clock.instant = scenarioAt(17);
  final synced = await _capture(container, AttendanceEventType.checkOut);
  // capture() invalidated the dashboard; let that refresh run to completion.
  await container.read(attendanceDashboardProvider.future);

  return (container: container, backend: backend, clock: clock, synced: synced);
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('Check In synced, then the dashboard refresh times out', () {
    test(
      'precondition: the backend recorded the check-in and the refresh timed '
      'out',
      () async {
        final s = await _checkInSyncedThenRefreshTimesOut();

        expect(s.synced.status, QueuedEventStatus.synced);
        expect(s.backend.calls, [
          'GET /attendance/dashboard',
          'POST /attendance/check-in',
          'GET /attendance/dashboard',
        ]);
        expect(
          s.backend.postedEvents.single['client_event_id'],
          s.synced.clientEventId,
        );
        expect(s.backend.dashboardTimeouts, 1);
        // The synced event no longer counts as pending, and the failed refresh
        // did not surface as an error: the screen keeps rendering data.
        expect(s.container.read(pendingAttendanceCountProvider), 0);
        expect(
          s.container.read(attendanceDashboardProvider),
          isA<AsyncData<AttendanceDashboardModel>>(),
        );
      },
    );

    test("the dashboard reflects the backend's recorded check-in", () async {
      final s = await _checkInSyncedThenRefreshTimesOut();

      final today = s.container
          .read(attendanceDashboardProvider)
          .requireValue
          .today;
      expect(
        today.attendance?.checkInTime,
        '08:00',
        reason:
            'The backend recorded the 08:00 check-in and returned it; the '
            'dashboard must not fall back to the pre-check-in snapshot.',
      );
    });

    test('a later Check Out is not blocked as "not checked in"', () async {
      final s = await _checkInSyncedThenRefreshTimesOut();
      s.backend
        ..checkOutRecord = attendanceRecordJson(checkOutTime: '17:00')
        ..dashboardReplies.add(
          dashboardJson(
            attendance: attendanceRecordJson(checkOutTime: '17:00'),
          ),
        );
      s.clock.instant = scenarioAt(17);

      await expectLater(
        _capture(s.container, AttendanceEventType.checkOut),
        completion(
          isA<AttendanceQueueEntry>().having(
            (entry) => entry.status,
            'status',
            QueuedEventStatus.synced,
          ),
        ),
        reason:
            'The backend already holds the 08:00 check-in, so a 17:00 Check '
            'Out must reach it instead of being rejected locally.',
      );
    });
  });

  group('Check Out synced, then the dashboard refresh times out', () {
    test(
      'precondition: the backend recorded the check-out and the refresh timed '
      'out',
      () async {
        final s = await _checkOutSyncedThenRefreshTimesOut();

        expect(s.synced.status, QueuedEventStatus.synced);
        expect(s.backend.calls, [
          'GET /attendance/dashboard',
          'POST /attendance/check-out',
          'GET /attendance/dashboard',
        ]);
        expect(
          s.backend.postedEvents.single['client_event_id'],
          s.synced.clientEventId,
        );
        expect(s.backend.dashboardTimeouts, 1);
        expect(s.container.read(pendingAttendanceCountProvider), 0);
        expect(
          s.container.read(pendingAttendanceActionsProvider).hasCheckOut,
          isFalse,
        );
        expect(
          s.container.read(attendanceDashboardProvider),
          isA<AsyncData<AttendanceDashboardModel>>(),
        );
      },
    );

    test("the dashboard shows the backend's recorded check-out", () async {
      final s = await _checkOutSyncedThenRefreshTimesOut();

      final today = s.container
          .read(attendanceDashboardProvider)
          .requireValue
          .today;
      expect(
        today.attendance?.checkOutTime,
        '17:00',
        reason:
            'The backend recorded the 17:00 check-out and returned it; the '
            'dashboard must not keep showing the pre-check-out snapshot.',
      );
    });

    test(
      'the on-device dashboard cache holds the recorded check-out',
      () async {
        final s = await _checkOutSyncedThenRefreshTimesOut();

        final cache = await s.container.read(
          dashboardCacheStoreProvider.future,
        );
        final cached = await cache.read(scenarioUserId);
        expect(
          cached?.today.attendance?.checkOutTime,
          '17:00',
          reason:
              'This cached snapshot is what the next failed refresh or an '
              'offline cold start renders.',
        );
      },
    );
  });
}
