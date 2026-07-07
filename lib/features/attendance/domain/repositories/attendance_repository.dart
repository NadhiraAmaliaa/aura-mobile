import '../../../../core/network/api_result.dart';
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

  /// Records today's check-in and returns the created record.
  Future<ApiResult<AttendanceModel>> checkIn({
    required String workMode,
    double? latitude,
    double? longitude,
  });

  /// Records today's check-out and returns the updated record.
  Future<ApiResult<AttendanceModel>> checkOut({
    double? latitude,
    double? longitude,
  });
}
