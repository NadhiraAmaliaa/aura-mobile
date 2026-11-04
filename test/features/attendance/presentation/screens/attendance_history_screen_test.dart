import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_history_month_provider.dart';
import 'package:aura_mobile/features/attendance/presentation/screens/attendance_history_screen.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../history_test_support.dart';

/// Distinct counts per month so each recap can be told apart.
const _septemberRecap = MonthlySummaryModel(
  month: '2026-09',
  hadir: 14,
  terlambat: 1,
  izin: 2,
  sakit: 3,
  dinas: 4,
  tidakAbsen: 5,
);
const _augustRecap = MonthlySummaryModel(
  month: '2026-08',
  hadir: 20,
  terlambat: 6,
  izin: 7,
  sakit: 8,
  dinas: 9,
  tidakAbsen: 11,
);

/// September 2026: Fri 18, Thu 17 (late), Thu 10 (no check-out), Wed 9 (sick).
final _september = [
  historyRecord('2026-09-18', checkIn: '07:52', checkOut: '15:01'),
  historyRecord(
    '2026-09-17',
    checkIn: '08:20',
    checkOut: '17:03',
    status: 'late',
    statusLabel: 'Terlambat',
  ),
  historyRecord('2026-09-10', checkIn: '07:23', checkOut: null),
  historyRecord(
    '2026-09-09',
    checkIn: null,
    checkOut: null,
    status: 'sick',
    statusLabel: 'Sakit',
  ),
];

/// August 2026: Mon 31 and Fri 28, with times not used in September.
final _august = [
  historyRecord('2026-08-31', checkIn: '07:11', checkOut: '16:59'),
  historyRecord('2026-08-28', checkIn: '07:12', checkOut: '15:04'),
];

const _user = UserModel(
  id: 7,
  name: 'Nadia',
  role: 'intern',
  intern: InternModel(
    id: 1,
    nim: '123',
    status: 'active',
    startDate: '2026-02-16',
    endDate: '2026-12-31',
  ),
);

class _Auth extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState.authenticated(_user);
}

FakeHistoryRepository _repository({
  List<AttendanceModel>? september,
  int perPage = 15,
}) => FakeHistoryRepository(
  recordsByMonth: {'2026-09': september ?? _september, '2026-08': _august},
  summaryByMonth: {'2026-09': _septemberRecap, '2026-08': _augustRecap},
  perPage: perPage,
);

