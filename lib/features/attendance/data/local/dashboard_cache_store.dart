import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/attendance_models.dart';

/// Local cache of the last successfully loaded attendance dashboard.
///
/// Persisted as the raw JSON payload so it rehydrates verbatim, letting the
/// presence/dashboard screens render offline (last-known today status + recap)
/// instead of blocking on the network. A single row (`id = 1`) is kept.
abstract interface class DashboardCacheStore {
  /// Overwrites the cached snapshot with [dashboard].
  Future<void> save(AttendanceDashboardModel dashboard);

  /// Returns the cached snapshot, or `null` when nothing is cached yet.
  Future<AttendanceDashboardModel?> read();
}

class SqfliteDashboardCacheStore implements DashboardCacheStore {
  SqfliteDashboardCacheStore(this._db);

  final Database _db;

  static const _rowId = 1;

  @override
  Future<void> save(AttendanceDashboardModel dashboard) async {
    await _db.insert(dashboardCacheTable, {
      'id': _rowId,
      'payload': jsonEncode(dashboard.toJson()),
      'cached_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<AttendanceDashboardModel?> read() async {
    final rows = await _db.query(
      dashboardCacheTable,
      where: 'id = ?',
      whereArgs: [_rowId],
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
