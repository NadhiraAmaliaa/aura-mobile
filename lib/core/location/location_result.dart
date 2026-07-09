/// Result types for a device location request.
///
/// Location acquisition has several *expected* failure modes (services off,
/// permission denied, timeout). Rather than throw for these, the location
/// service returns a sealed [LocationResult] — mirroring the `ApiResult`
/// pattern used at the network boundary — so callers handle every branch
/// explicitly.
library;

/// A device position reduced to what attendance needs.
///
/// Deliberately decoupled from geolocator's `Position` so the rest of the app
/// never imports the plugin. Coordinates are plain doubles; they are formatted
/// to the backend's `decimal:7` precision only when sent.
class GeoPosition {
  const GeoPosition({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  final double latitude;
  final double longitude;

  /// Estimated horizontal accuracy in metres, when the platform reports it.
  final double? accuracy;
}

/// Why a location request could not be fulfilled.
enum LocationFailureKind {
  /// Device location services (GPS) are switched off.
  serviceDisabled,

  /// Permission was denied for this attempt (can be asked again).
  permissionDenied,

  /// Permission is permanently denied; only Settings can re-enable it.
  permissionDeniedForever,

  /// The fix took longer than the allotted time.
  timeout,

  /// The fix was reported by a mock/fake location provider (spoofed GPS).
  mocked,

  /// Anything else (hardware error, platform exception).
  unknown,
}

/// Outcome of a location request: either a [GeoPosition] or a typed failure.
sealed class LocationResult {
  const LocationResult();
}

/// A successful fix.
class LocationSuccess extends LocationResult {
  const LocationSuccess(this.position);

  final GeoPosition position;
}

/// An expected failure with a UI-safe Indonesian [message].
class LocationFailure extends LocationResult {
  const LocationFailure(this.kind, this.message);

  final LocationFailureKind kind;
  final String message;
}
