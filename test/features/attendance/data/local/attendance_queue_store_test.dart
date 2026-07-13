import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late SqfliteAttendanceQueueStore store;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await openAppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    store = SqfliteAttendanceQueueStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  const userId = 7;

  AttendanceQueueEntry entry(
    String id, {
    int owner = userId,
    AttendanceEventType type = AttendanceEventType.checkIn,
    QueuedEventStatus status = QueuedEventStatus.pending,
    DateTime? createdAt,
    bool? autoTime,
  }) {
    return AttendanceQueueEntry(
      clientEventId: id,
      userId: owner,
      type: type,
      workMode: type == AttendanceEventType.checkIn ? 'wfo' : null,
      latitude: '3.5952000',
      longitude: '98.6722000',
      capturedAt: '2026-07-12T14:03:07+07:00',
      officeId: 5,
      officeName: 'Kantor Pusat',
      officeLatitude: '3.5952000',
      officeLongitude: '98.6722000',
      officeRadius: 200,
      autoTimeEnabled: autoTime,
      status: status,
      createdAt: createdAt ?? DateTime(2026, 7, 12, 14, 3, 7),
    );
  }

  test('saves and reads back an entry with all fields intact', () async {
    await store.save(entry('a', autoTime: true));

    final all = await store.allEntries(userId);

    expect(all, hasLength(1));
    final saved = all.single;
    expect(saved.clientEventId, 'a');
    expect(saved.type, AttendanceEventType.checkIn);
    expect(saved.workMode, 'wfo');
    expect(saved.latitude, '3.5952000');
    expect(saved.capturedAt, '2026-07-12T14:03:07+07:00');
    expect(saved.officeId, 5);
    expect(saved.officeName, 'Kantor Pusat');
    expect(saved.officeRadius, 200);
    expect(saved.autoTimeEnabled, isTrue);
    expect(saved.status, QueuedEventStatus.pending);
    expect(saved.attempts, 0);
  });

  test('preserves a null auto-time flag', () async {
    await store.save(entry('a'));

    final saved = (await store.allEntries(userId)).single;

    expect(saved.autoTimeEnabled, isNull);
  });

  test('replaces an entry that shares the same client event id', () async {
    await store.save(entry('a'));
    await store.save(
      entry('a').copyWith(status: QueuedEventStatus.synced, attempts: 2),
    );

    final all = await store.allEntries(userId);

    expect(all, hasLength(1));
    expect(all.single.status, QueuedEventStatus.synced);
    expect(all.single.attempts, 2);
  });

  test('pendingEntries returns only pending rows, oldest first', () async {
    await store.save(entry('new', createdAt: DateTime(2026, 7, 12, 10)));
    await store.save(entry('old', createdAt: DateTime(2026, 7, 12, 8)));
    await store.save(entry('done', status: QueuedEventStatus.synced));
    await store.save(entry('rejected', status: QueuedEventStatus.rejected));

    final pending = await store.pendingEntries(userId);

    expect(pending.map((e) => e.clientEventId), ['old', 'new']);
  });

  test('pendingCount counts only pending rows', () async {
    await store.save(entry('a'));
    await store.save(entry('b'));
    await store.save(entry('c', status: QueuedEventStatus.synced));

    expect(await store.pendingCount(userId), 2);
  });

  test('purgeSyncedBefore removes only old synced rows', () async {
    await store.save(
      entry(
        'old-synced',
        status: QueuedEventStatus.synced,
        createdAt: DateTime(2026, 7, 1),
      ),
    );
    await store.save(
      entry(
        'new-synced',
        status: QueuedEventStatus.synced,
        createdAt: DateTime(2026, 7, 20),
      ),
    );
    await store.save(entry('old-pending', createdAt: DateTime(2026, 7, 1)));

    await store.purgeSyncedBefore(userId, DateTime(2026, 7, 10));

    final ids =
        (await store.allEntries(userId)).map((e) => e.clientEventId).toSet();
    expect(ids, {'new-synced', 'old-pending'});
  });

  test('every read is isolated to its owning user', () async {
    const other = 8;
    await store.save(entry('a-in', createdAt: DateTime(2026, 7, 12, 8)));
    await store.save(entry('a-done', status: QueuedEventStatus.synced));
    await store.save(entry('b-in', owner: other));
    await store.save(
      entry(
        'b-old-synced',
        owner: other,
        status: QueuedEventStatus.synced,
        createdAt: DateTime(2026, 7, 1),
      ),
    );

    // Account 7 only ever sees its own rows.
    expect(
      (await store.allEntries(userId)).map((e) => e.clientEventId).toSet(),
      {'a-in', 'a-done'},
    );
    expect((await store.pendingEntries(userId)).single.clientEventId, 'a-in');
    expect(await store.pendingCount(userId), 1);

    // Account 8 only ever sees its own rows.
    expect(
      (await store.allEntries(other)).map((e) => e.clientEventId).toSet(),
      {'b-in', 'b-old-synced'},
    );

    // Purging one user's synced rows never touches the other's.
    await store.purgeSyncedBefore(userId, DateTime(2026, 7, 10));
    expect(
      (await store.allEntries(other)).map((e) => e.clientEventId).toSet(),
      {'b-in', 'b-old-synced'},
    );
  });
}
