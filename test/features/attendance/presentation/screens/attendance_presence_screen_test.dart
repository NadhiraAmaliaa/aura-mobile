import 'dart:async';

import 'package:aura_mobile/core/location/location_result.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/data/sync/attendance_sync_service.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_locations_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_queue_controller.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/automatic_time_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/current_location_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/current_location_state.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_attendance_date_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_time_status_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/screens/attendance_presence_screen.dart';
import 'package:aura_mobile/features/attendance/presentation/widgets/attendance_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Monday with a check-in and a check-out, coordinates as the API sends them.
const _today = AttendanceTodayModel(
  date: '2026-07-20',
  isWorkingDay: true,
  workHours: WorkHoursModel(start: '08:00', end: '17:00'),
  attendance: AttendanceModel(
    id: 4,
    checkInTime: '07:37',
    checkOutTime: '17:05',
    checkInLatitude: '-6.8516719',
    checkInLongitude: '107.5831051',
    checkOutLatitude: '-6.8516843',
    checkOutLongitude: '107.5831145',
    status: 'present',
    statusLabel: 'Hadir',
    workMode: 'wfo',
    workModeLabel: 'WFO',
  ),
);

/// The same Monday before anything was recorded.
const _todayEmpty = AttendanceTodayModel(
  date: '2026-07-20',
  isWorkingDay: true,
  workHours: WorkHoursModel(start: '08:00', end: '17:00'),
);

const _summary = MonthlySummaryModel(
  month: '2026-07',
  hadir: 0,
  terlambat: 0,
  izin: 0,
  sakit: 0,
  dinas: 0,
  tidakAbsen: 0,
);

const _position = GeoPosition(
  latitude: -6.8516719,
  longitude: 107.5831051,
  accuracy: 5,
);

class _Dashboard extends AttendanceDashboardNotifier {
  _Dashboard(this.today);

  /// `null` keeps the dashboard loading.
  final AttendanceTodayModel? today;

  @override
  Future<AttendanceDashboardModel> build() {
    final today = this.today;
    if (today == null) return Completer<AttendanceDashboardModel>().future;
    return Future.value(
      AttendanceDashboardModel(today: today, summary: _summary),
    );
  }
}

/// A resolved fix. [acquireFresh] never completes, so a started capture stays
/// in progress for the test to inspect.
class _Location extends CurrentLocation {
  @override
  CurrentLocationState build() => const CurrentLocationState.success(_position);

  @override
  Future<void> fetch() async {}

  @override
  Future<GeoPosition?> acquireFresh() => Completer<GeoPosition?>().future;
}

/// The failure the location service reports for a mocked fix.
const _mockedFix = CurrentLocationState.failure(
  LocationFailureKind.mocked,
  'Lokasi palsu terdeteksi.',
);

/// A fix that is reported as mocked: already on the fetch made when the page
/// opens when [onOpen], otherwise only on the fresh fix taken by a capture.
class _MockedLocation extends CurrentLocation {
  _MockedLocation({required this.onOpen});

  final bool onOpen;

  @override
  CurrentLocationState build() => const CurrentLocationState.success(_position);

  @override
  Future<void> fetch() async {
    if (onOpen) state = _mockedFix;
  }

  @override
  Future<GeoPosition?> acquireFresh() async {
    state = _mockedFix;
    return null;
  }
}

class _AutomaticTime extends AutomaticTimeStatus {
  @override
  Future<bool?> build() async => true;
}

/// Verified when [ready]; otherwise still verifying (never resolves), which
/// disables the actions without showing the block dialog.
class _TrustedTime extends TrustedTimeStatus {
  _TrustedTime({required this.ready});

  final bool ready;

  @override
  Future<bool> build() => ready ? Future.value(true) : Completer<bool>().future;
}

class _Queue extends AttendanceQueueController {
  @override
  Future<List<AttendanceQueueEntry>> build() async => const [];

  @override
  Future<SyncSummary> flush() async =>
      const SyncSummary(synced: 0, rejected: 0, stillPending: 0);
}

