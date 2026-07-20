import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/features/leave/data/local/leave_list_cache_store.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

LeaveRequestModel _request(int id) => LeaveRequestModel(
  id: id,
  requestNumber: 'LR-2026-000$id',
  type: 'izin',
  typeLabel: 'Izin',
  reason: 'Alasan $id',
  status: 'pending',
  statusLabel: 'Menunggu',
);

LeaveListModel _page(List<int> ids) => LeaveListModel(
  items: ids.map(_request).toList(),
  pagination: LeavePaginationModel(
    currentPage: 1,
    lastPage: 1,
    total: ids.length,
  ),
);

void main() {
  late Database db;
  late SqfliteLeaveListCacheStore store;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await openAppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    store = SqfliteLeaveListCacheStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  const userId = 7;

  test('returns null when nothing has been cached', () async {
    expect(await store.read(userId, 'pending'), isNull);
  });

  test('round-trips the list payload verbatim', () async {
    await store.save(userId, 'pending', _page([1, 2, 3]));

    final cached = await store.read(userId, 'pending');

    expect(cached, isNotNull);
    expect(cached!.items.map((e) => e.id), [1, 2, 3]);
    expect(cached.items.first.requestNumber, 'LR-2026-0001');
    expect(cached.pagination.total, 3);
  });

  test('keeps snapshots for the two filters isolated', () async {
    await store.save(userId, 'pending', _page([1]));
    await store.save(userId, 'history', _page([2, 3]));

    expect((await store.read(userId, 'pending'))!.items.map((e) => e.id), [1]);
    expect((await store.read(userId, 'history'))!.items.map((e) => e.id), [
      2,
      3,
    ]);
  });

  test('keeps only the latest snapshot per (user, filter)', () async {
    await store.save(userId, 'pending', _page([1, 2]));
    await store.save(userId, 'pending', _page([9]));

    final rows = await db.query(
      leaveListCacheTable,
      where: 'user_id = ? AND filter = ?',
      whereArgs: [userId, 'pending'],
    );
    expect(rows, hasLength(1));

    final cached = await store.read(userId, 'pending');
    expect(cached!.items.map((e) => e.id), [9]);
  });

  test('scopes snapshots by user so accounts never cross', () async {
    await store.save(userId, 'pending', _page([1]));

    expect(await store.read(8, 'pending'), isNull);
  });
}
