import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import 'attendance_queue_store.dart';
import 'dashboard_cache_store.dart';
import 'office_config_cache_store.dart';

part 'offline_providers.g.dart';

/// The offline attendance queue store, backed by the shared app database.
@Riverpod(keepAlive: true)
Future<AttendanceQueueStore> attendanceQueueStore(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return SqfliteAttendanceQueueStore(db);
}

/// The cached office-configuration store, backed by the shared app database.
@Riverpod(keepAlive: true)
Future<OfficeConfigCacheStore> officeConfigCacheStore(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return SqfliteOfficeConfigCacheStore(db);
}

/// The cached attendance-dashboard store, backed by the shared app database.
@Riverpod(keepAlive: true)
Future<DashboardCacheStore> dashboardCacheStore(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return SqfliteDashboardCacheStore(db);
}
