import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The single on-device SQLite database for AURA Mobile.
///
/// Currently backs the offline attendance queue (Phase 2): captured check-in /
/// check-out events are persisted here first, then synced to the backend, so an
/// action survives an app kill or a network outage. The active office
/// configuration is cached alongside it so an offline capture can freeze the
/// geofence snapshot the backend expects.
///
/// [openAppDatabase] accepts an explicit [factory] and [path] so tests can open
/// an in-memory database via `sqflite_common_ffi`; production uses the default
/// platform factory and the app's databases directory.
const _databaseName = 'aura_mobile.db';
const _databaseVersion = 2;

/// Queued attendance events awaiting (or done with) sync.
const attendanceQueueTable = 'attendance_queue';

/// Cached active office locations used to freeze the offline geofence snapshot.
const officeConfigCacheTable = 'office_config_cache';

/// Cached last-known attendance dashboard payload, so the presence/dashboard
/// screens render offline instead of waiting on the network.
const dashboardCacheTable = 'dashboard_cache';

Future<Database> openAppDatabase({DatabaseFactory? factory, String? path}) async {
  final resolvedFactory = factory ?? databaseFactory;
  final resolvedPath = path ?? await _defaultDatabasePath();

  return resolvedFactory.openDatabase(
    resolvedPath,
    options: OpenDatabaseOptions(
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    ),
  );
}

Future<String> _defaultDatabasePath() async {
  final directory = await getDatabasesPath();
  return p.join(directory, _databaseName);
}

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE $attendanceQueueTable (
      client_event_id   TEXT PRIMARY KEY,
      event_type        TEXT NOT NULL,
      work_mode         TEXT,
      latitude          TEXT,
      longitude         TEXT,
      captured_at       TEXT NOT NULL,
      office_id         INTEGER,
      office_name       TEXT,
      office_latitude   TEXT,
      office_longitude  TEXT,
      office_radius     INTEGER,
      auto_time_enabled INTEGER,
      status            TEXT NOT NULL DEFAULT 'pending',
      attempts          INTEGER NOT NULL DEFAULT 0,
      last_error        TEXT,
      created_at        TEXT NOT NULL,
      synced_at         TEXT
    )
  ''');

  await db.execute(
    'CREATE INDEX idx_${attendanceQueueTable}_status_created '
    'ON $attendanceQueueTable (status, created_at)',
  );

  await db.execute('''
    CREATE TABLE $officeConfigCacheTable (
      id         INTEGER PRIMARY KEY,
      name       TEXT NOT NULL,
      latitude   REAL NOT NULL,
      longitude  REAL NOT NULL,
      radius     INTEGER NOT NULL,
      cached_at  TEXT NOT NULL
    )
  ''');

  await _createDashboardCacheTable(db);
}

/// Applies incremental schema migrations. Each guarded block runs only when the
/// installed schema predates the feature, so existing offline data is kept.
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _createDashboardCacheTable(db);
  }
}

/// Single-row (`id = 1`) cache of the latest attendance dashboard, stored as
/// the JSON payload the API returned so it can be rehydrated verbatim offline.
Future<void> _createDashboardCacheTable(Database db) async {
  await db.execute('''
    CREATE TABLE $dashboardCacheTable (
      id         INTEGER PRIMARY KEY,
      payload    TEXT NOT NULL,
      cached_at  TEXT NOT NULL
    )
  ''');
}
