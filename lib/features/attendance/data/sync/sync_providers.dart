import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/attendance_providers.dart';
import '../../data/local/offline_providers.dart';
import '../../data/sync/attendance_sync_service.dart';

part 'sync_providers.g.dart';

/// The offline attendance sync engine, wired to the local queue store, the
/// network repository and the dashboard cache it updates after each successful
/// sync.
@Riverpod(keepAlive: true)
Future<AttendanceSyncService> attendanceSyncService(Ref ref) async {
  final store = await ref.watch(attendanceQueueStoreProvider.future);
  final dashboardCache = await ref.watch(dashboardCacheStoreProvider.future);
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceSyncService(
    store,
    repository,
    dashboardCache: dashboardCache,
  );
}
