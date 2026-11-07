import 'package:aura_mobile/core/device/device_time_providers.dart';
import 'package:aura_mobile/core/device/trusted_time_providers.dart';
import 'package:aura_mobile/core/location/location_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/core/providers/core_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_locations_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/automatic_time_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/current_location_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/current_location_state.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_attendance_date_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_time_status_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/screens/attendance_presence_screen.dart';
import 'package:aura_mobile/features/auth/presentation/providers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../post_sync_refresh_test_support.dart';

/// Regression tests, through the real Presensi screen, for an attendance event
/// that syncs successfully but whose follow-up dashboard refresh times out.
///
/// The screen runs on the production dashboard notifier (with its cache
/// fallback), queue controller, sync service, repository and Retrofit client,
/// with [FakeAttendanceBackend] at the HTTP boundary. Only device seams
/// (location, clock settings, trusted time, connectivity) and the stores'
/// storage (in memory; sqflite cannot run inside the widget tester's fake-async
/// zone) are faked.

const _position = GeoPosition(
  latitude: scenarioLatitude,
  longitude: scenarioLongitude,
  accuracy: 5,
);

/// A resolved, non-mocked fix; a capture's fresh fix resolves at once.
class _Location extends CurrentLocation {
  @override
  CurrentLocationState build() => const CurrentLocationState.success(_position);

  @override
  Future<void> fetch() async {}

  @override
  Future<GeoPosition?> acquireFresh() async => _position;
}

class _AutomaticTime extends AutomaticTimeStatus {
  @override
  Future<bool?> build() async => true;
}

class _TrustedTimeReady extends TrustedTimeStatus {
  @override
  Future<bool> build() async => true;
}

class _NoOffices extends AttendanceLocations {
  @override
  Future<List<AttendanceLocationModel>> build() async => const [];
}

/// Mounts the real Presensi screen with [backend] behind the production
/// attendance providers and [clock] as the trusted time.
///
/// Tests run on fuchsia (see `fuchsia` in [main]): the maps plugin has no
/// native view there and renders a text placeholder.
Future<void> _openPresensi(
  WidgetTester tester,
  FakeAttendanceBackend backend,
  SteppedTrustedTime clock,
) async {
  // Tall enough that the lazy ListView builds every section.
  tester.view.physicalSize = const Size(393, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      currentUserIdProvider.overrideWithValue(scenarioUserId),
      dioProvider.overrideWithValue(dioFor(backend)),
      connectivityProvider.overrideWithValue(OnlineConnectivity()),
      attendanceQueueStoreProvider.overrideWith(
        (ref) async => MemoryAttendanceQueueStore(),
      ),
      dashboardCacheStoreProvider.overrideWith(
        (ref) async => MemoryDashboardCacheStore(),
      ),
      deviceTimeSettingsProvider.overrideWithValue(
        const AutomaticClockSettings(),
      ),
      trustedTimeServiceProvider.overrideWith((ref) async => clock),
      currentLocationProvider.overrideWith(_Location.new),
      automaticTimeStatusProvider.overrideWith(_AutomaticTime.new),
      trustedTimeStatusProvider.overrideWith(_TrustedTimeReady.new),
      trustedAttendanceDateProvider.overrideWithValue(
        AsyncData(scenarioDayKey),
      ),
      attendanceLocationsProvider.overrideWith(_NoOffices.new),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AttendancePresenceScreen()),
    ),
  );
  await _pumpFrames(tester);
}

/// Advances one second of frames: enough for the scripted HTTP round trips,
/// sheet and dialog transitions and provider rebuilds. The live clock ticks
/// every second, so the screen never settles on its own.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final fuchsia = TargetPlatformVariant.only(TargetPlatform.fuchsia);

  Finder checkInButton() => find.byType(FilledButton).at(0);
  Finder checkOutButton() => find.byType(FilledButton).at(1);

  testWidgets(
    'after a synced Check In whose dashboard refresh timed out, Check Out is '
    'not blocked',
    (tester) async {
      final backend = FakeAttendanceBackend()
        ..dashboardReplies.addAll([
          dashboardJson(),
          null,
          dashboardJson(
            attendance: attendanceRecordJson(checkOutTime: '17:00'),
          ),
        ])
        ..checkInRecord = attendanceRecordJson()
        ..checkOutRecord = attendanceRecordJson(checkOutTime: '17:00');
      final clock = SteppedTrustedTime(scenarioAt(8));
      await _openPresensi(tester, backend, clock);

      // Check In as WFH through the type sheet.
      await tester.tap(checkInButton());
      await _pumpFrames(tester);
      await tester.tap(find.text('WFH'));
      await tester.pump();
      await tester.tap(find.text('Absen'));
      await _pumpFrames(tester);

      // Precondition: the backend recorded it and the refresh timed out.
      expect(find.text('Check In berhasil.'), findsOneWidget);
      expect(backend.calls, [
        'GET /attendance/dashboard',
        'POST /attendance/check-in',
        'GET /attendance/dashboard',
      ]);
      expect(backend.dashboardTimeouts, 1);

      clock.instant = scenarioAt(17);
      await tester.tap(checkOutButton());
      await _pumpFrames(tester);

      expect(
        find.text('Anda harus Check In terlebih dahulu sebelum Check Out.'),
        findsNothing,
        reason:
            'The backend already holds the 08:00 check-in; Check Out must not '
            'be blocked as "not checked in".',
      );
      expect(backend.calls, contains('POST /attendance/check-out'));
    },
    variant: fuchsia,
  );

  testWidgets(
    'after a synced Check Out whose dashboard refresh timed out, the history '
    'lists the check-out',
    (tester) async {
      final backend = FakeAttendanceBackend()
        ..dashboardReplies.addAll([
          dashboardJson(attendance: attendanceRecordJson()),
          null,
        ])
        ..checkOutRecord = attendanceRecordJson(checkOutTime: '17:00');
      final clock = SteppedTrustedTime(scenarioAt(17));
      await _openPresensi(tester, backend, clock);

      // Precondition: today's check-in is on screen before the check-out.
      expect(find.text('Masuk'), findsOneWidget);

      await tester.tap(checkOutButton());
      await _pumpFrames(tester);

      // Precondition: the backend recorded it and the refresh timed out.
      expect(find.text('Check Out berhasil.'), findsOneWidget);
      expect(backend.calls, [
        'GET /attendance/dashboard',
        'POST /attendance/check-out',
        'GET /attendance/dashboard',
      ]);
      expect(backend.dashboardTimeouts, 1);

      expect(
        find.text('Pulang'),
        findsOneWidget,
        reason:
            'The backend recorded the 17:00 check-out; today\'s history must '
            'list it after "Check Out berhasil."',
      );
    },
    variant: fuchsia,
  );
}
