import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/connectivity_providers.dart';
import '../../../../shared/utils/captured_at.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/local/attendance_queue_entry.dart';
import '../../data/local/offline_providers.dart';
import '../../data/models/attendance_models.dart';
import '../../data/sync/attendance_sync_service.dart';
import '../../data/sync/sync_providers.dart';
import 'attendance_dashboard_notifier.dart';

part 'attendance_queue_controller.g.dart';

/// Owns the offline attendance queue for the UI.
///
/// Every capture is persisted first, then an immediate sync is attempted
/// ("always enqueue, then sync"). The queue is also flushed automatically
/// whenever connectivity is regained. State is the full list of queued entries
/// owned by the current user, newest first, so the UI can show a pending badge
/// and outcomes.
///
/// The queue is scoped to the authenticated user ([currentUserIdProvider]): a
/// user switch rebuilds this against the new owner, so account B never sees or
/// syncs account A's queued entries.
@Riverpod(keepAlive: true)
class AttendanceQueueController extends _$AttendanceQueueController {
  static const _uuid = Uuid();

  @override
  Future<List<AttendanceQueueEntry>> build() async {
    // Flush automatically when the device regains connectivity.
    ref.listen(connectivityChangesProvider, (_, next) {
      final results = next.asData?.value;
      if (results != null && hasConnectivity(results)) {
        unawaited(flush());
      }
    });

    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const [];

    final store = await ref.watch(attendanceQueueStoreProvider.future);
    return store.allEntries(userId);
  }

  /// Builds a queue entry for a captured action, persists it, and attempts an
  /// immediate sync. Returns the resulting entry so the caller can message the
  /// outcome (synced / still pending / rejected).
  Future<AttendanceQueueEntry> capture({
    required AttendanceEventType type,
    String? workMode,
    double? latitude,
    double? longitude,
    AttendanceLocationModel? office,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw StateError(
        'Cannot capture attendance without an authenticated user.',
      );
    }

    final now = DateTime.now();
    final entry = AttendanceQueueEntry(
      clientEventId: _uuid.v4(),
      userId: userId,
      type: type,
      workMode: workMode,
      latitude: latitude?.toStringAsFixed(7),
      longitude: longitude?.toStringAsFixed(7),
      capturedAt: formatCapturedAt(now),
      officeId: office?.id,
      officeName: office?.name,
      officeLatitude: office?.latitude.toStringAsFixed(7),
      officeLongitude: office?.longitude.toStringAsFixed(7),
      officeRadius: office?.radius,
      createdAt: now,
    );

    final service = await ref.read(attendanceSyncServiceProvider.future);
    final result = await service.enqueue(entry);
    await _refresh();
    if (result.status == QueuedEventStatus.synced) {
      ref.invalidate(attendanceDashboardProvider);
    }
    return result;
  }

  /// Attempts to sync everything still pending for the current user. Safe to
  /// call repeatedly. Returns the [SyncSummary] so the UI can report the outcome.
  Future<SyncSummary> flush() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return const SyncSummary(synced: 0, rejected: 0, stillPending: 0);
    }

    final service = await ref.read(attendanceSyncServiceProvider.future);
    final summary = await service.flush(userId);
    await _refresh();
    if (summary.synced > 0) {
      ref.invalidate(attendanceDashboardProvider);
    }
    return summary;
  }

  Future<void> _refresh() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }
    final store = await ref.read(attendanceQueueStoreProvider.future);
    state = AsyncData(await store.allEntries(userId));
  }
}

/// The number of entries still awaiting sync.
@riverpod
int pendingAttendanceCount(Ref ref) {
  final entries =
      ref.watch(attendanceQueueControllerProvider).asData?.value ??
      const <AttendanceQueueEntry>[];
  return entries
      .where((entry) => entry.status == QueuedEventStatus.pending)
      .length;
}

/// Today's still-pending check-in / check-out actions, derived from the local
/// queue. Lets the presence screen reflect an offline capture immediately (so a
/// user can't double-queue a check-in, and can queue a check-out afterwards)
/// without waiting for the server-backed dashboard.
@riverpod
PendingAttendanceActions pendingAttendanceActions(Ref ref) {
  final entries =
      ref.watch(attendanceQueueControllerProvider).asData?.value ??
      const <AttendanceQueueEntry>[];
  final now = DateTime.now();

  bool isToday(DateTime moment) =>
      moment.year == now.year &&
      moment.month == now.month &&
      moment.day == now.day;

  final todaysPending = entries.where(
    (entry) =>
        entry.status == QueuedEventStatus.pending && isToday(entry.createdAt),
  );

  String? checkInWorkMode;
  var hasCheckIn = false;
  var hasCheckOut = false;
  for (final entry in todaysPending) {
    switch (entry.type) {
      case AttendanceEventType.checkIn:
        hasCheckIn = true;
        checkInWorkMode ??= entry.workMode;
      case AttendanceEventType.checkOut:
        hasCheckOut = true;
    }
  }

  return PendingAttendanceActions(
    hasCheckIn: hasCheckIn,
    hasCheckOut: hasCheckOut,
    checkInWorkMode: checkInWorkMode,
  );
}

/// Snapshot of today's queued (not-yet-synced) attendance actions.
class PendingAttendanceActions {
  const PendingAttendanceActions({
    required this.hasCheckIn,
    required this.hasCheckOut,
    required this.checkInWorkMode,
  });

  /// A check-in is queued for today.
  final bool hasCheckIn;

  /// A check-out is queued for today.
  final bool hasCheckOut;

  /// The work mode of the queued check-in (needed to gate an offline WFO
  /// check-out), or `null` when none is pending.
  final String? checkInWorkMode;
}
