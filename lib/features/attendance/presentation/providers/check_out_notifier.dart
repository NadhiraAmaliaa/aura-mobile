import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import 'attendance_dashboard_notifier.dart';
import 'check_out_state.dart';

part 'check_out_notifier.g.dart';

/// Drives a single check-out submission.
///
/// On success it invalidates [attendanceDashboardProvider] so the dashboard
/// reflects the updated record when the user returns to it.
@riverpod
class CheckOutController extends _$CheckOutController {
  @override
  CheckOutState build() => const CheckOutState.idle();

  /// Submit today's check-out, attaching coordinates when the device provided
  /// them.
  Future<void> submit({double? latitude, double? longitude}) async {
    state = const CheckOutState.submitting();

    final result = await ref
        .read(attendanceRepositoryProvider)
        .checkOut(latitude: latitude, longitude: longitude);

    state = result.fold(
      onSuccess: (record) {
        ref.invalidate(attendanceDashboardProvider);
        return CheckOutState.success(record);
      },
      onFailure: (exception) => CheckOutState.failure(exception.message),
    );
  }
}
