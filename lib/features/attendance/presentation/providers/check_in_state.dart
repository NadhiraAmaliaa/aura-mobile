import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/attendance_models.dart';

part 'check_in_state.freezed.dart';

/// State machine for submitting a check-in.
@freezed
sealed class CheckInState with _$CheckInState {
  /// Nothing submitted yet.
  const factory CheckInState.idle() = CheckInIdle;

  /// The request is in flight.
  const factory CheckInState.submitting() = CheckInSubmitting;

  /// The check-in succeeded; carries the created record.
  const factory CheckInState.success(AttendanceModel record) = CheckInSuccess;

  /// The check-in failed with a UI-safe [message].
  const factory CheckInState.failure(String message) = CheckInFailure;
}
