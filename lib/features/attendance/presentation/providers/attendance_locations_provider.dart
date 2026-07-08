import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import '../../data/models/attendance_models.dart';

part 'attendance_locations_provider.g.dart';

/// The active office locations for WFO geofence pre-validation.
///
/// Loaded lazily — the check-in screen only watches this once the user selects
/// the WFO work mode. On failure the typed `AppException` is surfaced through
/// `AsyncError` so the UI can present it and retry (via `ref.invalidate`).
@riverpod
class AttendanceLocations extends _$AttendanceLocations {
  @override
  Future<List<AttendanceLocationModel>> build() => _load();

  Future<List<AttendanceLocationModel>> _load() async {
    final result = await ref.read(attendanceRepositoryProvider).locations();

    return switch (result) {
      Success(:final data) => data,
      Failure(:final exception) => throw exception,
    };
  }
}


