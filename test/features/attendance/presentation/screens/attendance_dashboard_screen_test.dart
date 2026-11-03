import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_attendance_date_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

class _Dashboard extends AttendanceDashboardNotifier {
  _Dashboard(this.today);

  final AttendanceTodayModel today;

  @override
  Future<AttendanceDashboardModel> build() async => AttendanceDashboardModel(
    today: today,
    summary: const MonthlySummaryModel(month: '2026-07'),
  );
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  AttendanceTodayModel today = _monday,
  required String? currentDate,
}) async {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      attendanceDashboardProvider.overrideWith(() => _Dashboard(today)),
      trustedAttendanceDateProvider.overrideWithValue(AsyncData(currentDate)),
      connectivityChangesProvider.overrideWith((ref) => const Stream.empty()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AttendanceDashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('same-day snapshot keeps its times, status and date', (
    tester,
  ) async {
    await _pumpDashboard(tester, currentDate: '2026-07-20');

    expect(find.text('08:00 - 17:00'), findsOneWidget);
    expect(find.text('Absensi hari ini, 20 Juli 2026'), findsOneWidget);
    expect(find.text('07:37'), findsOneWidget);
    expect(find.text('17:05'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Hadir'), findsOneWidget);
  });

  testWidgets('a snapshot from an earlier day is not shown as today', (
    tester,
  ) async {
    // Thursday, offline: the cached snapshot is still Monday's.
    await _pumpDashboard(tester, currentDate: '2026-07-23');

    expect(find.text('Absensi hari ini, 23 Juli 2026'), findsOneWidget);
    expect(find.text('--:--'), findsNWidgets(2));
    expect(find.text('07:37'), findsNothing);
    expect(find.text('17:05'), findsNothing);
    expect(find.widgetWithText(Chip, 'Hadir'), findsNothing);
    expect(find.widgetWithText(Chip, 'WFO'), findsNothing);
    // Monday's working hours are not Thursday's.
    expect(find.text('08:00 - 17:00'), findsNothing);
    expect(find.text('--:-- - --:--'), findsOneWidget);
    // The rest of the dashboard stays as it was.
    expect(find.text('Presensi Magang'), findsOneWidget);
    expect(find.text('Rekapitulasi Presensi Bulan'), findsOneWidget);
  });

  testWidgets("a cached Sunday is not shown as Monday's holiday", (
    tester,
  ) async {
    // Monday, offline: the last snapshot is Sunday's non-working day.
    await _pumpDashboard(tester, today: _sunday, currentDate: '2026-07-20');

    expect(find.text('Hari libur'), findsNothing);
    expect(find.text('--:-- - --:--'), findsOneWidget);
    expect(find.text('Absensi hari ini, 20 Juli 2026'), findsOneWidget);
    expect(find.text('--:--'), findsNWidgets(2));
  });

  testWidgets('a same-day non-working snapshot still shows Hari libur', (
    tester,
  ) async {
    await _pumpDashboard(tester, today: _sunday, currentDate: '2026-07-19');

    expect(find.text('Hari libur'), findsOneWidget);
    expect(find.text('--:-- - --:--'), findsNothing);
    expect(find.text('Absensi hari ini, 19 Juli 2026'), findsOneWidget);
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

    expect(find.text('Absensi hari ini, 20 Juli 2026'), findsOneWidget);
    expect(find.text('07:37'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Hadir'), findsOneWidget);
  });
}
