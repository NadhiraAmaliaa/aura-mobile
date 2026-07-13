import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/attendance_models.dart';

/// Local cache of the active office locations.
///
/// Refreshed whenever the app successfully loads locations online, so an
/// offline check-in can still resolve the office it is standing in and freeze
/// the geofence snapshot (id/name/lat/lng/radius) the backend validates against.
abstract interface class OfficeConfigCacheStore {
  /// Replaces the entire cached set with [offices].
  Future<void> replaceAll(List<AttendanceLocationModel> offices);

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
    });
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
