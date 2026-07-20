import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/leave_models.dart';

/// Local cache of the latest successfully loaded leave-request list page for a
/// given filter (pending / history).
///
/// Persisted as the raw JSON payload so it rehydrates verbatim, letting the
/// list screens render offline (last-known snapshot) instead of blocking on the
/// network. One row per `(user_id, filter)`, so an account only ever reads its
/// own snapshot and the two lists never overwrite each other.
///
/// These are read-only snapshots: they are never authoritative for mutations —
/// submissions always go online through the live API.
abstract interface class LeaveListCacheStore {
  /// Overwrites the cached page for [userId] and [filter] with [page].
  Future<void> save(int userId, String filter, LeaveListModel page);

  /// Returns the cached page for [userId] and [filter], or `null` when nothing
  /// has been cached yet.
  Future<LeaveListModel?> read(int userId, String filter);
}

class SqfliteLeaveListCacheStore implements LeaveListCacheStore {
  SqfliteLeaveListCacheStore(this._db);

  final Database _db;

  @override
  Future<void> save(int userId, String filter, LeaveListModel page) async {
    await _db.insert(leaveListCacheTable, {
      'user_id': userId,
      'filter': filter,
      'payload': jsonEncode(page.toJson()),
      'cached_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<LeaveListModel?> read(int userId, String filter) async {
    final rows = await _db.query(
      leaveListCacheTable,
      where: 'user_id = ? AND filter = ?',
      whereArgs: [userId, filter],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final payload = rows.single['payload'] as String?;
    if (payload == null || payload.isEmpty) return null;

    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) return null;
    return LeaveListModel.fromJson(decoded);
  }
}