class _Offices extends AttendanceLocations {
  @override
  Future<List<AttendanceLocationModel>> build() async => const [];
}

/// Mounts the real Presensi screen with every provider it reads faked.
///
/// When [routed], the screen is pushed by a [GoRouter] on top of a stand-in
/// "Dashboard" page, as in the app, so it can navigate back.
///
/// Tests run on fuchsia (see `fuchsia` in [main]): the maps plugin has no
/// native view there and renders a text placeholder, so the real [CheckInMap]
/// can be laid out without a platform view.
Future<void> _pumpScreen(
  WidgetTester tester, {
  double width = 393,
  double textScale = 1,
  AttendanceTodayModel? today = _today,
  bool trustedTimeReady = true,
  CurrentLocation Function() location = _Location.new,
  bool routed = false,
}) async {
  // Tall enough that the lazy ListView builds every section.
  tester.view.physicalSize = Size(width, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      attendanceDashboardProvider.overrideWith(() => _Dashboard(today)),
      currentLocationProvider.overrideWith(location),
      automaticTimeStatusProvider.overrideWith(_AutomaticTime.new),
      trustedTimeStatusProvider.overrideWith(
        () => _TrustedTime(ready: trustedTimeReady),
      ),
      trustedAttendanceDateProvider.overrideWithValue(
        const AsyncData('2026-07-20'),
      ),
      attendanceQueueControllerProvider.overrideWith(_Queue.new),
      attendanceLocationsProvider.overrideWith(_Offices.new),
    ],
  );
  addTearDown(container.dispose);

  Widget scaled(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  );

  final Widget app;
  if (routed) {
    final router = GoRouter(
      initialLocation: '/presensi',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Dashboard')),
          routes: [
            GoRoute(
              path: 'presensi',
              builder: (_, _) => const AttendancePresenceScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    app = MaterialApp.router(builder: scaled, routerConfig: router);
  } else {
    app = MaterialApp(builder: scaled, home: const AttendancePresenceScreen());
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: app),
  );
  // Resolve the async providers. The live clock ticks every second and a
  // loading spinner never settles, so pump explicitly instead of settling.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  final fuchsia = TargetPlatformVariant.only(TargetPlatform.fuchsia);

  /// The Check In (0) or Check Out (1) action.
  FilledButton action(WidgetTester tester, int index) =>
      tester.widget<FilledButton>(find.byType(FilledButton).at(index));

  /// The rendered surface (fill and elevation) of the Check In (0) or Check
  /// Out (1) action.
  Material surface(WidgetTester tester, int index) => tester.widget<Material>(
    find
        .descendant(
          of: find.byType(FilledButton).at(index),
          matching: find.byType(Material),
        )
        .first,
  );

  testWidgets('keeps the map full width and 260dp tall under the AppBar', (
    tester,
  ) async {
    await _pumpScreen(tester);

    final map = tester.getRect(find.byType(CheckInMap));
    expect(map.size, const Size(393, 260));
    expect(map.top, tester.getRect(find.byType(AppBar)).bottom);
  }, variant: fuchsia);

  testWidgets('shows the live date and time in the existing format', (
    tester,
  ) async {
    await _pumpScreen(tester);

    // e.g. "Senin 20 Juli 2026, 07:37:05", still from the device clock.
    final dateTime = find.textContaining(
      RegExp(r'^\S+ \d{1,2} \S+ \d{4}, \d{2}:\d{2}:\d{2}$'),
    );
    expect(dateTime, findsOneWidget);

    // Compact card: a 40dp icon circle and 7dp above and below the taller of
    // the circle and the text (54dp when the text fits on one line).
    final card = find
        .ancestor(of: dateTime, matching: find.byType(DecoratedBox))
        .first;
    final circle = find
        .ancestor(
          of: find.byIcon(Icons.calendar_month_rounded),
          matching: find.byType(DecoratedBox),
        )
        .first;
    expect(tester.getSize(circle), const Size(40, 40));
    final content = tester.getSize(dateTime).height;
    expect(
      tester.getSize(card).height,
      closeTo((content > 40 ? content : 40) + 14, 0.5),
    );
  }, variant: fuchsia);

  testWidgets('keeps the Koordinat Anda debug card above the actions', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.text('Koordinat Anda'), findsOneWidget);
    expect(find.text('-6.8516719, 107.5831051'), findsOneWidget);
    expect(find.byTooltip('Perbarui lokasi'), findsOneWidget);
    expect(
      tester.getRect(find.text('Koordinat Anda')).bottom,
      lessThan(tester.getRect(find.text('Check In')).top),
    );
  }, variant: fuchsia);

  group('history table', () {
    testWidgets("lists today's records under the five columns", (tester) async {
      await _pumpScreen(tester);

      for (final header in ['No', 'Jam', 'Latitude', 'Longitude', 'Status']) {
        expect(find.text(header), findsOneWidget);
      }
      for (final value in [
        '07:37',
        '-6.8516719',
        '107.5831051',
        '17:05',
        '-6.8516843',
        '107.5831145',
      ]) {
        expect(find.text(value), findsOneWidget);
      }

      // Row order is unchanged: 1 Masuk, then 2 Pulang.
      final masuk = tester.getRect(find.text('Masuk'));
      final pulang = tester.getRect(find.text('Pulang'));
      expect(masuk.top, lessThan(pulang.top));
      expect(tester.getCenter(find.text('1')).dy, closeTo(masuk.center.dy, 1));
      expect(tester.getCenter(find.text('2')).dy, closeTo(pulang.center.dy, 1));

      // Cells line up with their column across rows and under the header
      // (the header label sits beside a 14dp icon).
      expect(
        tester.getCenter(find.text('07:37')).dx,
        closeTo(tester.getCenter(find.text('17:05')).dx, 0.5),
      );
      expect(
        tester.getCenter(find.text('Latitude')).dx,
        closeTo(tester.getCenter(find.text('-6.8516719')).dx, 10),
      );
    }, variant: fuchsia);

    testWidgets('shows the empty state under the header without a record', (
      tester,
    ) async {
      await _pumpScreen(tester, today: _todayEmpty);

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Belum ada absensi hari ini.'), findsOneWidget);
      expect(find.text('Masuk'), findsNothing);
    }, variant: fuchsia);

    testWidgets('shows a spinner while the dashboard loads', (tester) async {
      await _pumpScreen(tester, today: null);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Belum ada absensi hari ini.'), findsNothing);
    }, variant: fuchsia);
  });

  group('attendance actions', () {
    testWidgets(
      'are enabled, flat orange / red, once trusted time is ready',
      (tester) async {
        await _pumpScreen(tester);

        const fills = [Color(0xFFF9A431), Color(0xFFE84A4D)];
        for (var i = 0; i < 2; i++) {
          expect(action(tester, i).onPressed, isNotNull);
          expect(surface(tester, i).color, fills[i]);
          expect(surface(tester, i).elevation, 0, reason: 'no glow or shadow');
        }
      },
      variant: fuchsia,
    );

    testWidgets('are muted and flat while trusted time is still verifying', (
      tester,
    ) async {
      await _pumpScreen(tester);
      final enabled = [for (var i = 0; i < 2; i++) surface(tester, i).color!];

      await tester.pumpWidget(const SizedBox());
      await _pumpScreen(tester, trustedTimeReady: false);

      for (var i = 0; i < 2; i++) {
        expect(action(tester, i).onPressed, isNull);
        final disabled = surface(tester, i);
        expect(disabled.elevation, 0);
        // Visibly desaturated, so disabled reads differently from enabled.
        expect(
          HSVColor.fromColor(disabled.color!).saturation,
          lessThan(HSVColor.fromColor(enabled[i]).saturation - 0.2),
        );
      }
    }, variant: fuchsia);

    testWidgets(
      'a started Check In shows a white spinner and disables both',
      (tester) async {
        await _pumpScreen(tester);

        await tester.tap(find.text('Check In'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(find.text('Absen'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final spinner = find.descendant(
          of: find.byType(FilledButton).at(0),
          matching: find.byType(CircularProgressIndicator),
        );
        expect(spinner, findsOneWidget);
        expect(
          tester.widget<CircularProgressIndicator>(spinner).color,
          Colors.white,
        );
        expect(find.text('Check In'), findsNothing);
        for (var i = 0; i < 2; i++) {
          expect(action(tester, i).onPressed, isNull);
        }
      },
      variant: fuchsia,
    );
  });

  group('mock-location block', () {
    const blockTitle = 'Lokasi tidak dapat diverifikasi';

    /// Lets a dialog or page transition finish; the live clock never settles.
    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets(
      'ignores Back and barrier taps, keeps the actions disabled, and returns '
      'to the previous screen after Mengerti',
      (tester) async {
        await _pumpScreen(
          tester,
          routed: true,
          location: () => _MockedLocation(onOpen: true),
        );
        await settle(tester);

        expect(find.text(blockTitle), findsOneWidget);
        for (var i = 0; i < 2; i++) {
          expect(action(tester, i).onPressed, isNull);
        }

        // Android Back (button or gesture) neither closes it nor leaves.
        await tester.binding.handlePopRoute();
        await settle(tester);
        expect(find.text(blockTitle), findsOneWidget);
        expect(find.byType(AttendancePresenceScreen), findsOneWidget);

        // Tapping outside the dialog does nothing either.
        await tester.tapAt(const Offset(5, 5));
        await settle(tester);
        expect(find.text(blockTitle), findsOneWidget);

        await tester.tap(find.text('Mengerti'));
        await settle(tester);

        // Exactly one page back: the screen is gone, the dashboard remains.
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(AttendancePresenceScreen), findsNothing);
        expect(find.text('Dashboard'), findsOneWidget);
      },
      variant: fuchsia,
    );

    testWidgets(
      'a mocked fresh fix during Check In leaves the page exactly once',
      (tester) async {
        await _pumpScreen(
          tester,
          routed: true,
          location: () => _MockedLocation(onOpen: false),
        );

        await tester.tap(find.text('Check In'));
        await settle(tester);
        await tester.tap(find.text('Absen'));
        await settle(tester);

        // The block dialog is shown once; acknowledge every open dialog from
        // the top down, as the user would.
        expect(find.text(blockTitle), findsOneWidget);
        // Bounded, so a dialog that keeps reappearing fails instead of hanging.
        for (var i = 0; i < 3; i++) {
          if (find.text('Mengerti').evaluate().isEmpty) break;
          await tester.tap(find.text('Mengerti').last);
          await settle(tester);
        }
        expect(find.text('Mengerti'), findsNothing);

        expect(find.byType(AttendancePresenceScreen), findsNothing);
        expect(find.text('Dashboard'), findsOneWidget);
      },
      variant: fuchsia,
    );
  });

  group('responsive layout', () {
    for (final width in [320.0, 360.0, 393.0, 430.0]) {
      for (final textScale in [1.0, 1.3, 2.0]) {
        testWidgets('renders without overflow at ${width}dp, x$textScale', (
          tester,
        ) async {
          await _pumpScreen(tester, width: width, textScale: textScale);

          expect(tester.takeException(), isNull);

          // The map is untouched at every size.
          expect(tester.getSize(find.byType(CheckInMap)), Size(width, 260));

          // Both actions stay side by side and equally tall.
          final checkIn = tester.getRect(find.byType(FilledButton).at(0));
          final checkOut = tester.getRect(find.byType(FilledButton).at(1));
          expect(checkIn.top, checkOut.top);
          expect(checkIn.height, checkOut.height);
          expect(checkIn.right, lessThan(checkOut.left));

          // Table values are never clipped: each paragraph fits its full text.
          for (final value in ['07:37', '-6.8516719', '107.5831145']) {
            final paragraph = tester.renderObject<RenderParagraph>(
              find.text(value),
            );
            expect(
              paragraph.size.width,
              greaterThanOrEqualTo(
                paragraph.getMaxIntrinsicWidth(double.infinity) - 0.01,
              ),
              reason: '"$value" must be shown in full',
            );
          }
        }, variant: fuchsia);
      }
    }
  });
}
