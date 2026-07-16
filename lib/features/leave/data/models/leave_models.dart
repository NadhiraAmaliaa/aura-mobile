import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_models.freezed.dart';
part 'leave_models.g.dart';

/// A single leave request (izin / sakit), mirroring the backend
/// `LeaveRequestResource`.
///
/// Dates are ISO `yyyy-MM-dd` strings and labels are pre-resolved to their
/// Indonesian form by the server. [evidenceUrl] is the public-disk URL of the
/// uploaded attachment (or null). [canDownloadPdf] mirrors the backend rule
/// that only approved requests have a printable letter.
@freezed
abstract class LeaveRequestModel with _$LeaveRequestModel {
  const factory LeaveRequestModel({
    required int id,
    @JsonKey(name: 'request_number') required String requestNumber,
    required String type,
    @JsonKey(name: 'type_label') required String typeLabel,
    required String reason,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'total_days') int? totalDays,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    String? address,
    @JsonKey(name: 'evidence_url') String? evidenceUrl,
    required String status,
    @JsonKey(name: 'status_label') required String statusLabel,
    @JsonKey(name: 'admin_note') String? adminNote,
    @JsonKey(name: 'approver_name') String? approverName,
    @JsonKey(name: 'approved_at') String? approvedAt,
    @JsonKey(name: 'can_download_pdf') @Default(false) bool canDownloadPdf,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _LeaveRequestModel;

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestModelFromJson(json);
}

/// Pagination metadata for a page of leave requests.
///
/// Defined locally rather than reusing the attendance feature's identical
/// block, so the two features stay decoupled (feature-first isolation).
@freezed
abstract class LeavePaginationModel with _$LeavePaginationModel {
  const factory LeavePaginationModel({
    @JsonKey(name: 'current_page') @Default(1) int currentPage,
    @JsonKey(name: 'per_page') @Default(15) int perPage,
    @Default(0) int total,
    @JsonKey(name: 'last_page') @Default(1) int lastPage,
    @JsonKey(name: 'has_more') @Default(false) bool hasMore,
  }) = _LeavePaginationModel;

  factory LeavePaginationModel.fromJson(Map<String, dynamic> json) =>
      _$LeavePaginationModelFromJson(json);
}

/// One page of leave requests: the items plus pagination metadata.
@freezed
abstract class LeaveListModel with _$LeaveListModel {
  const factory LeaveListModel({
    @Default(<LeaveRequestModel>[]) List<LeaveRequestModel> items,
    required LeavePaginationModel pagination,
  }) = _LeaveListModel;

  factory LeaveListModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveListModelFromJson(json);
}

/// Envelope for `GET /leave-requests`, wrapping the page in `data`.
@freezed
abstract class LeaveListEnvelope with _$LeaveListEnvelope {
  const factory LeaveListEnvelope({required LeaveListModel data}) =
      _LeaveListEnvelope;

  factory LeaveListEnvelope.fromJson(Map<String, dynamic> json) =>
      _$LeaveListEnvelopeFromJson(json);
}

/// Envelope for `GET /leave-requests/{id}`, wrapping the record in `data`.
@freezed
abstract class LeaveDetailEnvelope with _$LeaveDetailEnvelope {
  const factory LeaveDetailEnvelope({required LeaveRequestModel data}) =
      _LeaveDetailEnvelope;

  factory LeaveDetailEnvelope.fromJson(Map<String, dynamic> json) =>
      _$LeaveDetailEnvelopeFromJson(json);
}
