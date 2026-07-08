import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/geofence_evaluation.dart';
import 'package:flutter_test/flutter_test.dart';

const _office = AttendanceLocationModel(
  id: 1,
  name: 'Kantor Pusat',
  latitude: 3.5952000,
  longitude: 98.6722000,
  radius: 200,
);

const _farOffice = AttendanceLocationModel(
  id: 2,
  name: 'Kantor Jauh',
  latitude: 3.7000000,
  longitude: 98.8000000,
  radius: 200,
);

void main() {
  group('evaluateGeofence', () {
    test('returns GeofenceNoLocations when the list is empty (fail-closed)', () {
      final result = evaluateGeofence(const [], 3.5952, 98.6722);
      expect(result, isA<GeofenceNoLocations>());
    });

    test('returns GeofenceInside when within the radius', () {
      final result = evaluateGeofence([_office], 3.5952, 98.6722);
      expect(result, isA<GeofenceInside>());
      final inside = result as GeofenceInside;
      expect(inside.location.id, 1);
      expect(inside.distanceMeters, lessThan(1));
    });

    test('returns GeofenceOutside when beyond the radius', () {
      // ~1.1 km north of the office, radius is 200 m.
      final result = evaluateGeofence([_office], 3.6052, 98.6722);
      expect(result, isA<GeofenceOutside>());
      final outside = result as GeofenceOutside;
      expect(outside.location.id, 1);
      expect(outside.distanceMeters, greaterThan(200));
    });

    test('picks the nearest location among several', () {
      final result = evaluateGeofence([_farOffice, _office], 3.5952, 98.6722);
      expect(result, isA<GeofenceInside>());
      expect((result as GeofenceInside).location.id, 1);
    });
  });
}
