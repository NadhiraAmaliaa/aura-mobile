import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

part 'database_providers.g.dart';

/// The shared, lazily-opened application [Database].
///
/// Kept alive for the app's lifetime and closed on dispose. Downstream stores
/// depend on this via `ref.watch(appDatabaseProvider.future)`.
@Riverpod(keepAlive: true)
Future<Database> appDatabase(Ref ref) async {
  final db = await openAppDatabase();
  ref.onDispose(db.close);
  return db;
}