Future<void> _pump(
  WidgetTester tester,
  FakeHistoryRepository repository, {
  double width = 393,
  double height = 900,
  double textScale = 1.0,
  bool settle = true,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      attendanceRepositoryProvider.overrideWithValue(repository),
      // The month the dashboard below this screen would provide.
      attendanceHistoryLatestMonthProvider.overrideWithValue('2026-09'),
      authProvider.overrideWith(_Auth.new),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const AttendanceHistoryScreen(),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// Opens the month picker and taps the short month [label] (e.g. "Agu").
///
/// Without [settle] (spinners still running) frames are pumped explicitly: a
/// sheet animation starts on the first frame after the tap, and the selection
/// rebuilds the screen on the frame after the sheet closes.
Future<void> _selectMonth(
  WidgetTester tester,
  String current,
  String label, {
  bool settle = true,
}) async {
  Future<void> advance() async {
    if (settle) {
      await tester.pumpAndSettle();
      return;
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
  }

  await tester.tap(find.text(current));
  await advance();
  await tester.tap(find.text(label));
  await advance();
}

Finder _recap(String label, int value) =>
    find.bySemanticsLabel('$label: $value');

void _expectSeptemberRecap() {
  for (final (label, value) in [
    ('Hadir', 14),
    ('Terlambat', 1),
    ('Izin', 2),
    ('Sakit', 3),
    ('Dinas Luar', 4),
    ('Tidak Absen', 5),
  ]) {
    expect(_recap(label, value), findsOneWidget, reason: label);
  }
}

void main() {
  testWidgets('shows the selected month, its six-category recap and records', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = _repository();
    await _pump(tester, repository);

    expect(find.text('Riwayat Presensi'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    _expectSeptemberRecap();
    expect(find.text('Daftar Kehadiran'), findsOneWidget);
    expect(find.text('4 data'), findsOneWidget);

    // Both endpoints were asked for the same month.
    expect(repository.dashboardCalls, ['2026-09']);
    expect(repository.historyCalls, [(month: '2026-09', page: 1)]);

    expect(find.text('Jumat'), findsOneWidget);
    expect(find.text('07:52'), findsOneWidget);
    expect(find.text('15:01'), findsOneWidget);
    // A missing check-out is a placeholder, never an invented time.
    expect(find.text('07:23'), findsOneWidget);
    expect(find.text(attendanceMissingTime), findsOneWidget);
    // The sick day shows the backend label (the other "Sakit" is the recap).
    expect(find.text('Sakit'), findsNWidgets(2));
    // No per-row status badges or chevrons.
    expect(find.text('Hadir'), findsOneWidget);
    expect(find.text('Terlambat'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    semantics.dispose();
  });

  testWidgets('a row shows the day beside the weekday, then both times', (
    tester,
  ) async {
    await _pump(tester, _repository(), width: 600);

    final day = tester.getRect(find.text('18'));
    final weekday = tester.getRect(find.text('Jumat'));
    final checkIn = tester.getRect(find.text('07:52'));
    final checkOut = tester.getRect(find.text('15:01'));

    for (final rect in [weekday, checkIn, checkOut]) {
      expect(rect.center.dy, moreOrLessEquals(day.center.dy, epsilon: 1.5));
    }
    expect(day.right, lessThanOrEqualTo(weekday.left));
    expect(weekday.right, lessThan(checkIn.left));
    expect(checkIn.right, lessThan(checkOut.left));
  });

  testWidgets('rows share one rounded surface, separated by dividers', (
    tester,
  ) async {
    await _pump(tester, _repository());

    // Rounded white surfaces enclosing a row's text: only the shared one.
    Finder surfaceOf(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).borderRadius != null,
      ),
    );

    expect(surfaceOf('18'), findsOneWidget);
    expect(tester.widget(surfaceOf('18')), same(tester.widget(surfaceOf('9'))));
    // Four records, three dividers between them.
    expect(
      find.descendant(of: surfaceOf('18'), matching: find.byType(Divider)),
      findsNWidgets(_september.length - 1),
    );
  });

  group('responsive layout', () {
    for (final width in [320.0, 360.0, 393.0, 430.0]) {
      for (final textScale in [1.0, 1.3, 2.0]) {
        testWidgets('renders without overflow at ${width}dp, x$textScale', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          await _pump(
            tester,
            _repository(),
            width: width,
            // Tall enough that the lazy list builds every row.
            height: 3200,
            textScale: textScale,
          );

          expect(tester.takeException(), isNull);
          _expectSeptemberRecap();

          // The day number always stays on the weekday's line, never above it.
          for (final (dayText, weekdayText) in [
            ('18', 'Jumat'),
            ('9', 'Rabu'),
          ]) {
            final day = tester.getRect(find.text(dayText));
            final weekday = tester.getRect(find.text(weekdayText));
            expect(
              weekday.center.dy,
              moreOrLessEquals(day.center.dy, epsilon: 1.5),
            );
            expect(day.right, lessThanOrEqualTo(weekday.left));
          }
          semantics.dispose();
        });
      }
    }
  });

  testWidgets('switching month loads that month\'s recap and records only', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = _repository();
    await _pump(tester, repository);

    await _selectMonth(tester, 'September 2026', 'Agu');

    expect(find.text('Agustus 2026'), findsOneWidget);
    expect(_recap('Hadir', 20), findsOneWidget);
    expect(_recap('Hadir', 14), findsNothing);
    expect(find.text('2 data'), findsOneWidget);
    expect(find.text('07:11'), findsOneWidget);
    expect(find.text('15:01'), findsNothing);
    expect(repository.dashboardCalls, ['2026-09', '2026-08']);
    expect(repository.historyCalls.last, (month: '2026-08', page: 1));
    semantics.dispose();
  });

  testWidgets('a late response for the previous month never shows', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = _repository()..hold = true;
    await _pump(tester, repository, settle: false);

    // September is still loading when the user switches to August.
    await _selectMonth(tester, 'September 2026', 'Agu', settle: false);
    repository
      ..releaseHistory('2026-08', 1)
      ..releaseDashboard('2026-08');
    await tester.pump();

    // September's responses arrive last.
    repository
      ..releaseHistory('2026-09', 1)
      ..releaseDashboard('2026-09');
    await tester.pumpAndSettle();

    expect(find.text('Agustus 2026'), findsOneWidget);
    expect(_recap('Hadir', 20), findsOneWidget);
    expect(_recap('Hadir', 14), findsNothing);
    expect(find.text('07:11'), findsOneWidget);
    expect(find.text('15:01'), findsNothing);
    expect(find.text('2 data'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('scrolling to the end loads the next page of the same month', (
    tester,
  ) async {
    final repository = _repository(september: monthRecords('2026-09', 20));
    await _pump(tester, repository, height: 700);
    expect(repository.historyCalls, [(month: '2026-09', page: 1)]);

    await tester.dragUntilVisible(
      find.text('Tidak ada data lagi'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    // Page 2 of the same month only; no page is requested twice.
    expect(repository.historyCalls, [
      (month: '2026-09', page: 1),
      (month: '2026-09', page: 2),
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed next page offers a retry in the footer', (
    tester,
  ) async {
    final repository = _repository(september: monthRecords('2026-09', 20))
      ..historyFailures['2026-09#2'] = const NetworkException();
    await _pump(tester, repository, height: 700);

    await tester.dragUntilVisible(
      find.text('Gagal memuat data berikutnya.'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    // Not retried automatically while the user keeps scrolling.
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(
      repository.historyCalls.where((call) => call.page == 2),
      hasLength(1),
    );

    repository.historyFailures.clear();
    await tester.tap(find.widgetWithText(TextButton, 'Coba lagi'));
    await tester.pumpAndSettle();

    expect(
      repository.historyCalls.where((call) => call.page == 2),
      hasLength(2),
    );
    await tester.dragUntilVisible(
      find.text('Tidak ada data lagi'),
      find.byType(ListView),
      const Offset(0, -300),
    );
  });

  testWidgets('an empty month shows the empty state beside its recap', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, _repository(september: const []));

    expect(
      find.text('Belum ada riwayat presensi pada September 2026.'),
      findsOneWidget,
    );
    expect(find.text('0 data'), findsOneWidget);
    _expectSeptemberRecap();
    semantics.dispose();
  });

  testWidgets('a history error offers a retry for the same month', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = _repository()
      ..historyFailures['2026-09#1'] = const NetworkException(
        message: 'Tidak ada koneksi internet.',
      );
    await _pump(tester, repository);

    expect(find.text('Tidak ada koneksi internet.'), findsOneWidget);
    _expectSeptemberRecap();

    repository.historyFailures.clear();
    await tester.tap(find.widgetWithText(FilledButton, 'Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('07:52'), findsOneWidget);
    expect(
      repository.historyCalls.every((call) => call.month == '2026-09'),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('a recap error has its own retry and keeps the list', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = _repository()
      ..dashboardFailures['2026-09'] = const ServerException();
    await _pump(tester, repository);

    expect(
      find.text('Ringkasan bulan ini belum dapat dimuat.'),
      findsOneWidget,
    );
    expect(find.text('07:52'), findsOneWidget);

    repository.dashboardFailures.clear();
    await tester.tap(find.widgetWithText(TextButton, 'Coba lagi'));
    await tester.pumpAndSettle();

    _expectSeptemberRecap();
    expect(repository.dashboardCalls, ['2026-09', '2026-09']);
    semantics.dispose();
  });

  testWidgets('the month picker offers only months of the internship period', (
    tester,
  ) async {
    await _pump(tester, _repository());
    await tester.tap(find.text('September 2026'));
    await tester.pumpAndSettle();

    VoidCallback? onPressed(String label) => tester
        .widget<ButtonStyleButton>(
          find.ancestor(
            of: find.text(label),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          ),
        )
        .onPressed;

    // Internship starts Feb 2026; the latest month is Sep 2026.
    expect(onPressed('Jan'), isNull);
    expect(onPressed('Feb'), isNotNull);
    expect(onPressed('Agu'), isNotNull);
    expect(onPressed('Okt'), isNull);
    expect(
      find.ancestor(of: find.text('Sep'), matching: find.byType(FilledButton)),
      findsOneWidget,
    );
    // A single year: no navigation to other years.
    for (final tooltip in ['Tahun sebelumnya', 'Tahun berikutnya']) {
      final button = tester.widget<IconButton>(
        find.widgetWithIcon(
          IconButton,
          tooltip == 'Tahun sebelumnya'
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
        ),
      );
      expect(button.onPressed, isNull, reason: tooltip);
    }
  });

  testWidgets('pull to refresh reloads the recap and list of the month', (
    tester,
  ) async {
    final repository = _repository();
    await _pump(tester, repository);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(repository.dashboardCalls, ['2026-09', '2026-09']);
    expect(repository.historyCalls, [
      (month: '2026-09', page: 1),
      (month: '2026-09', page: 1),
    ]);
    expect(find.text('07:52'), findsOneWidget);
  });
}
