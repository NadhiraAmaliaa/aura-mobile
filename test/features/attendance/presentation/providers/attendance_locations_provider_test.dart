import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_locations_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A repository whose `locations` returns a scripted result. Other methods are
/// unused here.
class _FakeAttendanceRepository implements AttendanceRepository {
  _FakeAttendanceRepository(this.result);

  final ApiResult<List<AttendanceLocationModel>> result;

  @override
  Future<ApiResult<List<AttendanceLocationModel>>> locations() async => result;

  @override
  Future<ApiResult<AttendanceModel>> checkIn({
    required String workMode,
    double? latitude,
    double? longitude,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<AttendanceModel>> checkOut({
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
  return ProviderContainer.test(
    overrides: [attendanceRepositoryProvider.overrideWithValue(repository)],
  );
}

const _office = AttendanceLocationModel(
  id: 1,
  name: 'Kantor Pusat',
  latitude: 3.5952000,
  longitude: 98.6722000,
  radius: 200,
);

void main() {
  group('attendanceLocationsProvider', () {
    test('resolves to the repository list on success', () async {
      final container = _containerFor(
        _FakeAttendanceRepository(const Success([_office])),
      );

      final locations = await container.read(
        attendanceLocationsProvider.future,
      );

      expect(locations, hasLength(1));
      expect(locations.first.name, 'Kantor Pusat');
    });
  });
}
