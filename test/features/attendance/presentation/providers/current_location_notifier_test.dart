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
  Future<LocationResult> getBestPosition({
    Duration warmUp = const Duration(seconds: 3),
    double acceptableAccuracy = 20,
  }) async => result;

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

    test('acquireFresh returns the position and sets it as state', () async {
      const position = GeoPosition(
        latitude: 3.5952000,
        longitude: 98.6722000,
        accuracy: 6,
      );
      final container = _containerFor(const LocationSuccess(position));
      final notifier = container.read(currentLocationProvider.notifier);

      final future = notifier.acquireFresh();
      // Loading is set synchronously before awaiting the service.
      expect(container.read(currentLocationProvider), isA<LocationLoading>());

      final acquired = await future;

      expect(acquired, isNotNull);
      expect(acquired!.latitude, 3.5952000);
      expect(container.read(currentLocationProvider), isA<LocationReady>());
    });

    test('acquireFresh returns null and sets error on failure', () async {
      final container = _containerFor(
        const LocationFailure(
          LocationFailureKind.timeout,
          'Gagal mendapatkan lokasi (waktu habis). Coba lagi.',
        ),
      );
      final notifier = container.read(currentLocationProvider.notifier);

      final acquired = await notifier.acquireFresh();

      expect(acquired, isNull);
      expect(container.read(currentLocationProvider), isA<LocationError>());
    });

    test(
      'acquireFresh rejects a mocked fix as a mocked failure (no position)',
      () async {
        final container = _containerFor(
          const LocationFailure(
            LocationFailureKind.mocked,
            'Lokasi palsu terdeteksi. Nonaktifkan aplikasi Fake GPS / Mock '
            'Location terlebih dahulu, lalu coba lagi.',
          ),
        );
        final notifier = container.read(currentLocationProvider.notifier);

        final acquired = await notifier.acquireFresh();

        expect(acquired, isNull);
        final state = container.read(currentLocationProvider);
        expect(state, isA<LocationError>());
        final error = state as LocationError;
        expect(error.kind, LocationFailureKind.mocked);
        expect(error.message, contains('Fake GPS'));
      },
    );

    test('acquireFresh accepts a genuine (non-mocked) fix', () async {
      const position = GeoPosition(
        latitude: 3.5952000,
        longitude: 98.6722000,
        accuracy: 5,
      );
      final container = _containerFor(const LocationSuccess(position));
      final notifier = container.read(currentLocationProvider.notifier);

      final acquired = await notifier.acquireFresh();

      expect(acquired, isNotNull);
      expect(container.read(currentLocationProvider), isA<LocationReady>());
    });
  });
}
