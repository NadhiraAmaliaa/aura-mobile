import 'package:aura_mobile/core/location/location_providers.dart';
import 'package:aura_mobile/core/location/location_result.dart';
import 'package:aura_mobile/core/location/location_service.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/current_location_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/current_location_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [LocationService] that returns a scripted result, so the notifier can be
/// exercised without the geolocator plugin / real device GPS.
class _FakeLocationService implements LocationService {
  _FakeLocationService(this.result);

  final LocationResult result;

  @override
  Future<LocationResult> getCurrentPosition() async => result;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}

ProviderContainer _containerFor(LocationResult result) {
  final container = ProviderContainer(
    overrides: [
      locationServiceProvider.overrideWithValue(_FakeLocationService(result)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('CurrentLocation', () {
    test('starts idle', () {
      final container = _containerFor(
        const LocationFailure(LocationFailureKind.unknown, 'x'),
      );

      expect(container.read(currentLocationProvider), isA<LocationIdle>());
    });

    test('fetch transitions through loading to success', () async {
      const position = GeoPosition(
        latitude: 3.5952000,
        longitude: 98.6722000,
        accuracy: 8,
      );
      final container = _containerFor(const LocationSuccess(position));
      final notifier = container.read(currentLocationProvider.notifier);

      final future = notifier.fetch();
      // Loading is set synchronously before awaiting the service.
      expect(container.read(currentLocationProvider), isA<LocationLoading>());

      await future;

      final state = container.read(currentLocationProvider);
      expect(state, isA<LocationReady>());
      final ready = state as LocationReady;
      expect(ready.position.latitude, 3.5952000);
      expect(ready.position.longitude, 98.6722000);
      expect(ready.position.accuracy, 8);
    });

    test('fetch surfaces a typed failure with its message', () async {
      final container = _containerFor(
        const LocationFailure(
          LocationFailureKind.permissionDeniedForever,
          'Izin lokasi diblokir permanen. Buka Pengaturan untuk mengaktifkannya.',
        ),
      );
      final notifier = container.read(currentLocationProvider.notifier);

      await notifier.fetch();

      final state = container.read(currentLocationProvider);
      expect(state, isA<LocationError>());
      final error = state as LocationError;
      expect(error.kind, LocationFailureKind.permissionDeniedForever);
      expect(error.message, contains('Pengaturan'));
    });
  });
}
