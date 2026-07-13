import '../../../../core/network/api_result.dart';
import '../../data/local/attendance_queue_entry.dart';
import '../../data/models/attendance_models.dart';

/// Abstract attendance boundary — the seam the presentation layer depends on
/// and the point tests override with a fake.
///
/// Per architecture doc §3.1, `attendance` is one of the two features that
/// keeps a domain boundary. As with `auth`, the data DTOs cross this boundary
/// directly rather than being mirrored into separate entities (documented
/// deviation) — the abstract repository preserves the testing seam.
abstract interface class AttendanceRepository {
  /// Loads the attendance dashboard. [month] is an optional `YYYY-MM` filter
  /// for the monthly recap; null means the current month.
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month});

  /// Loads one page of attendance history, newest first. [page] is 1-based.
  Future<ApiResult<AttendanceHistoryModel>> history({int? page, int? perPage});

  /// Sends a locally-queued attendance [entry] to the backend, carrying the
  /// offline metadata (`captured_at`, idempotency key, frozen office snapshot).
  /// Dispatches to the check-in or check-out endpoint based on the entry type.
  Future<ApiResult<AttendanceModel>> syncEvent(AttendanceQueueEntry entry);

  /// Loads the active office locations for WFO geofence pre-validation.
  Future<ApiResult<List<AttendanceLocationModel>>> locations();
}
