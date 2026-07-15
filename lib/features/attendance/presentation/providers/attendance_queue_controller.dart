import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/device/device_time_providers.dart';
import '../../../../core/device/device_time_settings.dart';
import '../../../../core/network/connectivity_providers.dart';
import '../../../../shared/utils/captured_at.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/local/attendance_queue_entry.dart';
import '../../data/local/offline_providers.dart';
import '../../data/models/attendance_models.dart';
import '../../data/sync/attendance_sync_service.dart';
import '../../data/sync/sync_providers.dart';
import '../geofence_evaluation.dart';
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
    AttendanceTodayModel? today,
    DateTime? at,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw StateError(
        'Cannot capture attendance without an authenticated user.',
      );
    }

    // Verify the device clock is automatic at the moment of capture, before the
    // event is enqueued. A manual clock can spoof the authoritative captured_at,
    // so an explicit `false` hard-blocks. `null` (non-Android / unverifiable) is
    // allowed and forwarded so the backend applies its own policy.
    final autoTimeEnabled = await ref
        .read(deviceTimeSettingsProvider)
        .isAutomaticEnabled();
    if (autoTimeEnabled == false) {
      throw const AutomaticTimeDisabledException();
    }

    final now = at ?? DateTime.now();

    // Local mirror of the backend's deterministic business rules, enforced
    // *before* the event is written to the queue. These are UX/data-quality
    // guards only — the backend re-checks every one as the final authority —
    // but they stop an invalid capture (duplicate, past-cutoff, out-of-order,
    // outside the office radius) from ever reaching SQLite, online or offline.
    _assertLocalRulesAllow(
      type: type,
      workMode: workMode,
      latitude: latitude,
      longitude: longitude,
      office: office,
      today: today,
      now: now,
    );

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
      autoTimeEnabled: autoTimeEnabled,
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

  /// Throws an [AttendanceRuleException] when a deterministic backend rule would
  /// reject this capture, so the offending event is never enqueued. Rules that
  /// depend on server-only data (leave, internship window, captured_at skew,
  /// idempotent replay, last-write-wins) are intentionally left to the backend.
  void _assertLocalRulesAllow({
    required AttendanceEventType type,
    required String? workMode,
    required double? latitude,
    required double? longitude,
    required AttendanceLocationModel? office,
    required AttendanceTodayModel? today,
    required DateTime now,
  }) {
    final pending = _pendingActionsFrom(state.asData?.value ?? const [], now);
    final serverCheckInTime = today?.attendance?.checkInTime;
    final hasCheckIn = serverCheckInTime != null || pending.hasCheckIn;

    switch (type) {
      case AttendanceEventType.checkIn:
        if (hasCheckIn) {
          throw const AttendanceRuleException(
            'Anda sudah melakukan check in hari ini.',
          );
        }
        final cutoff = _checkInCutoff(today, workMode, now);
        if (cutoff != null && now.isAfter(cutoff.deadline)) {
          throw AttendanceRuleException(
            'Check In untuk mode ini hanya dapat dilakukan hingga pukul '
            '${cutoff.label}. Waktu Check In telah terlewati.',
          );
        }
      case AttendanceEventType.checkOut:
        if (!hasCheckIn) {
          throw const AttendanceRuleException(
            'Anda harus Check In terlebih dahulu sebelum Check Out.',
          );
        }
        final checkInMoment = _checkInMoment(serverCheckInTime, pending, now);
        if (checkInMoment != null && !now.isAfter(checkInMoment)) {
          throw const AttendanceRuleException(
            'Waktu Check Out harus setelah waktu Check In.',
          );
        }
    }

    // WFO snapshot geofence: whenever a frozen office accompanies the capture,
    // the coordinates must still fall inside its radius. Mirrors the backend
    // re-checking the frozen snapshot, so a position outside the office radius
    // never reaches the queue even if the on-screen check is bypassed.
    if (office != null) {
      if (latitude == null || longitude == null) {
        throw const AttendanceRuleException(
          'Lokasi Anda wajib diaktifkan untuk absensi WFO.',
        );
      }
      final verdict = evaluateGeofence([office], latitude, longitude);
      if (verdict is! GeofenceInside) {
        throw AttendanceRuleException(switch (verdict) {
          GeofenceOutside(:final location, :final distanceMeters) =>
            'Anda di luar radius kantor ${location.name} '
                '(${distanceMeters.round()} m).',
          _ => 'Lokasi tidak valid untuk WFO.',
        });
      }
    }
  }

  /// The check-in deadline for [today]'s work day, mirroring the backend
  /// `Attendance::checkInDeadline`. Returns `null` (no deadline) for Dinas, a
  /// non-working day, unknown day state, or a missing end time.
  ({DateTime deadline, String label})? _checkInCutoff(
    AttendanceTodayModel? today,
    String? workMode,
    DateTime now,
  ) {
    if (today == null || !today.isWorkingDay) return null;
    if (workMode == 'dinas') return null;
    final end = today.workHours.end;
    if (end == null || end.isEmpty) return null;
    final parts = end.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final label = end.length >= 5 ? end.substring(0, 5) : end;
    return (deadline: DateTime(now.year, now.month, now.day, h, m), label: label);
  }

  /// The moment today's check-in was recorded — from the server-backed
  /// dashboard time (on [now]'s date) or, offline, the still-pending check-in's
  /// captured timestamp. Used to guard a check-out captured before its check-in.
  DateTime? _checkInMoment(
    String? serverCheckInTime,
    PendingAttendanceActions pending,
    DateTime now,
  ) {
    if (serverCheckInTime != null) {
      final parts = serverCheckInTime.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          return DateTime(now.year, now.month, now.day, h, m);
        }
      }
    }
    return pending.checkInCapturedAt;
  }
}

