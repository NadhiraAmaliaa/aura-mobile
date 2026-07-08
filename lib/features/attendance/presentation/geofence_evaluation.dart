import '../../../core/location/geo_math.dart';
import '../data/models/attendance_models.dart';

/// Outcome of checking a device position against the active office locations.
///
/// Mirrors the backend policy in `AttendanceService::assertWithinOfficeGeofence`
/// (fail-closed): with no active locations the WFO check-in is blocked. This is
/// only a UX pre-check — the server remains authoritative.
sealed class GeofenceEvaluation {
  const GeofenceEvaluation();
}

/// No active office location is configured — WFO check-in is blocked.
class GeofenceNoLocations extends GeofenceEvaluation {
  const GeofenceNoLocations();
}

/// The position is inside the nearest office's radius — check-in is allowed.
class GeofenceInside extends GeofenceEvaluation {
  const GeofenceInside(this.location, this.distanceMeters);

  final AttendanceLocationModel location;
  final double distanceMeters;
}

/// The position is outside the nearest office's radius — check-in is blocked.
class GeofenceOutside extends GeofenceEvaluation {
  const GeofenceOutside(this.location, this.distanceMeters);

  final AttendanceLocationModel location;
  final double distanceMeters;
}

/// Evaluate [latitude]/[longitude] against the active office [locations],
/// picking the nearest one.
GeofenceEvaluation evaluateGeofence(
  List<AttendanceLocationModel> locations,
  double latitude,
  double longitude,
) {
  if (locations.isEmpty) {
    return const GeofenceNoLocations();
  }

  AttendanceLocationModel? nearest;
  double? nearestDistance;

  for (final location in locations) {
    final distance = distanceMeters(
      latitude,
      longitude,
      location.latitude,
      location.longitude,
    );

    if (nearestDistance == null || distance < nearestDistance) {
      nearest = location;
      nearestDistance = distance;
    }
  }

  return nearestDistance! <= nearest!.radius
      ? GeofenceInside(nearest, nearestDistance)
      : GeofenceOutside(nearest, nearestDistance);
}
