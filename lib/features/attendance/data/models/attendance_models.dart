import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_models.freezed.dart';
part 'attendance_models.g.dart';

/// A single attendance record, mirroring the backend `AttendanceResource`.
///
/// Times are `HH:mm` strings; coordinates are nullable strings because the API
/// emits them from a `decimal:7` cast. They are parsed to numbers only where a
/// map needs them (a later slice).
@freezed
abstract class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    required int id,
    @JsonKey(name: 'attendance_date') String? attendanceDate,
    @JsonKey(name: 'check_in_time') String? checkInTime,
    @JsonKey(name: 'check_out_time') String? checkOutTime,
    @JsonKey(name: 'check_in_latitude') String? checkInLatitude,
    @JsonKey(name: 'check_in_longitude') String? checkInLongitude,
    @JsonKey(name: 'check_out_latitude') String? checkOutLatitude,
    @JsonKey(name: 'check_out_longitude') String? checkOutLongitude,
    required String status,
    @JsonKey(name: 'status_label') required String statusLabel,
    @JsonKey(name: 'work_mode') String? workMode,
    @JsonKey(name: 'work_mode_label') String? workModeLabel,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);
}

/// Configured working hours for a day. Both ends are null on a non-working day.
@freezed
abstract class WorkHoursModel with _$WorkHoursModel {
  const factory WorkHoursModel({String? start, String? end}) = _WorkHoursModel;

  factory WorkHoursModel.fromJson(Map<String, dynamic> json) =>
      _$WorkHoursModelFromJson(json);
}

/// An approved leave covering today, summarised for the dashboard.
@freezed
abstract class TodayLeaveModel with _$TodayLeaveModel {
  const factory TodayLeaveModel({
    required String type,
    @JsonKey(name: 'type_label') required String typeLabel,
  }) = _TodayLeaveModel;

  factory TodayLeaveModel.fromJson(Map<String, dynamic> json) =>
      _$TodayLeaveModelFromJson(json);
}

/// Today's snapshot: working hours plus any record or approved leave.
@freezed
abstract class AttendanceTodayModel with _$AttendanceTodayModel {
  const factory AttendanceTodayModel({
    required String date,
    @JsonKey(name: 'is_working_day') required bool isWorkingDay,
    @JsonKey(name: 'work_hours') required WorkHoursModel workHours,
    AttendanceModel? attendance,
    TodayLeaveModel? leave,
  }) = _AttendanceTodayModel;

  factory AttendanceTodayModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceTodayModelFromJson(json);
}

/// Monthly attendance recap counts (present / late / permission / sick /
/// dinas / absent) for the selected month.
@freezed
abstract class MonthlySummaryModel with _$MonthlySummaryModel {
  const factory MonthlySummaryModel({
    required String month,
    @Default(0) int hadir,
    @Default(0) int terlambat,
    @Default(0) int izin,
    @Default(0) int sakit,
    @Default(0) int dinas,
    @JsonKey(name: 'tidak_absen') @Default(0) int tidakAbsen,
  }) = _MonthlySummaryModel;

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryModelFromJson(json);
}

/// The full attendance dashboard payload.
@freezed
abstract class AttendanceDashboardModel with _$AttendanceDashboardModel {
  const factory AttendanceDashboardModel({
    required AttendanceTodayModel today,
    required MonthlySummaryModel summary,
  }) = _AttendanceDashboardModel;

  factory AttendanceDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDashboardModelFromJson(json);
}

/// Envelope for `GET /attendance/dashboard`, which wraps the payload in `data`.
@freezed
abstract class AttendanceDashboardEnvelope with _$AttendanceDashboardEnvelope {
  const factory AttendanceDashboardEnvelope({
    required AttendanceDashboardModel data,
  }) = _AttendanceDashboardEnvelope;

  factory AttendanceDashboardEnvelope.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDashboardEnvelopeFromJson(json);
}
