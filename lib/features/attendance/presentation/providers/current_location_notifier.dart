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
      LocationSuccess(:final position) => CurrentLocationState.success(
        position,
      ),
      LocationFailure(:final kind, :final message) =>
        CurrentLocationState.failure(kind, message),
    };
  }

  /// Acquire the freshest, best-available fix immediately before an attendance
  /// action (Check In / Check Out).
  ///
  /// Uses a short GPS warm-up so submission uses a current fix rather than the
  /// one captured when the page opened. Updates [state] so the map and
  /// coordinate read-out reflect the fresh position, and returns it (or `null`
  /// when acquisition failed).
  Future<GeoPosition?> acquireFresh() async {
    state = const CurrentLocationState.loading();

    final result = await ref.read(locationServiceProvider).getBestPosition();

    switch (result) {
      case LocationSuccess(:final position):
        state = CurrentLocationState.success(position);
        return position;
      case LocationFailure(:final kind, :final message):
        state = CurrentLocationState.failure(kind, message);
        return null;
    }
  }

  /// Open OS app settings (for a permanently denied permission).
  Future<void> openAppSettings() =>
      ref.read(locationServiceProvider).openAppSettings();

  /// Open OS location-services settings (when GPS is off).
  Future<void> openLocationSettings() =>
      ref.read(locationServiceProvider).openLocationSettings();
}
