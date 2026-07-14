import 'dart:io';

import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/features/attendance/data/local/office_config_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late SqfliteOfficeConfigCacheStore store;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await openAppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    store = SqfliteOfficeConfigCacheStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  const pusat = AttendanceLocationModel(
    id: 1,
    name: 'Kantor Pusat',
    latitude: 3.5952,
    longitude: 98.6722,
    radius: 200,
  );
  const cabang = AttendanceLocationModel(
    id: 2,
    name: 'Kantor Cabang',
    latitude: 3.6,
    longitude: 98.68,
    radius: 150,
  );

  test('returns an empty list when nothing is cached', () async {
    expect(await store.all(), isEmpty);
  });

  test('stores and reads offices back sorted by name', () async {
    await store.replaceAll([pusat, cabang]);

    final cached = await store.all();

    expect(cached.map((o) => o.name), ['Kantor Cabang', 'Kantor Pusat']);
    final first = cached.first;
    expect(first.id, 2);
    expect(first.latitude, 3.6);
    expect(first.longitude, 98.68);
    expect(first.radius, 150);
  });

  test('replaceAll fully replaces the previous cache', () async {
    await store.replaceAll([pusat, cabang]);
    await store.replaceAll([pusat]);

    final cached = await store.all();

    expect(cached, hasLength(1));
    expect(cached.single.id, 1);
  });

  test('is not initialized before any successful sync', () async {
    expect(await store.isInitialized(), isFalse);
  });

  test('a successful sync marks the configuration initialized', () async {
    await store.replaceAll([pusat]);

    expect(await store.isInitialized(), isTrue);
  });

  test(
    'an empty sync clears stale office rows but stays initialized',
    () async {
      await store.replaceAll([pusat, cabang]);

      // The admin removed every active office; the server now returns [].
      await store.replaceAll(const []);

      expect(await store.all(), isEmpty);
      // The authoritative empty result is still a completed sync.
      expect(await store.isInitialized(), isTrue);
    },
  );

  test(
    'an empty-but-initialized configuration survives an app restart',
    () async {
      final dir = await Directory.systemTemp.createTemp('office_cache_test');
      addTearDown(() => dir.delete(recursive: true));
      final path = p.join(dir.path, 'aura_restart.db');

      // First launch: a successful empty response is persisted to disk.
      final firstDb = await openAppDatabase(
        factory: databaseFactoryFfi,
        path: path,
      );
      await SqfliteOfficeConfigCacheStore(firstDb).replaceAll(const []);
      await firstDb.close();

      // Next (offline) launch reopens the same file-backed database.
      final secondDb = await openAppDatabase(
        factory: databaseFactoryFfi,
        path: path,
      );
      addTearDown(() => secondDb.close());
      final reopened = SqfliteOfficeConfigCacheStore(secondDb);

      expect(await reopened.isInitialized(), isTrue);
      expect(await reopened.all(), isEmpty);
    },
  );
}
