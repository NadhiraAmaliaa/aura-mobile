// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    _AttendanceModel(
      id: (json['id'] as num).toInt(),
      attendanceDate: json['attendance_date'] as String?,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      checkInLatitude: json['check_in_latitude'] as String?,
      checkInLongitude: json['check_in_longitude'] as String?,
      checkOutLatitude: json['check_out_latitude'] as String?,
      checkOutLongitude: json['check_out_longitude'] as String?,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      workMode: json['work_mode'] as String?,
      workModeLabel: json['work_mode_label'] as String?,
    );

Map<String, dynamic> _$AttendanceModelToJson(_AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attendance_date': instance.attendanceDate,
      'check_in_time': instance.checkInTime,
      'check_out_time': instance.checkOutTime,
      'check_in_latitude': instance.checkInLatitude,
      'check_in_longitude': instance.checkInLongitude,
      'check_out_latitude': instance.checkOutLatitude,
      'check_out_longitude': instance.checkOutLongitude,
      'status': instance.status,
      'status_label': instance.statusLabel,
      'work_mode': instance.workMode,
      'work_mode_label': instance.workModeLabel,
    };

_WorkHoursModel _$WorkHoursModelFromJson(Map<String, dynamic> json) =>
    _WorkHoursModel(
      start: json['start'] as String?,
      end: json['end'] as String?,
    );

Map<String, dynamic> _$WorkHoursModelToJson(_WorkHoursModel instance) =>
    <String, dynamic>{'start': instance.start, 'end': instance.end};

_TodayLeaveModel _$TodayLeaveModelFromJson(Map<String, dynamic> json) =>
    _TodayLeaveModel(
      type: json['type'] as String,
      typeLabel: json['type_label'] as String,
    );

Map<String, dynamic> _$TodayLeaveModelToJson(_TodayLeaveModel instance) =>
    <String, dynamic>{'type': instance.type, 'type_label': instance.typeLabel};

_AttendanceTodayModel _$AttendanceTodayModelFromJson(
  Map<String, dynamic> json,
) => _AttendanceTodayModel(
  date: json['date'] as String,
  isWorkingDay: json['is_working_day'] as bool,
  workHours: WorkHoursModel.fromJson(
    json['work_hours'] as Map<String, dynamic>,
  ),
  attendance: json['attendance'] == null
      ? null
      : AttendanceModel.fromJson(json['attendance'] as Map<String, dynamic>),
  leave: json['leave'] == null
      ? null
      : TodayLeaveModel.fromJson(json['leave'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AttendanceTodayModelToJson(
  _AttendanceTodayModel instance,
) => <String, dynamic>{
  'date': instance.date,
  'is_working_day': instance.isWorkingDay,
  'work_hours': instance.workHours,
  'attendance': instance.attendance,
  'leave': instance.leave,
};

_MonthlySummaryModel _$MonthlySummaryModelFromJson(Map<String, dynamic> json) =>
    _MonthlySummaryModel(
      month: json['month'] as String,
      hadir: (json['hadir'] as num?)?.toInt() ?? 0,
      terlambat: (json['terlambat'] as num?)?.toInt() ?? 0,
      izin: (json['izin'] as num?)?.toInt() ?? 0,
      sakit: (json['sakit'] as num?)?.toInt() ?? 0,
      dinas: (json['dinas'] as num?)?.toInt() ?? 0,
      tidakAbsen: (json['tidak_absen'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MonthlySummaryModelToJson(
  _MonthlySummaryModel instance,
) => <String, dynamic>{
  'month': instance.month,
  'hadir': instance.hadir,
  'terlambat': instance.terlambat,
  'izin': instance.izin,
  'sakit': instance.sakit,
  'dinas': instance.dinas,
  'tidak_absen': instance.tidakAbsen,
};

_AttendanceDashboardModel _$AttendanceDashboardModelFromJson(
  Map<String, dynamic> json,
) => _AttendanceDashboardModel(
  today: AttendanceTodayModel.fromJson(json['today'] as Map<String, dynamic>),
  summary: MonthlySummaryModel.fromJson(
    json['summary'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AttendanceDashboardModelToJson(
  _AttendanceDashboardModel instance,
) => <String, dynamic>{'today': instance.today, 'summary': instance.summary};

_AttendanceDashboardEnvelope _$AttendanceDashboardEnvelopeFromJson(
  Map<String, dynamic> json,
) => _AttendanceDashboardEnvelope(
  data: AttendanceDashboardModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AttendanceDashboardEnvelopeToJson(
  _AttendanceDashboardEnvelope instance,
) => <String, dynamic>{'data': instance.data};

_PaginationModel _$PaginationModelFromJson(Map<String, dynamic> json) =>
    _PaginationModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      hasMore: json['has_more'] as bool? ?? false,
    );

Map<String, dynamic> _$PaginationModelToJson(_PaginationModel instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'last_page': instance.lastPage,
      'has_more': instance.hasMore,
    };

_AttendanceHistoryModel _$AttendanceHistoryModelFromJson(
  Map<String, dynamic> json,
) => _AttendanceHistoryModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AttendanceModel>[],
  pagination: PaginationModel.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AttendanceHistoryModelToJson(
  _AttendanceHistoryModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'pagination': instance.pagination,
};

_AttendanceHistoryEnvelope _$AttendanceHistoryEnvelopeFromJson(
  Map<String, dynamic> json,
) => _AttendanceHistoryEnvelope(
  data: AttendanceHistoryModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AttendanceHistoryEnvelopeToJson(
  _AttendanceHistoryEnvelope instance,
) => <String, dynamic>{'data': instance.data};

_AttendanceMutationEnvelope _$AttendanceMutationEnvelopeFromJson(
  Map<String, dynamic> json,
) => _AttendanceMutationEnvelope(
  message: json['message'] as String,
  data: AttendanceModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AttendanceMutationEnvelopeToJson(
  _AttendanceMutationEnvelope instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

_AttendanceLocationModel _$AttendanceLocationModelFromJson(
  Map<String, dynamic> json,
) => _AttendanceLocationModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  radius: (json['radius'] as num).toInt(),
);

Map<String, dynamic> _$AttendanceLocationModelToJson(
  _AttendanceLocationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'radius': instance.radius,
};

_AttendanceLocationsEnvelope _$AttendanceLocationsEnvelopeFromJson(
  Map<String, dynamic> json,
) => _AttendanceLocationsEnvelope(
  data:
      (json['data'] as List<dynamic>?)
          ?.map(
            (e) => AttendanceLocationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <AttendanceLocationModel>[],
);

Map<String, dynamic> _$AttendanceLocationsEnvelopeToJson(
  _AttendanceLocationsEnvelope instance,
) => <String, dynamic>{'data': instance.data};
