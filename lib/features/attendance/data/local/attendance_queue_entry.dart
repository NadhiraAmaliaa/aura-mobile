import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_queue_entry.freezed.dart';

/// Whether a queued event is a check-in or a check-out.
enum AttendanceEventType {
  checkIn('check_in'),
  checkOut('check_out');

  const AttendanceEventType(this.wire);

  /// The value persisted locally and mapped to the backend endpoint.
  final String wire;

  static AttendanceEventType fromWire(String value) =>
      values.firstWhere((type) => type.wire == value);
}

/// Sync lifecycle of a queued event.
enum QueuedEventStatus {
  /// Not yet accepted by the backend; will be retried.
  pending('pending'),

  /// Accepted by the backend (HTTP 200/201).
  synced('synced'),

  /// Terminally rejected by the backend (e.g. 409/422); retrying won't help.
  rejected('rejected');

  const QueuedEventStatus(this.wire);

  final String wire;

  static QueuedEventStatus fromWire(String value) =>
      values.firstWhere((status) => status.wire == value);
}

/// A single captured attendance action persisted in the local offline queue.
///
/// [capturedAt] is a pre-formatted ISO-8601 string with an explicit UTC offset
/// (see `formatCapturedAt`) and is sent verbatim to the backend. The `office*`
/// fields are the frozen geofence snapshot captured at the moment of the action
/// so the backend can validate WFO presence against the office configuration
/// that was active on-device, independent of later admin changes.
@freezed
abstract class AttendanceQueueEntry with _$AttendanceQueueEntry {
  const factory AttendanceQueueEntry({
    required String clientEventId,
    required AttendanceEventType type,
    int? userId,
    String? workMode,
    String? latitude,
    String? longitude,
    required String capturedAt,
    int? officeId,
    String? officeName,
    String? officeLatitude,
    String? officeLongitude,
    int? officeRadius,
    bool? autoTimeEnabled,
    @Default(QueuedEventStatus.pending) QueuedEventStatus status,
    @Default(0) int attempts,
    String? lastError,
    required DateTime createdAt,
    DateTime? syncedAt,
  }) = _AttendanceQueueEntry;
}
