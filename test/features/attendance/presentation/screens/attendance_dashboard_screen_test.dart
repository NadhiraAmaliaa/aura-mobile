import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_attendance_date_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Monday's snapshot: checked in at 07:37, working hours 08:00 - 17:00.
const _monday = AttendanceTodayModel(
  date: '2026-07-20',
  isWorkingDay: true,
  workHours: WorkHoursModel(start: '08:00', end: '17:00'),
  attendance: AttendanceModel(
    id: 4,
    checkInTime: '07:37',
    checkOutTime: '17:05',
    status: 'present',
    statusLabel: 'Hadir',
    workMode: 'wfo',
    workModeLabel: 'WFO',
  ),
);

/// Sunday's snapshot: a non-working day with no working hours or attendance.
const _sunday = AttendanceTodayModel(
  date: '2026-07-19',
  isWorkingDay: false,
  workHours: WorkHoursModel(),
);

/// Distinct counts so each summary tile can be told apart.
const _summary = MonthlySummaryModel(
  month: '2026-07',
  hadir: 14,
  terlambat: 1,
  izin: 2,
  sakit: 3,
  dinas: 4,
  tidakAbsen: 5,
);

class _Dashboard extends AttendanceDashboardNotifier {
  _Dashboard(this.today);

  final AttendanceTodayModel today;

  @override
  Future<AttendanceDashboardModel> build() async =>
      AttendanceDashboardModel(today: today, summary: _summary);
}

