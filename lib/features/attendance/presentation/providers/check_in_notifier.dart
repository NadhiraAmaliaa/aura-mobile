import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import 'attendance_dashboard_notifier.dart';
import 'check_in_state.dart';

part 'check_in_notifier.g.dart';

/// Drives a single check-in submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the new record when the user returns to it.
@riverpod
class CheckInController extends _$CheckInController {
  @override
  CheckInState build() => const CheckInState.idle();

  /// Submit today's check-in for [workMode], attaching coordinates when the
  /// device provided them.
  Future<void> submit({
    required String workMode,
    double? latitude,
    double? longitude,
  }) async {
    state = const CheckInState.submitting();

    final result = await ref
        .read(attendanceRepositoryProvider)
        .checkIn(workMode: workMode, latitude: latitude, longitude: longitude);

    state = result.fold(
      onSuccess: (record) {
        ref.invalidate(attendanceDashboardProvider);
        return CheckInState.success(record);
      },
      onFailure: (exception) => CheckInState.failure(exception.message),
    );
  }
}
