import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/leave_models.dart';

part 'leave_api.g.dart';

/// Typed leave-request endpoints. Paths are relative to the versioned base URL
/// (`.../api/v1`) and start with a leading slash so Dio's string-concatenation
/// join preserves the `v1` segment (see architecture doc §7).
///
/// Read-only for now: submission (`POST /leave-requests`) lands in a later
/// slice; approval stays on the admin web app.
@RestApi()
abstract class LeaveApi {
  factory LeaveApi(Dio dio, {String baseUrl}) = _LeaveApi;

  /// A page of the intern's own leave requests, newest first. [filter] narrows
  /// the list to `pending` or `history` (approved + rejected); null returns
  /// all. [page] is 1-based; [perPage] is clamped server-side (max 50).
  @GET('/leave-requests')
  Future<LeaveListEnvelope> list(
    @Query('filter') String? filter,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  );

  /// A single leave request owned by the authenticated intern.
  @GET('/leave-requests/{id}')
  Future<LeaveDetailEnvelope> detail(@Path('id') int id);
}
