import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/office_config_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
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
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AttendanceHistoryModel>> history({
    int? page,
    int? perPage,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<AttendanceModel>> syncEvent(AttendanceQueueEntry entry) =>
      throw UnimplementedError();
}

/// In-memory office cache, so the offline path can be tested without a real DB.
class _FakeOfficeCache implements OfficeConfigCacheStore {
  _FakeOfficeCache(this._offices);

  List<AttendanceLocationModel> _offices;

  @override
  Future<List<AttendanceLocationModel>> all() async => _offices;

  @override
  Future<void> replaceAll(List<AttendanceLocationModel> offices) async =>
      _offices = offices;
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

  group('geofenceOffices offline fallback', () {
    test(
      'resolves WFO offices from the sqflite cache when locations fail',
      () async {
        // Live locations are unreachable (offline)...
        final container = ProviderContainer.test(
          overrides: [
            attendanceRepositoryProvider.overrideWithValue(
              _FakeAttendanceRepository(Failure(const NetworkException())),
            ),
            // ...but the office config was cached on a previous online load.
            officeConfigCacheStoreProvider.overrideWith(
              (ref) async => _FakeOfficeCache([_office]),
            ),
          ],
        );
        // Keep the provider mounted across its async cache fallback.
        final sub = container.listen(geofenceOfficesProvider, (_, _) {});
        addTearDown(sub.close);

        final offices = await container.read(geofenceOfficesProvider.future);

        expect(offices, hasLength(1));
        expect(offices.first.name, 'Kantor Pusat');
      },
    );
  });
}
