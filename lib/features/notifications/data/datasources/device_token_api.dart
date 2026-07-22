import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/device_token_request.dart';

part 'device_token_api.g.dart';

/// Typed client for device-token registration. Paths are relative to the
/// versioned base URL (`.../api/v1`) and start with a leading slash so Dio's
/// string-concatenation join preserves the `v1` segment.
@RestApi()
abstract class DeviceTokenApi {
  factory DeviceTokenApi(Dio dio, {String baseUrl}) = _DeviceTokenApi;

  /// Upserts the current device's FCM token for the authenticated intern.
  /// Returns 204 No Content on success.
  @POST('/auth/devices')
  Future<void> registerDevice(@Body() DeviceTokenRequest body);
}
