/// Request payload for registering this device's FCM token with the backend.
///
/// Plain DTO with an explicit [toJson] (Retrofit serializes `@Body` objects via
/// `toJson`), matching the hand-written request models used by the auth API.
class DeviceTokenRequest {
  const DeviceTokenRequest({required this.token, required this.platform});

  /// The current FCM registration token.
  final String token;

  /// The device platform: `android`, `ios` or `web`.
  final String platform;

  Map<String, dynamic> toJson() => {'token': token, 'platform': platform};
}
