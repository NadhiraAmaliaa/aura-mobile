import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/attendance_models.dart';

/// Local cache of the active office locations.
///
/// Refreshed whenever the app successfully loads locations online, so an
/// offline check-in can still resolve the office it is standing in and freeze
/// the geofence snapshot (id/name/lat/lng/radius) the backend validates against.
abstract interface class OfficeConfigCacheStore {
  /// Replaces the entire cached set with [offices] and marks the office
  /// configuration as synced. An empty [offices] list is valid data: it clears
  /// the office rows yet keeps the "initialized" marker.
  Future<void> replaceAll(List<AttendanceLocationModel> offices);

  /// Whether the office configuration has been fetched successfully at least
  /// once. Distinguishes an authoritative *empty* config (initialized, no
  /// offices) from a cold cache that has never been fetched.
  Future<bool> isInitialized();

  /// Returns the cached offices, or an empty list when nothing is cached yet.
  Future<List<AttendanceLocationModel>> all();
}

class SqfliteOfficeConfigCacheStore implements OfficeConfigCacheStore {
  SqfliteOfficeConfigCacheStore(this._db);

  final Database _db;

  @override
  Future<void> replaceAll(List<AttendanceLocationModel> offices) async {
    final cachedAt = DateTime.now().toIso8601String();
    await _db.transaction((txn) async {
      await txn.delete(officeConfigCacheTable);
      for (final office in offices) {
        await txn.insert(officeConfigCacheTable, {
          'id': office.id,
          'name': office.name,
          'latitude': office.latitude,
          'longitude': office.longitude,
          'radius': office.radius,
          'cached_at': cachedAt,
        });
      }
      // Stamp the sync marker in the same transaction so an empty-but-valid
      // response still counts as an initialized configuration.
      await txn.insert(officeConfigMetaTable, {
        'id': 1,
        'synced_at': cachedAt,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  @override
  Future<bool> isInitialized() async {
    final rows = await _db.query(
      officeConfigMetaTable,
      where: 'id = 1',
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<List<AttendanceLocationModel>> all() async {
    final rows = await _db.query(officeConfigCacheTable, orderBy: 'name ASC');
    return rows
        .map(
          (row) => AttendanceLocationModel(
            id: row['id']! as int,
            name: row['name']! as String,
            latitude: (row['latitude']! as num).toDouble(),
            longitude: (row['longitude']! as num).toDouble(),
            radius: row['radius']! as int,
          ),
        )
        .toList();
  }
}