ProviderContainer _container(
  AttendanceTodayModel today, {
  required String? currentDate,
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      attendanceDashboardProvider.overrideWith(() => _Dashboard(today)),
      trustedAttendanceDateProvider.overrideWithValue(AsyncData(currentDate)),
      connectivityChangesProvider.overrideWith((ref) => const Stream.empty()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  AttendanceTodayModel today = _monday,
  required String? currentDate,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container(today, currentDate: currentDate),
      child: const MaterialApp(home: AttendanceDashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Mounts the dashboard under the real route names, with stand-in children.
Future<void> _pumpRouted(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: RoutePaths.attendance,
    routes: [
      GoRoute(
        path: RoutePaths.attendance,
        name: RouteNames.attendance,
        builder: (context, state) => const AttendanceDashboardScreen(),
        routes: [
          GoRoute(
            path: RoutePaths.attendanceHistory,
            name: RouteNames.attendanceHistory,
            builder: (context, state) => const Text('history-page'),
          ),
          GoRoute(
            path: RoutePaths.attendancePresence,
            name: RouteNames.attendancePresence,
            builder: (context, state) => const Text('presence-page'),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container(_monday, currentDate: '2026-07-20'),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  // Resolve the dashboard future without letting the intro pulse finish.
  await tester.pump();
  await tester.pump();
}

final _pill = find.widgetWithText(InkWell, 'Presensi Magang');

/// The glow's fade. Its animation is the pulse intensity (0 at rest, 1 at each
/// peak) that also drives the zoom, so it reports whether the pulse runs.
Animation<double> _pulse(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find.descendant(of: _pill, matching: find.byType(FadeTransition)),
    )
    .opacity;

/// The glow's own expansion, nested inside its fade.
double _glowScale(WidgetTester tester) => tester
    .widget<ScaleTransition>(
      find.descendant(
        of: find.descendant(of: _pill, matching: find.byType(FadeTransition)),
        matching: find.byType(ScaleTransition),
      ),
    )
    .scale
    .value;

/// On-screen fingerprint size relative to its 26dp layout size; `getRect`
/// includes every ancestor transform, so this is the zoom the user sees.
double _fingerprintZoom(WidgetTester tester) =>
    tester.getRect(find.byIcon(Icons.fingerprint)).width / 26;

void main() {
  testWidgets('same-day snapshot keeps its times and date, without chips', (
    tester,
  ) async {
    await _pumpDashboard(tester, currentDate: '2026-07-20');

    expect(find.text('Absensi'), findsOneWidget);
    expect(find.text('08:00 - 17:00'), findsOneWidget);
    expect(find.text('20 Juli 2026'), findsOneWidget);
    expect(find.text('07:37'), findsOneWidget);
    expect(find.text('17:05'), findsOneWidget);
    // Status and work mode are no longer shown as badges; the only "Hadir"
    // left is the monthly summary tile.
    expect(find.byType(Chip), findsNothing);
    expect(find.text('WFO'), findsNothing);
    expect(find.text('Hadir'), findsOneWidget);
  });

  testWidgets('a snapshot from an earlier day is not shown as today', (
    tester,
  ) async {
    // Thursday, offline: the cached snapshot is still Monday's.
    await _pumpDashboard(tester, currentDate: '2026-07-23');

    expect(find.text('23 Juli 2026'), findsOneWidget);
    expect(find.text('--:--'), findsNWidgets(2));
    expect(find.text('07:37'), findsNothing);
    expect(find.text('17:05'), findsNothing);
    // Monday's working hours are not Thursday's.
    expect(find.text('08:00 - 17:00'), findsNothing);
    expect(find.text('--:-- - --:--'), findsOneWidget);
    // The rest of the dashboard stays as it was.
    expect(find.text('Presensi Magang'), findsOneWidget);
    expect(find.text('Ringkasan Bulan Ini'), findsOneWidget);
    expect(find.text('Riwayat Presensi'), findsOneWidget);
  });

  testWidgets("a cached Sunday is not shown as Monday's holiday", (
    tester,
  ) async {
    // Monday, offline: the last snapshot is Sunday's non-working day.
    await _pumpDashboard(tester, today: _sunday, currentDate: '2026-07-20');

    expect(find.text('Hari libur'), findsNothing);
    expect(find.text('--:-- - --:--'), findsOneWidget);
    expect(find.text('20 Juli 2026'), findsOneWidget);
    expect(find.text('--:--'), findsNWidgets(2));
  });

  testWidgets('a same-day non-working snapshot still shows Hari libur', (
    tester,
  ) async {
    await _pumpDashboard(tester, today: _sunday, currentDate: '2026-07-19');

    expect(find.text('Hari libur'), findsOneWidget);
    expect(find.text('--:-- - --:--'), findsNothing);
    expect(find.text('19 Juli 2026'), findsOneWidget);
  });

  testWidgets("today's leave is shown as plain text, not a chip", (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      today: _monday.copyWith(
        attendance: null,
        leave: const TodayLeaveModel(type: 'izin', typeLabel: 'Izin'),
      ),
      currentDate: '2026-07-20',
    );

    expect(find.text('Sedang Izin'), findsOneWidget);
    expect(find.byType(Chip), findsNothing);
  });

  testWidgets("an earlier day's leave is not shown as today's", (tester) async {
    await _pumpDashboard(
      tester,
      today: _monday.copyWith(
        attendance: null,
        leave: const TodayLeaveModel(type: 'izin', typeLabel: 'Izin'),
      ),
      currentDate: '2026-07-23',
    );

    expect(find.text('Sedang Izin'), findsNothing);
    expect(find.text('--:--'), findsNWidgets(2));
  });

  testWidgets('without a trusted date the snapshot is shown as before', (
    tester,
  ) async {
    await _pumpDashboard(tester, currentDate: null);

    expect(find.text('20 Juli 2026'), findsOneWidget);
    expect(find.text('07:37'), findsOneWidget);
    expect(find.text('08:00 - 17:00'), findsOneWidget);
  });

  testWidgets('summary shows all six values from the model', (tester) async {
    await _pumpDashboard(tester, currentDate: '2026-07-20');

    for (final (label, value) in [
      ('Hadir', 14),
      ('Terlambat', 1),
      ('Izin', 2),
      ('Sakit', 3),
      ('Dinas Luar', 4),
      ('Tidak Absen', 5),
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(find.text('$value'), findsOneWidget);
    }
  });

  group('navigation', () {
    testWidgets('Presensi Magang opens the check-in flow on the first frame', (
      tester,
    ) async {
      await _pumpRouted(tester);
      // Tapped mid intro pulse: navigation must not wait for it.
      expect(_pulse(tester).isAnimating, isTrue);

      await tester.tap(find.text('Presensi Magang'));
      // GoRouter applies the push on the next frame; no time elapses.
      await tester.pump();
      await tester.pump();

      expect(find.text('presence-page'), findsOneWidget);
    });

    testWidgets('Riwayat Presensi opens the history', (tester) async {
      await _pumpRouted(tester);

      await tester.ensureVisible(find.text('Riwayat Presensi'));
      await tester.tap(find.text('Riwayat Presensi'));
      await tester.pump();
      await tester.pump();

      expect(find.text('history-page'), findsOneWidget);
    });

    testWidgets('the AppBar history action is gone', (tester) async {
      await _pumpDashboard(tester, currentDate: '2026-07-20');

      expect(find.byTooltip('Riwayat'), findsNothing);
      expect(find.byIcon(Icons.history), findsNothing);
    });
  });

  group('fingerprint pulse', () {
    testWidgets('pulses twice with a rest between, then stops', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: _container(_monday, currentDate: '2026-07-20'),
          child: const MaterialApp(home: AttendanceDashboardScreen()),
        ),
      );
      await tester.pump();

      // Timeline (1750 ms): in 0-375, out 375-750, rest 750-1000,
      // in 1000-1375, out 1375-1750.
      await tester.pump(const Duration(milliseconds: 94));
      // Eased: a quarter of the way in, well under a quarter of the zoom.
      expect(_fingerprintZoom(tester), inExclusiveRange(1.0, 1.06));

      await tester.pump(const Duration(milliseconds: 281)); // 375: first peak
      expect(_fingerprintZoom(tester), closeTo(1.25, 0.005));
      expect(_pulse(tester).value, closeTo(1.0, 0.005));
      expect(_glowScale(tester), closeTo(1.2, 0.005));

      await tester.pump(const Duration(milliseconds: 425)); // 800: resting
      expect(_fingerprintZoom(tester), closeTo(1.0, 0.001));
      expect(_pulse(tester).value, 0.0);
      await tester.pump(
        const Duration(milliseconds: 190),
      ); // 990: still resting
      expect(_fingerprintZoom(tester), closeTo(1.0, 0.001));
      expect(_pulse(tester).value, 0.0);
      expect(_pulse(tester).isAnimating, isTrue);

      await tester.pump(const Duration(milliseconds: 385)); // 1375: second peak
      expect(_fingerprintZoom(tester), closeTo(1.25, 0.005));
      expect(_pulse(tester).value, closeTo(1.0, 0.005));

      await tester.pump(const Duration(milliseconds: 376)); // past 1750: done
      expect(_pulse(tester).isAnimating, isFalse);
      expect(_fingerprintZoom(tester), closeTo(1.0, 0.001));
      expect(_pulse(tester).value, 0.0);

      // Nothing keeps running: no further frames, no third pulse.
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(_pulse(tester).value, 0.0);
    });

    testWidgets('is not replayed when the content is rebuilt', (tester) async {
      final container = _container(_monday, currentDate: '2026-07-20');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AttendanceDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Reload swaps the content for the loader and back, remounting it.
      container.invalidate(attendanceDashboardProvider);
      await tester.pump();
      await tester.pump();

      expect(_pulse(tester).isAnimating, isFalse);
      expect(_pulse(tester).value, 0.0);
      expect(_fingerprintZoom(tester), closeTo(1.0, 0.001));
    });

    testWidgets('is skipped when the platform reduces motion', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: _container(_monday, currentDate: '2026-07-20'),
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: const AttendanceDashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 375));

      expect(_pulse(tester).isAnimating, isFalse);
      expect(_pulse(tester).value, 0.0);
      expect(_fingerprintZoom(tester), closeTo(1.0, 0.001));
    });

    testWidgets('press feedback is green-tinted, not the grey highlight', (
      tester,
    ) async {
      await _pumpDashboard(tester, currentDate: '2026-07-20');
      final inkWell = tester.widget<InkWell>(
        find.widgetWithText(InkWell, 'Presensi Magang'),
      );

      const green = Color(0xFF367D49);
      expect(inkWell.highlightColor, green.withValues(alpha: 0.06));
      expect(inkWell.splashColor, green.withValues(alpha: 0.12));
    });

    testWidgets('only shrinks the glyph while the button is held', (
      tester,
    ) async {
      await _pumpDashboard(tester, currentDate: '2026-07-20');
      double pressScale() => tester
          .widget<AnimatedScale>(
            find.ancestor(
              of: find.byIcon(Icons.fingerprint),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Presensi Magang')),
      );
      // InkWell reports the press after kPressTimeout inside a scrollable.
      await tester.pump(kPressTimeout);
      expect(pressScale(), lessThan(1.0));

      await gesture.cancel();
      await tester.pump();
      expect(pressScale(), 1.0);
    });
  });

  group('responsive layout', () {
    Future<void> pumpAt(
      WidgetTester tester, {
      required double width,
      required double textScale,
    }) async {
      // Tall enough that the lazy ListView builds every section.
      tester.view.physicalSize = Size(width, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: _container(_monday, currentDate: '2026-07-20'),
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: const AttendanceDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Rect tile(WidgetTester tester, String label) =>
        tester.getRect(find.bySemanticsLabel(RegExp('^$label: ')));

    const labels = [
      'Hadir',
      'Terlambat',
      'Izin',
      'Sakit',
      'Dinas Luar',
      'Tidak Absen',
    ];

    for (final width in [320.0, 360.0, 393.0, 430.0]) {
      for (final textScale in [1.0, 1.3, 2.0]) {
        testWidgets('renders without overflow at ${width}dp, x$textScale', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          await pumpAt(tester, width: width, textScale: textScale);

          expect(tester.takeException(), isNull);
          expect(find.text('Presensi Magang'), findsOneWidget);
          expect(find.text('Riwayat Presensi'), findsOneWidget);

          final height = tile(tester, 'Hadir').height;
          for (final label in labels) {
            // A paragraph narrower than its widest word has split that word.
            final paragraph = tester.renderObject<RenderParagraph>(
              find.text(label),
            );
            expect(
              paragraph.size.width,
              greaterThanOrEqualTo(
                paragraph.getMinIntrinsicWidth(double.infinity) - 0.01,
              ),
              reason: '"$label" must not break mid-word',
            );
            expect(
              tile(tester, label).height,
              closeTo(height, 0.01),
              reason: 'all summary cards share one height',
            );
          }
          semantics.dispose();
        });
      }
    }

    testWidgets('summary is three-across when every word fits', (tester) async {
      final semantics = tester.ensureSemantics();
      // The column count follows the measured label font. The test font's
      // glyphs are wider than Roboto's, so a wider view stands in for a phone.
      await pumpAt(tester, width: 600, textScale: 1.0);

      expect(tile(tester, 'Izin').top, tile(tester, 'Hadir').top);
      expect(tile(tester, 'Sakit').top, greaterThan(tile(tester, 'Hadir').top));
      semantics.dispose();
    });

    for (final width in [320.0, 393.0]) {
      testWidgets('summary drops a column for large text at ${width}dp', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpAt(tester, width: width, textScale: 2.0);

        expect(
          tile(tester, 'Izin').top,
          greaterThanOrEqualTo(tile(tester, 'Hadir').bottom),
        );
        semantics.dispose();
      });
    }
  });
}
