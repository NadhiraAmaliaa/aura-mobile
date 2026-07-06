import 'package:dio/dio.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
import '../datasources/lookup_api.dart';
import '../models/university_model.dart';

/// Reference-data repository for the login screen. Concrete (no abstract seam):
/// per architecture doc §3.1, only `auth`/`attendance` get a domain boundary;
/// lookups are plain read-only reference data.
class LookupRepository {
  LookupRepository(this._api);

  final LookupApi _api;

  Future<ApiResult<List<University>>> universities() async {
    try {
      final universities = await _api.universities();
      return Success(universities);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }
}
