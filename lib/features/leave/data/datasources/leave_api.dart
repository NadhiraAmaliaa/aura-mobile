import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/leave_models.dart';

part 'leave_api.g.dart';

/// Typed leave-request endpoints. Paths are relative to the versioned base URL
/// (`.../api/v1`) and start with a leading slash so Dio's string-concatenation
/// join preserves the `v1` segment (see architecture doc §7).
///
/// Submission is multipart (evidence file); approval stays on the admin web
/// app. The approved-request PDF is streamed by a separate controller and is
/// fetched via [FileDownloadService], not through this typed client.
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

  /// Submit a new leave request. Dates are `yyyy-MM-dd`; [evidence] is required
  /// for `sakit` and optional for `izin` (enforced server-side by the shared
  /// form request). Returns the created record wrapped in `data`.
  @POST('/leave-requests')
  @MultiPart()
  Future<LeaveDetailEnvelope> create({
    @Part(name: 'type') required String type,
    @Part(name: 'reason') required String reason,
    @Part(name: 'start_date') required String startDate,
    @Part(name: 'end_date') required String endDate,
    @Part(name: 'contact_phone') String? contactPhone,
    @Part(name: 'address') String? address,
    @Part(name: 'evidence') File? evidence,
  });
}
