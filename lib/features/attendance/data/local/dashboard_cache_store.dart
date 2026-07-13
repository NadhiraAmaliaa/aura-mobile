import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/attendance_models.dart';

/// Local cache of the last successfully loaded attendance dashboard.
///
/// Persisted as the raw JSON payload so it rehydrates verbatim, letting the
/// presence/dashboard screens render offline (last-known today status + recap)
/// instead of blocking on the network. One row per user (`user_id`), so an
/// account only ever reads its own snapshot.
abstract interface class DashboardCacheStore {
  /// Overwrites [userId]'s cached snapshot with [dashboard].
  Future<void> save(int userId, AttendanceDashboardModel dashboard);

  /// Returns [userId]'s cached snapshot, or `null` when nothing is cached yet.
  Future<AttendanceDashboardModel?> read(int userId);
}

class SqfliteDashboardCacheStore implements DashboardCacheStore {
  SqfliteDashboardCacheStore(this._db);

  final Database _db;

  @override
  Future<void> save(int userId, AttendanceDashboardModel dashboard) async {
    await _db.insert(dashboardCacheTable, {
      'user_id': userId,
      'payload': jsonEncode(dashboard.toJson()),
      'cached_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<AttendanceDashboardModel?> read(int userId) async {
    final rows = await _db.query(
      dashboardCacheTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final payload = rows.single['payload'] as String?;
    if (payload == null || payload.isEmpty) return null;

    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) return null;
    return AttendanceDashboardModel.fromJson(decoded);
  }
}
