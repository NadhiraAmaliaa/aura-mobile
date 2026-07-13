import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/features/attendance/data/local/dashboard_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _dashboard = AttendanceDashboardModel(
  today: AttendanceTodayModel(
    date: '2026-07-12',
    isWorkingDay: true,
    workHours: WorkHoursModel(start: '08:00', end: '17:00'),
    attendance: AttendanceModel(
      id: 42,
      attendanceDate: '2026-07-12',
      checkInTime: '08:03',
      status: 'hadir',
      statusLabel: 'Hadir',
      workMode: 'wfo',
      workModeLabel: 'WFO',
    ),
  ),
  summary: MonthlySummaryModel(month: '2026-07', hadir: 5, terlambat: 1),
);

void main() {
  late Database db;
  late SqfliteDashboardCacheStore store;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await openAppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    store = SqfliteDashboardCacheStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('returns null when nothing has been cached', () async {
    expect(await store.read(), isNull);
  });

  test('round-trips the dashboard payload verbatim', () async {
    await store.save(_dashboard);

    final cached = await store.read();

    expect(cached, isNotNull);
    expect(cached!.today.attendance?.id, 42);
    expect(cached.today.attendance?.checkInTime, '08:03');
    expect(cached.today.attendance?.workMode, 'wfo');
    expect(cached.summary.hadir, 5);
    expect(cached.summary.terlambat, 1);
  });

  test('keeps only the latest snapshot (single row)', () async {
    await store.save(_dashboard);
    await store.save(
      _dashboard.copyWith(
        summary: const MonthlySummaryModel(month: '2026-08', hadir: 9),
      ),
    );

    final rows = await db.query(dashboardCacheTable);
    expect(rows, hasLength(1));

    final cached = await store.read();
    expect(cached!.summary.month, '2026-08');
    expect(cached.summary.hadir, 9);
  });
}
