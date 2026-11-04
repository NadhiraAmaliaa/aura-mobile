import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import '../../data/models/attendance_models.dart';
import '../attendance_month.dart';
import 'attendance_dashboard_notifier.dart';
import 'trusted_attendance_date_provider.dart';

part 'attendance_history_month_provider.g.dart';

/// The latest month the history offers (`yyyy-MM`), resolved once per visit.
///
/// Only reads providers that are already alive (the dashboard below this
/// screen and its trusted date), so opening the history never starts a
/// dashboard fetch or a trusted-time lookup of its own.
@riverpod
String attendanceHistoryLatestMonth(Ref ref) {
  String? aliveValue<T>(
    ProviderListenable<AsyncValue<T>> provider,
    String? Function(T value) pick,
  ) {
    final value = ref.read(provider).value;
    return value == null ? null : pick(value);
  }

  return initialHistoryMonth(
    trustedDate: ref.exists(trustedAttendanceDateProvider)
        ? aliveValue(trustedAttendanceDateProvider, (date) => date)
        : null,
    dashboardMonth: ref.exists(attendanceDashboardProvider)
        ? aliveValue(
            attendanceDashboardProvider,
            (dashboard) => dashboard.summary.month,
          )
        : null,
    now: DateTime.now(),
  );
}

/// The month selected on the history screen (`yyyy-MM`). Starts at the latest
/// month and resets on every visit (auto-disposed with the screen).
@riverpod
class AttendanceHistoryMonth extends _$AttendanceHistoryMonth {
  @override
  String build() => ref.watch(attendanceHistoryLatestMonthProvider);

  /// Switch the history and its summary to [month].
  void select(String month) {
    if (month != state) state = month;
  }
}

/// The monthly recap for a `yyyy-MM` [month], read from the existing dashboard
/// endpoint so the six categories keep the backend's rules exactly.
///
/// A recap echoing a different month (e.g. an older backend resolving the
/// month differently) is rejected rather than shown under the wrong month.
@riverpod
Future<MonthlySummaryModel> attendanceMonthSummary(
  Ref ref,
  String month,
) async {
  final result = await ref
      .read(attendanceRepositoryProvider)
      .dashboard(month: month);
  return switch (result) {
    Success(:final data) when data.summary.month == month => data.summary,
    Success() => throw attendanceMonthMismatch,
    Failure(:final exception) => throw exception,
  };
}
