import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/location/location_result.dart';

part 'current_location_state.freezed.dart';

/// State machine for a single "get my location" interaction.
///
/// Explicit variants (rather than an `AsyncValue`) because an idle state — the
/// user has not yet asked for their location — is meaningful and must not
/// trigger a permission prompt on screen load.
@freezed
sealed class CurrentLocationState with _$CurrentLocationState {
  /// Nothing requested yet.
  const factory CurrentLocationState.idle() = LocationIdle;

  /// A fix is being acquired.
  const factory CurrentLocationState.loading() = LocationLoading;

  /// A position was obtained.
  const factory CurrentLocationState.success(GeoPosition position) =
      LocationReady;

  /// Acquisition failed for a known reason.
  const factory CurrentLocationState.failure(
    LocationFailureKind kind,
    String message,
  ) = LocationError;
}
