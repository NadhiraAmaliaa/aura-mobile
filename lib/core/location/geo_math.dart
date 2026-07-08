import 'dart:math';

/// Great-circle distance in metres between two coordinates (haversine).
///
/// Mirrors the backend `App\Support\Geo::haversineMeters` (same Earth radius)
/// so client-side WFO pre-validation agrees with the server's authoritative
/// geofence check.
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusMeters = 6371000.0;

  final dLat = _degToRad(lat2 - lat1);
  final dLng = _degToRad(lng2 - lng1);

  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLng / 2) *
          sin(dLng / 2);

  return 2 * earthRadiusMeters * asin(sqrt(a));
}

double _degToRad(double degrees) => degrees * pi / 180.0;
