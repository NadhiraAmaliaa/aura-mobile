import 'dart:io';

import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Verifies that an offline capture persisted to sqflite survives an app kill:
/// the queue must be reopened from disk with the pending entry intact so it can
/// still be synced later. Uses a real file-backed database (not in-memory) to
/// model process restart.
void main() {
  setUpAll(sqfliteFfiInit);

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('aura_queue_restart');
    dbPath = p.join(tempDir.path, 'aura_mobile.db');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  AttendanceQueueEntry pendingCheckIn(String id) => AttendanceQueueEntry(
    clientEventId: id,
    type: AttendanceEventType.checkIn,
    workMode: 'wfo',
    latitude: '3.5952000',
    longitude: '98.6722000',
    capturedAt: '2026-07-12T14:03:07+07:00',
    officeId: 5,
    officeName: 'Kantor Pusat',
    officeLatitude: '3.5952000',
    officeLongitude: '98.6722000',
    officeRadius: 200,
    createdAt: DateTime(2026, 7, 12, 14, 3, 7),
  );

  test('a queued offline capture survives an app restart', () async {
    // First launch: capture while offline, then the process dies.
    var db = await openAppDatabase(
      factory: databaseFactoryFfi,
      path: dbPath,
    );
    await SqfliteAttendanceQueueStore(db).save(pendingCheckIn('evt-1'));
    await db.close();

    // Second launch: reopen the same on-disk database.
    db = await openAppDatabase(factory: databaseFactoryFfi, path: dbPath);
    final pending = await SqfliteAttendanceQueueStore(db).pendingEntries();
    await db.close();

    expect(pending, hasLength(1));
    expect(pending.single.clientEventId, 'evt-1');
    expect(pending.single.status, QueuedEventStatus.pending);
    expect(pending.single.workMode, 'wfo');
    expect(pending.single.officeName, 'Kantor Pusat');
  });
}
