import 'package:dio/dio.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_api.dart';
import '../local/attendance_queue_entry.dart';
import '../models/attendance_models.dart';

/// Network-backed [AttendanceRepository]. Unwraps the `data` envelope and maps
/// all transport errors to typed [AppException]s so callers only ever see an
/// [ApiResult].
class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._api);

  final AttendanceApi _api;

  @override
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month}) async {
    try {
      final response = await _api.dashboard(month);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<AttendanceHistoryModel>> history({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _api.history(page, perPage);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<AttendanceModel>> syncEvent(
    AttendanceQueueEntry entry,
  ) async {
    try {
      final body = <String, dynamic>{
        'client_event_id': entry.clientEventId,
        'captured_at': entry.capturedAt,
        'latitude': ?entry.latitude,
        'longitude': ?entry.longitude,
        'office_id': ?entry.officeId,
        'office_latitude': ?entry.officeLatitude,
        'office_longitude': ?entry.officeLongitude,
        'office_radius': ?entry.officeRadius,
        'office_name': ?entry.officeName,
        'auto_time_enabled': ?entry.autoTimeEnabled,
      };

      final response = switch (entry.type) {
        AttendanceEventType.checkIn => await _api.checkIn({
            ...body,
            'work_mode': entry.workMode,
          }),
        AttendanceEventType.checkOut => await _api.checkOut(body),
      };
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<List<AttendanceLocationModel>>> locations() async {
    try {
      final response = await _api.locations();
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }
}
