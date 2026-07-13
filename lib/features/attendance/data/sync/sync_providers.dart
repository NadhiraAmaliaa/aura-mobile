import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/attendance_providers.dart';
import '../../data/local/offline_providers.dart';
import '../../data/sync/attendance_sync_service.dart';

part 'sync_providers.g.dart';

/// The offline attendance sync engine, wired to the local queue store and the
/// network repository.
@Riverpod(keepAlive: true)
Future<AttendanceSyncService> attendanceSyncService(Ref ref) async {
  final store = await ref.watch(attendanceQueueStoreProvider.future);
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceSyncService(store, repository);
}