/// A deterministic attendance business rule was violated locally, before the
/// event reached the queue. Carries the user-facing message (mirroring the
/// backend copy) so the presence screen can show the block dialog directly.
class AttendanceRuleException implements Exception {
  const AttendanceRuleException(this.message);

  /// The user-facing reason the capture was blocked.
  final String message;

  @override
  String toString() => 'AttendanceRuleException: $message';
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
  return _pendingActionsFrom(entries, DateTime.now());
}

/// Derives [PendingAttendanceActions] from a list of queued [entries] as of
/// [now]. Shared by the provider and by the controller's own pre-validation so
/// the controller never has to read a provider that depends on it.
PendingAttendanceActions _pendingActionsFrom(
  List<AttendanceQueueEntry> entries,
  DateTime now,
) {
  bool isToday(DateTime moment) =>
      moment.year == now.year &&
      moment.month == now.month &&
      moment.day == now.day;

  final todaysPending = entries.where(
    (entry) =>
        entry.status == QueuedEventStatus.pending && isToday(entry.createdAt),
  );

  String? checkInWorkMode;
  DateTime? checkInCapturedAt;
  var hasCheckIn = false;
  var hasCheckOut = false;
  for (final entry in todaysPending) {
    switch (entry.type) {
      case AttendanceEventType.checkIn:
        hasCheckIn = true;
        checkInWorkMode ??= entry.workMode;
        checkInCapturedAt ??=
            DateTime.tryParse(entry.capturedAt) ?? entry.createdAt;
      case AttendanceEventType.checkOut:
        hasCheckOut = true;
    }
  }

  return PendingAttendanceActions(
    hasCheckIn: hasCheckIn,
    hasCheckOut: hasCheckOut,
    checkInWorkMode: checkInWorkMode,
    checkInCapturedAt: checkInCapturedAt,
  );
}

/// Snapshot of today's queued (not-yet-synced) attendance actions.
class PendingAttendanceActions {
  const PendingAttendanceActions({
    required this.hasCheckIn,
    required this.hasCheckOut,
    required this.checkInWorkMode,
    this.checkInCapturedAt,
  });

  /// A check-in is queued for today.
  final bool hasCheckIn;

  /// A check-out is queued for today.
  final bool hasCheckOut;

  /// The work mode of the queued check-in (needed to gate an offline WFO
  /// check-out), or `null` when none is pending.
  final String? checkInWorkMode;

  /// When the still-pending check-in was captured, so an offline check-out can
  /// be validated as happening after it. `null` when no check-in is pending.
  final DateTime? checkInCapturedAt;
}
