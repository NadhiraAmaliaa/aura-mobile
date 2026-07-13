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

  const userId = 7;

  test('returns null when nothing has been cached', () async {
    expect(await store.read(userId), isNull);
  });

  test('round-trips the dashboard payload verbatim', () async {
    await store.save(userId, _dashboard);

    final cached = await store.read(userId);

    expect(cached, isNotNull);
    expect(cached!.today.attendance?.id, 42);
    expect(cached.today.attendance?.checkInTime, '08:03');
    expect(cached.today.attendance?.workMode, 'wfo');
    expect(cached.summary.hadir, 5);
    expect(cached.summary.terlambat, 1);
  });

  test('keeps only the latest snapshot per user (single row)', () async {
    await store.save(userId, _dashboard);
    await store.save(
      userId,
      _dashboard.copyWith(
        summary: const MonthlySummaryModel(month: '2026-08', hadir: 9),
      ),
    );

    final rows = await db.query(
      dashboardCacheTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    expect(rows, hasLength(1));

    final cached = await store.read(userId);
    expect(cached!.summary.month, '2026-08');
    expect(cached.summary.hadir, 9);
  });

  test('one user never reads another user\'s snapshot', () async {
    const other = 8;
    await store.save(userId, _dashboard);

    // Account 8 has cached nothing of its own yet.
    expect(await store.read(other), isNull);

    // Account 8 caches its own distinct snapshot.
    await store.save(
      other,
      _dashboard.copyWith(
        summary: const MonthlySummaryModel(month: '2026-09', hadir: 1),
      ),
    );

    // Each account reads only its own row.
    expect((await store.read(userId))!.summary.hadir, 5);
    expect((await store.read(other))!.summary.month, '2026-09');
  });
}
