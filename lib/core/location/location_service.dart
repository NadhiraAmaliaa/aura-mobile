import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'adaptive_acquisition.dart';
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

  /// Acquire the freshest, best-available position using an adaptive warm-up.
  ///
  /// Listens to the location stream and decides when to stop based on the
  /// accuracy seen so far, so a genuinely good fix returns fast while a coarse
  /// network fix is not accepted too early:
  /// - a fix at or below [acceptableAccuracy] metres (good) returns immediately;
  /// - past [warmUp], a fix at or below [moderateAccuracy] metres is granted a
  ///   short [settle] window to improve, then returned;
  /// - a coarser fix keeps the stream open until a better one arrives or the
  ///   [hardCap] elapses, after which the best fix seen is returned.
  ///
  /// Same permission handling and failure model as [getCurrentPosition].
  Future<LocationResult> getBestPosition({
    Duration warmUp,
    double acceptableAccuracy,
    double moderateAccuracy,
    Duration settle,
    Duration hardCap,
  });

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

  /// Streaming settings for the warm-up (no per-fix time limit; the caller
  /// bounds the total wait).
  static const _warmUpSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  /// Base warm-up window: the first decision checkpoint, brief so Check In/Out
  /// stay responsive when the signal is good.
  static const _defaultWarmUp = Duration(seconds: 3);

  /// A fix at or below this horizontal accuracy (metres) is good enough to use
  /// immediately without waiting out the warm-up window. This is an early-exit
  /// optimisation only — it never rejects a fix.
  static const _defaultAcceptableAccuracy = 20.0;

  /// Past [_defaultWarmUp], a fix at or below this accuracy (metres) is treated
  /// as moderate: good enough to keep, but granted a short settle to improve.
  /// A coarser fix (typically an initial network fix) is not accepted yet.
  static const _defaultModerateAccuracy = 50.0;

  /// Extra time a moderate fix is allowed to improve before it is returned.
  static const _defaultSettle = Duration(seconds: 2);

  /// Absolute upper bound on the warm-up, so Check In/Out never waits too long
  /// even when only coarse fixes are available.
  static const _defaultHardCap = Duration(seconds: 7);

  /// Returned when the platform flags the fix as coming from a mock provider
  /// (Android API 18+, or an iOS 15+ simulated location). Blocks Fake GPS /
  /// Mock Location spoofing before the attendance request is submitted.
  static const _mockedLocationFailure = LocationFailure(
    LocationFailureKind.mocked,
    'Lokasi palsu terdeteksi. Nonaktifkan aplikasi Fake GPS / Mock Location '
    'terlebih dahulu, lalu coba lagi.',
  );

  @override
  Future<LocationResult> getCurrentPosition() async {
    final failure = await _ensureLocationUsable();
    if (failure != null) return failure;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return _resolvePosition(position);
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
  Future<LocationResult> getBestPosition({
    Duration warmUp = _defaultWarmUp,
    double acceptableAccuracy = _defaultAcceptableAccuracy,
    double moderateAccuracy = _defaultModerateAccuracy,
    Duration settle = _defaultSettle,
    Duration hardCap = _defaultHardCap,
  }) async {
    final failure = await _ensureLocationUsable();
    if (failure != null) return failure;

    try {
      final position = await _acquireBestPosition(
        warmUp,
        acceptableAccuracy,
        moderateAccuracy,
        settle,
        hardCap,
      );
      return _resolvePosition(position);
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

  /// Verify permission is granted before a fix is attempted.
  ///
  /// Returns `null` when the caller may proceed, or a [LocationFailure]
  /// describing why it cannot.
  ///
  /// Note: we deliberately do NOT short-circuit on
  /// [Geolocator.isLocationServiceEnabled] here. When services (GPS) are off,
  /// geolocator_android's FusedLocationClient shows the Play services
  /// resolution dialog (the AGHRIS-style "Turn on location?" prompt) as a side
  /// effect of [Geolocator.getCurrentPosition]/the position stream, and then
  /// automatically continues once the user enables it. Guarding here would
  /// prevent that dialog from ever appearing. If the user declines, or Play
  /// services are unavailable, geolocator throws
  /// [LocationServiceDisabledException], which the callers map to a
  /// [LocationFailureKind.serviceDisabled] failure (settings-screen fallback).
  Future<LocationFailure?> _ensureLocationUsable() async {
    // Ensure the app has permission, requesting it once if needed. Permission
    // (runtime grant) is orthogonal to services-enabled (the device GPS switch);
    // geolocator needs permission before it can trigger the services dialog.
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

    return null;
  }

  /// Adaptive warm-up over the position stream (see [selectAdaptiveFix]). Falls
  /// back to a single high-accuracy read when the stream yields nothing before
  /// the hard cap.
  Future<Position> _acquireBestPosition(
    Duration warmUp,
    double acceptableAccuracy,
    double moderateAccuracy,
    Duration settle,
    Duration hardCap,
  ) async {
    final outcome = await selectAdaptiveFix(
      Geolocator.getPositionStream(locationSettings: _warmUpSettings),
      acceptableAccuracy: acceptableAccuracy,
      moderateAccuracy: moderateAccuracy,
      warmUp: warmUp,
      settle: settle,
      hardCap: hardCap,
    );
    final position = outcome.position;
    if (position != null) return position;
    // Cap reached with no stream fix: single bounded high-accuracy read.
    return await Geolocator.getCurrentPosition(locationSettings: _settings);
  }

  /// Convert a resolved [Position] into a [LocationResult], rejecting fixes the
  /// platform reports as mocked so spoofed coordinates never reach the backend.
  LocationResult _resolvePosition(Position position) {
    if (position.isMocked) return _mockedLocationFailure;
    return LocationSuccess(_toGeoPosition(position));
  }

  GeoPosition _toGeoPosition(Position position) => GeoPosition(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
  );

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
