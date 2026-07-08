import 'dart:math';

import 'package:aura_mobile/core/location/geo_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('distanceMeters', () {
    test('is zero for identical coordinates', () {
      expect(distanceMeters(3.5952, 98.6722, 3.5952, 98.6722), 0);
    });

    test('is symmetric', () {
      final ab = distanceMeters(3.5952, 98.6722, 3.6052, 98.6822);
      final ba = distanceMeters(3.6052, 98.6822, 3.5952, 98.6722);
      expect((ab - ba).abs(), lessThan(1e-6));
    });

    test('approximates a known one-degree-of-latitude span (~111 km)', () {
      // One degree of latitude is ~111.19 km at the equator.
      final d = distanceMeters(0, 0, 1, 0);
      expect(d, closeTo(111195, 50));
    });

    test('matches a manual haversine for a short span', () {
      const lat1 = 3.5952, lng1 = 98.6722, lat2 = 3.6052, lng2 = 98.6722;
      const r = 6371000.0;
      final dLat = (lat2 - lat1) * pi / 180.0;
      final a = sin(dLat / 2) * sin(dLat / 2);
      final expected = 2 * r * asin(sqrt(a));
      expect(distanceMeters(lat1, lng1, lat2, lng2), closeTo(expected, 1e-6));
    });
  });
}
