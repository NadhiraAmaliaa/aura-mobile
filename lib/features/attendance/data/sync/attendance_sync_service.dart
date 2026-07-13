import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../local/attendance_queue_entry.dart';
import '../local/attendance_queue_store.dart';

/// How a single sync attempt was resolved.
enum SyncOutcome {
  /// The backend accepted the event.
  synced,

  /// The backend terminally rejected the event (e.g. outside the office
  /// radius, stale capture). Retrying would not help.
  rejected,

  /// A transient failure (offline, timeout, 5xx, auth). The event stays
  /// pending and will be retried on the next flush.
  retryLater,
}

/// Aggregate result of flushing the queue.
class SyncSummary {
  const SyncSummary({
    required this.synced,
    required this.rejected,
    required this.stillPending,
  });

  final int synced;
  final int rejected;
  final int stillPending;
}

/// Drives the "always enqueue, then sync" flow.
///
/// Every captured action is persisted first ([enqueue]) so it survives an app
/// kill or network outage, then an immediate sync is attempted. [flush] retries
/// everything still pending, oldest first, and stops early on the first
/// transient failure to avoid hammering an unreachable network.
class AttendanceSyncService {
  AttendanceSyncService(
    this._store,
    this._repository, {
    this.clock = DateTime.now,
  });

  final AttendanceQueueStore _store;
  final AttendanceRepository _repository;

  /// Injectable clock, so tests can assert deterministic `syncedAt` values.
  final DateTime Function() clock;

  /// Persists [entry], then attempts to sync it once. Returns the entry with
  /// its resolved [AttendanceQueueEntry.status].
  Future<AttendanceQueueEntry> enqueue(AttendanceQueueEntry entry) async {
    await _store.save(entry);
    return _attempt(entry);
  }

  /// Attempts to sync every pending entry owned by [userId], oldest first,
  /// stopping at the first transient failure.
  Future<SyncSummary> flush(int userId) async {
    final pending = await _store.pendingEntries(userId);
    var synced = 0;
    var rejected = 0;

    for (var i = 0; i < pending.length; i++) {
      final updated = await _attempt(pending[i]);
      switch (updated.status) {
        case QueuedEventStatus.synced:
          synced++;
        case QueuedEventStatus.rejected:
          rejected++;
        case QueuedEventStatus.pending:
          // Transient failure — stop; the rest are almost certainly blocked too.
          return SyncSummary(
            synced: synced,
            rejected: rejected,
            stillPending: pending.length - synced - rejected,
          );
      }
    }

    return SyncSummary(
      synced: synced,
      rejected: rejected,
      stillPending: pending.length - synced - rejected,
    );
  }

  Future<AttendanceQueueEntry> _attempt(AttendanceQueueEntry entry) async {
    final result = await _repository.syncEvent(entry);
    final attempts = entry.attempts + 1;

    final AttendanceQueueEntry updated = switch (result) {
      Success() => entry.copyWith(
        status: QueuedEventStatus.synced,
        syncedAt: clock(),
        attempts: attempts,
        lastError: null,
      ),
      Failure(:final exception) => switch (_classify(exception)) {
        SyncOutcome.rejected => entry.copyWith(
          status: QueuedEventStatus.rejected,
          attempts: attempts,
          lastError: exception.message,
        ),
        _ => entry.copyWith(attempts: attempts, lastError: exception.message),
      },
    };

    await _store.save(updated);
    return updated;
  }

  SyncOutcome _classify(AppException exception) => switch (exception) {
    ValidationException() => SyncOutcome.rejected,
    ServerException(:final statusCode)
        when _isTerminalClientError(statusCode) =>
      SyncOutcome.rejected,
    _ => SyncOutcome.retryLater,
  };

  /// A 4xx (other than auth/rate-limit) means the request itself is invalid —
  /// retrying the same payload will keep failing, so treat it as terminal.
  bool _isTerminalClientError(int? status) =>
      status != null &&
      status >= 400 &&
      status < 500 &&
      status != 401 &&
      status != 429;
}
