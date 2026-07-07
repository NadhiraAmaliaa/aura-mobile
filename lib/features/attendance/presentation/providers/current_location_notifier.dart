import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/location/location_providers.dart';
import '../../../../core/location/location_result.dart';
import 'current_location_state.dart';

part 'current_location_notifier.g.dart';

/// Drives the "get my current location" flow for attendance.
///
/// Starts [CurrentLocationState.idle] so no permission prompt appears until the
/// user explicitly taps to fetch. Slice 4 (check-in) reads the resolved
/// [GeoPosition] from the [LocationReady] state.
@riverpod
class CurrentLocation extends _$CurrentLocation {
  @override
  CurrentLocationState build() => const CurrentLocationState.idle();

  /// Request the device's current position, updating [state] as it progresses.
  Future<void> fetch() async {
    state = const CurrentLocationState.loading();

    final result = await ref.read(locationServiceProvider).getCurrentPosition();

    state = switch (result) {
      LocationSuccess(:final position) => CurrentLocationState.success(position),
      LocationFailure(:final kind, :final message) =>
        CurrentLocationState.failure(kind, message),
    };
  }

  /// Open OS app settings (for a permanently denied permission).
  Future<void> openAppSettings() =>
      ref.read(locationServiceProvider).openAppSettings();

  /// Open OS location-services settings (when GPS is off).
  Future<void> openLocationSettings() =>
      ref.read(locationServiceProvider).openLocationSettings();
}
