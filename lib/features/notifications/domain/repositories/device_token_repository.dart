import '../../../../core/network/api_result.dart';
import '../../data/models/device_token_request.dart';

/// Abstract boundary for registering this device's FCM token with the backend.
/// Kept as an interface so the presentation layer depends on the seam and tests
/// can substitute a fake.
abstract interface class DeviceTokenRepository {
  /// Registers (upserts) the given FCM token. Returns [Success] on success or a
  /// typed [Failure] on any transport/server error.
  Future<ApiResult<void>> register(DeviceTokenRequest request);
}
