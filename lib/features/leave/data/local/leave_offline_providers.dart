import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import 'leave_list_cache_store.dart';

part 'leave_offline_providers.g.dart';

/// The cached leave-list store, backed by the shared app database.
///
/// Isolated to the leave feature; it shares only the single on-device database,
/// not the attendance offline queue's behavior.
@Riverpod(keepAlive: true)
Future<LeaveListCacheStore> leaveListCacheStore(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return SqfliteLeaveListCacheStore(db);
}
