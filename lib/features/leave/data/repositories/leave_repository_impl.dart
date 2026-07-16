import 'package:dio/dio.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
import '../datasources/leave_api.dart';
import '../models/leave_models.dart';
import 'leave_repository.dart';

/// Network-backed [LeaveRepository]. Unwraps the `data` envelope and maps all
/// transport errors to typed [AppException]s so callers only ever see an
/// [ApiResult].
class LeaveRepositoryImpl implements LeaveRepository {
  LeaveRepositoryImpl(this._api);

  final LeaveApi _api;

  @override
  Future<ApiResult<LeaveListModel>> list({
    String? filter,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _api.list(filter, page, perPage);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<LeaveRequestModel>> detail(int id) async {
    try {
      final response = await _api.detail(id);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }
}
