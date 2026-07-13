import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/attendance_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/office_config_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_locations_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

/// A [Connectivity] whose result is scripted, so the plugin channel is never
/// touched in tests. Defaults to "online".
class _FakeConnectivity implements Connectivity {
  _FakeConnectivity({this.connected = true});

  final bool connected;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      connected ? [ConnectivityResult.wifi] : [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProviderContainer _containerFor(
  _FakeAttendanceRepository repository, {
  bool connected = true,
  List<AttendanceLocationModel> cachedOffices = const [],
}) {
  return ProviderContainer.test(
    overrides: [
      attendanceRepositoryProvider.overrideWithValue(repository),
      connectivityProvider.overrideWithValue(
        _FakeConnectivity(connected: connected),
      ),
      officeConfigCacheStoreProvider.overrideWith(
        (ref) async => _FakeOfficeCache([...cachedOffices]),
      ),
    ],
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

    test(
      'falls back to the cached offices when the backend is unreachable',
      () async {
        // Online, but the request fails (timeout / connection refused / 5xx)...
        final container = _containerFor(
          _FakeAttendanceRepository(Failure(const NetworkException())),
          // ...and a previous online load left the office config cached.
          cachedOffices: const [_office],
        );
        final sub = container.listen(attendanceLocationsProvider, (_, _) {});
        addTearDown(sub.close);

        final locations = await container.read(
          attendanceLocationsProvider.future,
        );

        expect(locations, hasLength(1));
        expect(locations.first.name, 'Kantor Pusat');
      },
    );

    test('serves the cache without a request when there is no transport', () async {
      // No network at all: the doomed request must be skipped entirely.
      final container = _containerFor(
        _FakeAttendanceRepository(Failure(const NetworkException())),
        connected: false,
        cachedOffices: const [_office],
      );
      final sub = container.listen(attendanceLocationsProvider, (_, _) {});
      addTearDown(sub.close);

      final locations = await container.read(
        attendanceLocationsProvider.future,
      );

      expect(locations, hasLength(1));
    });

    test('surfaces an explicit 401 instead of the cache', () async {
      final container = ProviderContainer.test(
        // Never retry, so the error settles for the expectation.
        retry: (_, _) => null,
        overrides: [
          attendanceRepositoryProvider.overrideWithValue(
            _FakeAttendanceRepository(Failure(const UnauthorizedException())),
          ),
          connectivityProvider.overrideWithValue(_FakeConnectivity()),
          officeConfigCacheStoreProvider.overrideWith(
            (ref) async => _FakeOfficeCache([_office]),
          ),
        ],
      );
      final sub = container.listen(attendanceLocationsProvider, (_, _) {});
      addTearDown(sub.close);

      await expectLater(
        container.read(attendanceLocationsProvider.future),
        throwsA(isA<UnauthorizedException>()),
      );
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
