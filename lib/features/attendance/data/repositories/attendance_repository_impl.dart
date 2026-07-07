import 'package:dio/dio.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_api.dart';
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
  Future<ApiResult<AttendanceModel>> checkIn({
    required String workMode,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{
        'work_mode': workMode,
        'latitude': ?latitude,
        'longitude': ?longitude,
      };
      final response = await _api.checkIn(body);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<AttendanceModel>> checkOut({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{
        'latitude': ?latitude,
        'longitude': ?longitude,
      };
      final response = await _api.checkOut(body);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }
}
