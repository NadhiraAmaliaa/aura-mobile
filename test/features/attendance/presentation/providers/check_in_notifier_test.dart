import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/check_in_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/check_in_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A repository whose `checkIn` returns a scripted result and records the
/// arguments it was called with. Other methods are unused here.
class _FakeAttendanceRepository implements AttendanceRepository {
  _FakeAttendanceRepository(this.result);

  final ApiResult<AttendanceModel> result;

  String? capturedWorkMode;
  double? capturedLatitude;
  double? capturedLongitude;

  @override
  Future<ApiResult<AttendanceModel>> checkIn({
    required String workMode,
    double? latitude,
    double? longitude,
  }) async {
    capturedWorkMode = workMode;
    capturedLatitude = latitude;
    capturedLongitude = longitude;
    return result;
  }

  @override
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AttendanceHistoryModel>> history({
    int? page,
    int? perPage,
  }) => throw UnimplementedError();
}

ProviderContainer _containerFor(_FakeAttendanceRepository repository) {
  final container = ProviderContainer(
    overrides: [
      attendanceRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

const _record = AttendanceModel(
  id: 1,
  attendanceDate: '2026-07-06',
  checkInTime: '07:50',
  status: 'present',
  statusLabel: 'Hadir',
  workMode: 'wfo',
  workModeLabel: 'WFO',
);

void main() {
  group('CheckInController', () {
    test('starts idle', () {
      final container = _containerFor(
        _FakeAttendanceRepository(const Success(_record)),
      );

      expect(container.read(checkInControllerProvider), isA<CheckInIdle>());
    });

    test('submit transitions through submitting to success', () async {
      final repository = _FakeAttendanceRepository(const Success(_record));
      final container = _containerFor(repository);
      final notifier = container.read(checkInControllerProvider.notifier);

      final future = notifier.submit(
        workMode: 'wfo',
        latitude: 3.5952000,
        longitude: 98.6722000,
      );
      // Submitting is set synchronously before awaiting the repository.
      expect(
        container.read(checkInControllerProvider),
        isA<CheckInSubmitting>(),
      );

      await future;

      final state = container.read(checkInControllerProvider);
      expect(state, isA<CheckInSuccess>());
      expect((state as CheckInSuccess).record.status, 'present');
      expect(repository.capturedWorkMode, 'wfo');
      expect(repository.capturedLatitude, 3.5952000);
      expect(repository.capturedLongitude, 98.6722000);
    });

    test('submit surfaces the failure message', () async {
      final repository = _FakeAttendanceRepository(
        const Failure(
          ServerException(
            message: 'Anda sudah melakukan Check In hari ini.',
            statusCode: 409,
          ),
        ),
      );
      final container = _containerFor(repository);
      final notifier = container.read(checkInControllerProvider.notifier);

      await notifier.submit(workMode: 'wfo');

      final state = container.read(checkInControllerProvider);
      expect(state, isA<CheckInFailure>());
      expect(
        (state as CheckInFailure).message,
        'Anda sudah melakukan Check In hari ini.',
      );
    });
  });
}
