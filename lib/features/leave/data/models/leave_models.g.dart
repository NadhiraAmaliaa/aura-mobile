// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaveRequestModel _$LeaveRequestModelFromJson(Map<String, dynamic> json) =>
    _LeaveRequestModel(
      id: (json['id'] as num).toInt(),
      requestNumber: json['request_number'] as String,
      type: json['type'] as String,
      typeLabel: json['type_label'] as String,
      reason: json['reason'] as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      totalDays: (json['total_days'] as num?)?.toInt(),
      contactPhone: json['contact_phone'] as String?,
      address: json['address'] as String?,
      evidenceUrl: json['evidence_url'] as String?,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      adminNote: json['admin_note'] as String?,
      approverName: json['approver_name'] as String?,
      approvedAt: json['approved_at'] as String?,
      canDownloadPdf: json['can_download_pdf'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$LeaveRequestModelToJson(_LeaveRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request_number': instance.requestNumber,
      'type': instance.type,
      'type_label': instance.typeLabel,
      'reason': instance.reason,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'total_days': instance.totalDays,
      'contact_phone': instance.contactPhone,
      'address': instance.address,
      'evidence_url': instance.evidenceUrl,
      'status': instance.status,
      'status_label': instance.statusLabel,
      'admin_note': instance.adminNote,
      'approver_name': instance.approverName,
      'approved_at': instance.approvedAt,
      'can_download_pdf': instance.canDownloadPdf,
      'created_at': instance.createdAt,
    };

_LeavePaginationModel _$LeavePaginationModelFromJson(
  Map<String, dynamic> json,
) => _LeavePaginationModel(
  currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
  perPage: (json['per_page'] as num?)?.toInt() ?? 15,
  total: (json['total'] as num?)?.toInt() ?? 0,
  lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
  hasMore: json['has_more'] as bool? ?? false,
);

Map<String, dynamic> _$LeavePaginationModelToJson(
  _LeavePaginationModel instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'per_page': instance.perPage,
  'total': instance.total,
  'last_page': instance.lastPage,
  'has_more': instance.hasMore,
};

_LeaveListModel _$LeaveListModelFromJson(Map<String, dynamic> json) =>
    _LeaveListModel(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => LeaveRequestModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <LeaveRequestModel>[],
      pagination: LeavePaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$LeaveListModelToJson(_LeaveListModel instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

_LeaveListEnvelope _$LeaveListEnvelopeFromJson(Map<String, dynamic> json) =>
    _LeaveListEnvelope(
      data: LeaveListModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LeaveListEnvelopeToJson(_LeaveListEnvelope instance) =>
    <String, dynamic>{'data': instance.data};

_LeaveDetailEnvelope _$LeaveDetailEnvelopeFromJson(Map<String, dynamic> json) =>
    _LeaveDetailEnvelope(
      data: LeaveRequestModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LeaveDetailEnvelopeToJson(
  _LeaveDetailEnvelope instance,
) => <String, dynamic>{'data': instance.data};
