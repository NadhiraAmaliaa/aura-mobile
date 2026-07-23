import 'package:dio/dio.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
import '../../domain/repositories/device_token_repository.dart';
import '../datasources/device_token_api.dart';
import '../models/device_token_request.dart';

/// Network-backed [DeviceTokenRepository]. Maps all transport errors to typed
/// [AppException]s (via [mapDioException]) and routes unexpected errors to
/// observability, mirroring the auth repository's error contract.
class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  DeviceTokenRepositoryImpl(this._api);

  final DeviceTokenApi _api;

  @override
  Future<ApiResult<void>> register(DeviceTokenRequest request) async {
    try {
      await _api.registerDevice(request);
      return const Success<void>(null);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }
}
