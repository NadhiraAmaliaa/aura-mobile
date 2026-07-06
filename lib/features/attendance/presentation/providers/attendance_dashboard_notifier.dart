import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import '../../data/models/attendance_models.dart';

part 'attendance_dashboard_notifier.g.dart';

/// Loads the attendance dashboard (today's snapshot + monthly recap).
///
/// Exposed as `AsyncValue<AttendanceDashboardModel>` so the screen can render
/// loading / error / data exhaustively. On failure the typed `AppException` is
/// surfaced through `AsyncError` for the UI to present and retry.
@riverpod
class AttendanceDashboardNotifier extends _$AttendanceDashboardNotifier {
  @override
  Future<AttendanceDashboardModel> build() => _load();

  /// Re-fetch the dashboard, showing a loading state while it refreshes.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<AttendanceDashboardModel> _load() async {
    final result = await ref.read(attendanceRepositoryProvider).dashboard();
    return result.fold(
      onSuccess: (data) => data,
      onFailure: (exception) => throw exception,
    );
  }
}
