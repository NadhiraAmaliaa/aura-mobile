import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/features/attendance/data/local/office_config_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
