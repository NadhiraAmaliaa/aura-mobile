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
  Future<AttendanceDashboardEnvelope> dashboard(@Query('month') String? month);

  /// A page of past attendance records, newest first. [page] is 1-based;
  /// [perPage] is clamped server-side (max 50).
  @GET('/attendance/history')
  Future<AttendanceHistoryEnvelope> history(
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  );

  /// Record today's check-in. Body: `work_mode` plus optional `latitude` /
  /// `longitude`. Returns the created record.
  @POST('/attendance/check-in')
  Future<AttendanceMutationEnvelope> checkIn(@Body() Map<String, dynamic> body);

  /// Record today's check-out. Body: optional `latitude` / `longitude`.
  /// Returns the updated record.
  @POST('/attendance/check-out')
  Future<AttendanceMutationEnvelope> checkOut(
    @Body() Map<String, dynamic> body,
  );

  /// The active office locations for WFO geofence pre-validation. Coordinates
  /// are numeric; radius is in metres.
  @GET('/attendance/locations')
  Future<AttendanceLocationsEnvelope> locations();
}
