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

  /// Entries still awaiting sync, oldest first.
  Future<List<AttendanceQueueEntry>> pendingEntries();

  /// All entries, newest first (for UI / diagnostics).
  Future<List<AttendanceQueueEntry>> allEntries();

  /// Number of entries still awaiting sync.
  Future<int> pendingCount();

  /// Removes synced entries created before [cutoff] to keep the queue small.
  Future<void> purgeSyncedBefore(DateTime cutoff);
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
  Future<List<AttendanceQueueEntry>> pendingEntries() async {
    final rows = await _db.query(
      attendanceQueueTable,
      where: 'status = ?',
      whereArgs: [QueuedEventStatus.pending.wire],
      orderBy: 'created_at ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<AttendanceQueueEntry>> allEntries() async {
    final rows = await _db.query(
      attendanceQueueTable,
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<int> pendingCount() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) AS c FROM $attendanceQueueTable WHERE status = ?',
      [QueuedEventStatus.pending.wire],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> purgeSyncedBefore(DateTime cutoff) async {
    await _db.delete(
      attendanceQueueTable,
      where: 'status = ? AND created_at < ?',
      whereArgs: [QueuedEventStatus.synced.wire, cutoff.toIso8601String()],
    );
  }
}

Map<String, Object?> _toRow(AttendanceQueueEntry entry) => {
      'client_event_id': entry.clientEventId,
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
