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
const _databaseVersion = 4;

/// Queued attendance events awaiting (or done with) sync.
const attendanceQueueTable = 'attendance_queue';

/// Cached active office locations used to freeze the offline geofence snapshot.
const officeConfigCacheTable = 'office_config_cache';

/// Single-row metadata for the office cache. Its presence records that the
/// office configuration has been fetched successfully at least once, so an
/// authoritative *empty* office list is distinguishable from "never fetched".
const officeConfigMetaTable = 'office_config_meta';

/// Cached last-known attendance dashboard payload, so the presence/dashboard
/// screens render offline instead of waiting on the network.
const dashboardCacheTable = 'dashboard_cache';

Future<Database> openAppDatabase({
  DatabaseFactory? factory,
  String? path,
}) async {
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
      user_id           INTEGER,
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
    'CREATE INDEX idx_${attendanceQueueTable}_user_status_created '
    'ON $attendanceQueueTable (user_id, status, created_at)',
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

  await _createOfficeConfigMetaTable(db);

  await _createDashboardCacheTable(db);
}

/// Applies incremental schema migrations. Each guarded block runs only when the
/// installed schema predates the feature, so existing offline data is kept.
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _createDashboardCacheTable(db);
  }
  if (oldVersion < 3) {
    // Scope user-specific caches by their owner so one account can never read
    // or sync another account's attendance data.
    await db.execute(
      'ALTER TABLE $attendanceQueueTable ADD COLUMN user_id INTEGER',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${attendanceQueueTable}_user_status_created '
      'ON $attendanceQueueTable (user_id, status, created_at)',
    );
    // The dashboard cache changes from a single global row to one row per user;
    // recreate it (a cache is safe to drop — it repopulates on the next load).
    await db.execute('DROP TABLE IF EXISTS $dashboardCacheTable');
    await _createDashboardCacheTable(db);
  }
  if (oldVersion < 4) {
    await _createOfficeConfigMetaTable(db);
    // An existing install with cached offices was populated by a prior
    // successful fetch, so treat it as already initialized — otherwise an
    // offline upgrade launch would re-fetch, fail, and block the bootstrap.
    final officeRows =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $officeConfigCacheTable'),
        ) ??
        0;
    if (officeRows > 0) {
      await db.insert(officeConfigMetaTable, {
        'id': 1,
        'synced_at': DateTime.now().toIso8601String(),
      });
    }
  }
}

/// Single-row (`id = 1`) marker that the office configuration has been synced
/// at least once. `synced_at` records the last successful sync so an
/// empty-but-valid office list survives restart and offline use.
Future<void> _createOfficeConfigMetaTable(Database db) async {
  await db.execute('''
    CREATE TABLE $officeConfigMetaTable (
      id         INTEGER PRIMARY KEY,
      synced_at  TEXT NOT NULL
    )
  ''');
}

/// Per-user (`user_id` primary key) cache of the latest attendance dashboard,
/// stored as the JSON payload the API returned so it can be rehydrated verbatim
/// offline for its owner only.
Future<void> _createDashboardCacheTable(Database db) async {
  await db.execute('''
    CREATE TABLE $dashboardCacheTable (
      user_id    INTEGER PRIMARY KEY,
      payload    TEXT NOT NULL,
      cached_at  TEXT NOT NULL
    )
  ''');
}
