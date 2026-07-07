import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/check_out_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/check_out_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A repository whose `checkOut` returns a scripted result and records the
/// arguments it was called with. Other methods are unused here.
class _FakeAttendanceRepository implements AttendanceRepository {
  _FakeAttendanceRepository(this.result);

  final ApiResult<AttendanceModel> result;

  double? capturedLatitude;
  double? capturedLongitude;

  @override
  Future<ApiResult<AttendanceModel>> checkOut({
    double? latitude,
    double? longitude,
  }) async {
    capturedLatitude = latitude;
    capturedLongitude = longitude;
    return result;
  }

  @override
  Future<ApiResult<AttendanceModel>> checkIn({
    required String workMode,
    double? latitude,
    double? longitude,
  }) => throw UnimplementedError();

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
  checkInTime: '08:00',
  checkOutTime: '17:05',
  status: 'present',
  statusLabel: 'Hadir',
  workMode: 'wfo',
  workModeLabel: 'WFO',
);

void main() {
  group('CheckOutController', () {
    test('starts idle', () {
      final container = _containerFor(
        _FakeAttendanceRepository(const Success(_record)),
      );

      expect(container.read(checkOutControllerProvider), isA<CheckOutIdle>());
    });

    test('submit transitions through submitting to success', () async {
      final repository = _FakeAttendanceRepository(const Success(_record));
      final container = _containerFor(repository);
      final notifier = container.read(checkOutControllerProvider.notifier);

      final future = notifier.submit(
        latitude: 3.5952000,
        longitude: 98.6722000,
      );
      // Submitting is set synchronously before awaiting the repository.
      expect(
        container.read(checkOutControllerProvider),
        isA<CheckOutSubmitting>(),
      );

      await future;

      final state = container.read(checkOutControllerProvider);
      expect(state, isA<CheckOutSuccess>());
      expect((state as CheckOutSuccess).record.checkOutTime, '17:05');
      expect(repository.capturedLatitude, 3.5952000);
      expect(repository.capturedLongitude, 98.6722000);
    });

    test('submit surfaces the failure message', () async {
      final repository = _FakeAttendanceRepository(
        const Failure(
          ServerException(
            message: 'Anda harus Check In terlebih dahulu sebelum Check Out.',
            statusCode: 422,
          ),
        ),
      );
      final container = _containerFor(repository);
      final notifier = container.read(checkOutControllerProvider.notifier);

      await notifier.submit();

      final state = container.read(checkOutControllerProvider);
      expect(state, isA<CheckOutFailure>());
      expect(
        (state as CheckOutFailure).message,
        'Anda harus Check In terlebih dahulu sebelum Check Out.',
      );
    });
  });
}
