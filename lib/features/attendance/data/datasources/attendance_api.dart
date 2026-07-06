import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/attendance_models.dart';

part 'attendance_api.g.dart';

/// Typed attendance endpoints. Paths are relative to the versioned base URL
/// (`.../api/v1`) and start with a leading slash so Dio's string-concatenation
/// join preserves the `v1` segment (see architecture doc §7).
@RestApi()
abstract class AttendanceApi {
  factory AttendanceApi(Dio dio, {String baseUrl}) = _AttendanceApi;

  /// Today's snapshot plus the monthly recap. [month] is an optional `YYYY-MM`
  /// filter for the recap; when null the backend uses the current month.
  @GET('/attendance/dashboard')
  Future<AttendanceDashboardEnvelope> dashboard(
    @Query('month') String? month,
  );
}
