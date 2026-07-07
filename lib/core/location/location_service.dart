import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'location_result.dart';

/// Reads the device's real GPS/location.
///
/// The abstract seam lets the presentation layer depend on an interface (and
/// tests substitute a fake) instead of geolocator's static API.
abstract interface class LocationService {
  /// Acquire the current device position.
  ///
  /// Handles the full permission dance (services enabled -> permission granted)
  /// and returns a sealed [LocationResult]; expected problems are surfaced as
  /// [LocationFailure] rather than thrown.
  Future<LocationResult> getCurrentPosition();

  /// Open the OS app-settings page so the user can re-enable a permanently
  /// denied permission. Returns whether the page was opened.
  Future<bool> openAppSettings();

  /// Open the OS location-services (GPS) settings page. Returns whether the
  /// page was opened.
  Future<bool> openLocationSettings();
}

/// [LocationService] backed by the `geolocator` plugin (real device GPS).
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  /// High accuracy with a timeout so a lost fix cannot hang the UI forever.
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 20),
  );

  @override
  Future<LocationResult> getCurrentPosition() async {
    // 1. Location services (GPS) must be switched on at the OS level.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationFailure(
        LocationFailureKind.serviceDisabled,
        'Layanan lokasi (GPS) tidak aktif. Aktifkan lalu coba lagi.',
      );
    }

    // 2. Ensure the app has permission, requesting it once if needed.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationFailure(
        LocationFailureKind.permissionDeniedForever,
        'Izin lokasi diblokir permanen. Buka Pengaturan untuk mengaktifkannya.',
      );
    }
    if (permission == LocationPermission.denied) {
      return const LocationFailure(
        LocationFailureKind.permissionDenied,
        'Izin lokasi ditolak. Berikan izin untuk melanjutkan.',
      );
    }

    // 3. Permission granted (whileInUse / always) -> get a fix.
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return LocationSuccess(
        GeoPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ),
      );
    } on TimeoutException {
      return const LocationFailure(
        LocationFailureKind.timeout,
        'Gagal mendapatkan lokasi (waktu habis). Coba lagi.',
      );
    } on LocationServiceDisabledException {
      return const LocationFailure(
        LocationFailureKind.serviceDisabled,
        'Layanan lokasi (GPS) tidak aktif. Aktifkan lalu coba lagi.',
      );
    } catch (_) {
      return const LocationFailure(
        LocationFailureKind.unknown,
        'Gagal mendapatkan lokasi. Coba lagi.',
      );
    }
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
