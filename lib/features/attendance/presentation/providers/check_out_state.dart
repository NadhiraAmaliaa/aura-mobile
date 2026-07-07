import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/attendance_models.dart';

part 'check_out_state.freezed.dart';

/// State machine for submitting a check-out.
@freezed
sealed class CheckOutState with _$CheckOutState {
  /// Nothing submitted yet.
  const factory CheckOutState.idle() = CheckOutIdle;

  /// The request is in flight.
  const factory CheckOutState.submitting() = CheckOutSubmitting;

  /// The check-out succeeded; carries the updated record.
  const factory CheckOutState.success(AttendanceModel record) = CheckOutSuccess;

  /// The check-out failed with a UI-safe [message].
  const factory CheckOutState.failure(String message) = CheckOutFailure;
}
