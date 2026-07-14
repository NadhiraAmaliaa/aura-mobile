import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import 'attendance_queue_entry.dart';

/// Persistence seam for the offline attendance queue.
///
/// Abstracted so the sync engine can be unit-tested against an in-memory fake,
/// while [SqfliteAttendanceQueueStore] is exercised with a real database.
abstract interface class AttendanceQueueStore {
  /// Inserts a new entry, or replaces an existing one with the same
  /// [AttendanceQueueEntry.clientEventId].
  Future<void> save(AttendanceQueueEntry entry);

  /// Enqueues a check-out while keeping at most one still-pending check-out per
  /// owner and attendance date: any other pending check-out for the same
  /// [AttendanceQueueEntry.userId] on the same captured date is discarded so the
  /// newest capture wins. Already-synced or rejected check-outs are left
  /// untouched (a later tap is a genuinely new event). Runs atomically.
  Future<void> replacePendingCheckOut(AttendanceQueueEntry entry);

  /// Entries owned by [userId] still awaiting sync, oldest first.
  Future<List<AttendanceQueueEntry>> pendingEntries(int userId);

  /// All entries owned by [userId], newest first (for UI / diagnostics).
  Future<List<AttendanceQueueEntry>> allEntries(int userId);

  /// Number of entries owned by [userId] still awaiting sync.
  Future<int> pendingCount(int userId);

  /// Removes [userId]'s synced entries created before [cutoff] to keep the
  /// queue small.
  Future<void> purgeSyncedBefore(int userId, DateTime cutoff);
}

class SqfliteAttendanceQueueStore implements AttendanceQueueStore {
  SqfliteAttendanceQueueStore(this._db);

  final Database _db;

  @override
  Future<void> save(AttendanceQueueEntry entry) async {
    await _db.insert(
      attendanceQueueTable,
      _toRow(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> replacePendingCheckOut(AttendanceQueueEntry entry) async {
    await _db.transaction((txn) async {
      // Drop any still-pending check-out this owner captured on the same local
      // date, so only the newest pending check-out survives. captured_at is an
      // ISO-8601 string with the device's local offset, so its first 10 chars
      // are the local calendar date and compare correctly across same-device
      // captures. Synced / rejected rows are excluded and never removed.
      await txn.delete(
        attendanceQueueTable,
        where:
            'user_id = ? AND event_type = ? AND status = ? '
            'AND substr(captured_at, 1, 10) = ?',
        whereArgs: [
          entry.userId,
          AttendanceEventType.checkOut.wire,
          QueuedEventStatus.pending.wire,
          entry.capturedAt.substring(0, 10),
        ],
      );
      await txn.insert(
        attendanceQueueTable,
        _toRow(entry),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  @override
  Future<List<AttendanceQueueEntry>> pendingEntries(int userId) async {
    final rows = await _db.query(
      attendanceQueueTable,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, QueuedEventStatus.pending.wire],
      orderBy: 'created_at ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<AttendanceQueueEntry>> allEntries(int userId) async {
    final rows = await _db.query(
      attendanceQueueTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<int> pendingCount(int userId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) AS c FROM $attendanceQueueTable '
      'WHERE user_id = ? AND status = ?',
      [userId, QueuedEventStatus.pending.wire],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> purgeSyncedBefore(int userId, DateTime cutoff) async {
    await _db.delete(
      attendanceQueueTable,
      where: 'user_id = ? AND status = ? AND created_at < ?',
      whereArgs: [
        userId,
        QueuedEventStatus.synced.wire,
        cutoff.toIso8601String(),
      ],
    );
  }
}

Map<String, Object?> _toRow(AttendanceQueueEntry entry) => {
  'client_event_id': entry.clientEventId,
  'user_id': entry.userId,
  'event_type': entry.type.wire,
  'work_mode': entry.workMode,
  'latitude': entry.latitude,
  'longitude': entry.longitude,
  'captured_at': entry.capturedAt,
  'office_id': entry.officeId,
  'office_name': entry.officeName,
  'office_latitude': entry.officeLatitude,
  'office_longitude': entry.officeLongitude,
  'office_radius': entry.officeRadius,
  'auto_time_enabled': entry.autoTimeEnabled == null
      ? null
      : (entry.autoTimeEnabled! ? 1 : 0),
  'status': entry.status.wire,
  'attempts': entry.attempts,
  'last_error': entry.lastError,
  'created_at': entry.createdAt.toIso8601String(),
  'synced_at': entry.syncedAt?.toIso8601String(),
};

AttendanceQueueEntry _fromRow(Map<String, Object?> row) {
  final autoTime = row['auto_time_enabled'] as int?;
  final syncedAt = row['synced_at'] as String?;
  return AttendanceQueueEntry(
    clientEventId: row['client_event_id']! as String,
    type: AttendanceEventType.fromWire(row['event_type']! as String),
    userId: row['user_id'] as int?,
    workMode: row['work_mode'] as String?,
    latitude: row['latitude'] as String?,
    longitude: row['longitude'] as String?,
    capturedAt: row['captured_at']! as String,
    officeId: row['office_id'] as int?,
    officeName: row['office_name'] as String?,
    officeLatitude: row['office_latitude'] as String?,
    officeLongitude: row['office_longitude'] as String?,
    officeRadius: row['office_radius'] as int?,
    autoTimeEnabled: autoTime == null ? null : autoTime != 0,
    status: QueuedEventStatus.fromWire(row['status']! as String),
    attempts: row['attempts']! as int,
    lastError: row['last_error'] as String?,
    createdAt: DateTime.parse(row['created_at']! as String),
    syncedAt: syncedAt == null ? null : DateTime.parse(syncedAt),
  );
}
