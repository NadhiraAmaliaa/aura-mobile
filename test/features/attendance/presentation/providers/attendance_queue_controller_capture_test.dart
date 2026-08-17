import 'package:aura_mobile/core/device/device_time_providers.dart';
import 'package:aura_mobile/core/device/device_time_settings.dart';
import 'package:aura_mobile/core/device/trusted_time_providers.dart';
import 'package:aura_mobile/core/device/trusted_time_service.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/data/sync/attendance_sync_service.dart';
import 'package:aura_mobile/features/attendance/data/sync/sync_providers.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_queue_controller.dart';
import 'package:aura_mobile/features/auth/presentation/providers/current_user_provider.dart';
import 'package:aura_mobile/shared/utils/captured_at.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A device-time seam with a canned answer.
class FakeDeviceTimeSettings implements DeviceTimeSettings {
  FakeDeviceTimeSettings(this.automatic);

  final bool? automatic;

  @override
  Future<bool?> isAutomaticEnabled() async => automatic;

  @override
  Future<bool> openDateTimeSettings() async => true;
}

/// A sync service that records the enqueued entry and reports it as synced.
class RecordingSyncService extends AttendanceSyncService {
  RecordingSyncService() : super(_DummyStore(), _DummyRepository());

  AttendanceQueueEntry? lastEnqueued;

  @override
  Future<AttendanceQueueEntry> enqueue(AttendanceQueueEntry entry) async {
    lastEnqueued = entry;
    return entry.copyWith(status: QueuedEventStatus.synced);
  }
}

class _DummyStore implements AttendanceQueueStore {
  @override
  Future<List<AttendanceQueueEntry>> allEntries(int userId) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _DummyRepository implements AttendanceRepository {
  const _DummyRepository();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A TrustedTimeService stand-in for existing tests that pass `at:` directly.
/// Returns `DateTime.now().toUtc()` so the controller's trusted-time path is
/// exercised without the native platform clock.
class _PassthroughTrustedTimeService implements TrustedTimeService {
  @override
  Future<DateTime> now() async => DateTime.now().toUtc();

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<void> setAnchor(DateTime serverTimeUtc) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProviderContainer containerFor({
  required bool? automatic,
  required RecordingSyncService syncService,
}) {
  final container = ProviderContainer.test(
    overrides: [
      currentUserIdProvider.overrideWithValue(7),
      deviceTimeSettingsProvider.overrideWithValue(
        FakeDeviceTimeSettings(automatic),
      ),
      trustedTimeServiceProvider.overrideWith(
        (ref) async => _PassthroughTrustedTimeService(),
      ),
      attendanceSyncServiceProvider.overrideWith((ref) async => syncService),
      attendanceQueueStoreProvider.overrideWith((ref) async => _DummyStore()),
      connectivityChangesProvider.overrideWith((ref) => const Stream.empty()),
    ],
  );
  return container;
}

/// A queue store pre-seeded with entries (only `allEntries` is exercised by the
/// controller's build / refresh), used to simulate a still-pending check-in.
class _SeededStore implements AttendanceQueueStore {
  _SeededStore(this.seed);

  final List<AttendanceQueueEntry> seed;

  @override
  Future<List<AttendanceQueueEntry>> allEntries(int userId) async =>
      seed.where((e) => e.userId == userId).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProviderContainer containerWith({
  required RecordingSyncService syncService,
  required AttendanceQueueStore store,
}) {
  return ProviderContainer.test(
    overrides: [
      currentUserIdProvider.overrideWithValue(7),
      deviceTimeSettingsProvider.overrideWithValue(
        FakeDeviceTimeSettings(true),
      ),
      trustedTimeServiceProvider.overrideWith(
        (ref) async => _PassthroughTrustedTimeService(),
      ),
      attendanceSyncServiceProvider.overrideWith((ref) async => syncService),
      attendanceQueueStoreProvider.overrideWith((ref) async => store),
      connectivityChangesProvider.overrideWith((ref) => const Stream.empty()),
    ],
  );
}

/// A single active office at a fixed point, radius 50 m.
const _office = AttendanceLocationModel(
  id: 1,
  name: 'Kantor Pusat',
  latitude: 3.5952,
  longitude: 98.6722,
  radius: 50,
);

/// Today's server snapshot used to drive the local rule checks.
AttendanceTodayModel _today({
  bool isWorkingDay = true,
  String? end = '17:00',
  String? checkInTime,
}) {
  return AttendanceTodayModel(
    date: '2026-07-12',
    isWorkingDay: isWorkingDay,
    workHours: WorkHoursModel(start: '08:00', end: end),
    attendance: checkInTime == null
        ? null
        : AttendanceModel(
            id: 1,
            status: 'present',
            statusLabel: 'Hadir',
            checkInTime: checkInTime,
          ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttendanceQueueController.capture auto-time gate', () {
    test('stamps the automatic-time result on the enqueued entry', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);

      await container.read(attendanceQueueControllerProvider.future);
      final controller = container.read(
        attendanceQueueControllerProvider.notifier,
      );

      await controller.capture(type: AttendanceEventType.checkIn);

      expect(syncService.lastEnqueued?.autoTimeEnabled, isTrue);
    });

    test('forwards null when the device cannot verify the clock', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: null, syncService: syncService);
      addTearDown(container.dispose);

      await container.read(attendanceQueueControllerProvider.future);
      final controller = container.read(
        attendanceQueueControllerProvider.notifier,
      );

      await controller.capture(type: AttendanceEventType.checkIn);

      expect(syncService.lastEnqueued?.autoTimeEnabled, isNull);
    });

    test('hard-blocks and never enqueues when the clock is manual', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(
        automatic: false,
        syncService: syncService,
      );
      addTearDown(container.dispose);

      await container.read(attendanceQueueControllerProvider.future);
      final controller = container.read(
        attendanceQueueControllerProvider.notifier,
      );

      await expectLater(
        controller.capture(type: AttendanceEventType.checkIn),
        throwsA(isA<AutomaticTimeDisabledException>()),
      );
      expect(syncService.lastEnqueued, isNull);
    });
  });

  group('AttendanceQueueController.capture local business rules', () {
    Future<AttendanceQueueController> controllerFrom(
      ProviderContainer container,
    ) async {
      await container.read(attendanceQueueControllerProvider.future);
      return container.read(attendanceQueueControllerProvider.notifier);
    }

    test('blocks a duplicate check-in and never enqueues', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      await expectLater(
        controller.capture(
          type: AttendanceEventType.checkIn,
          workMode: 'wfh',
          today: _today(checkInTime: '08:00'),
        ),
        throwsA(
          isA<AttendanceRuleException>().having(
            (e) => e.message,
            'message',
            contains('sudah melakukan check in'),
          ),
        ),
      );
      expect(syncService.lastEnqueued, isNull);
    });

    test('blocks a check-in after the cutoff and never enqueues', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      await expectLater(
        controller.capture(
          type: AttendanceEventType.checkIn,
          workMode: 'wfh',
          today: _today(end: '17:00'),
          at: DateTime(2026, 7, 12, 18),
        ),
        throwsA(
          isA<AttendanceRuleException>().having(
            (e) => e.message,
            'message',
            contains('Waktu Check In telah terlewati'),
          ),
        ),
      );
      expect(syncService.lastEnqueued, isNull);
    });

    test('allows a check-in before the cutoff', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      await controller.capture(
        type: AttendanceEventType.checkIn,
        workMode: 'wfh',
        today: _today(end: '17:00'),
        at: DateTime(2026, 7, 12, 7),
      );

      expect(syncService.lastEnqueued?.type, AttendanceEventType.checkIn);
    });

    test('allows a check-in on a non-working day regardless of time', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      await controller.capture(
        type: AttendanceEventType.checkIn,
        workMode: 'wfh',
        today: _today(isWorkingDay: false, end: null),
        at: DateTime(2026, 7, 12, 23),
      );

      expect(syncService.lastEnqueued?.type, AttendanceEventType.checkIn);
    });

    test(
      'blocks a WFO check-out outside the office radius and never enqueues',
      () async {
        final syncService = RecordingSyncService();
        final container = containerFor(
          automatic: true,
          syncService: syncService,
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        await expectLater(
          controller.capture(
            type: AttendanceEventType.checkOut,
            office: _office,
            latitude: 3.6052, // ~1.1 km north, well outside 50 m
            longitude: 98.6722,
            today: _today(checkInTime: '08:00'),
            at: DateTime(2026, 7, 12, 17),
          ),
          throwsA(
            isA<AttendanceRuleException>().having(
              (e) => e.message,
              'message',
              contains('di luar radius kantor'),
            ),
          ),
        );
        expect(syncService.lastEnqueued, isNull);
      },
    );

    test('blocks a check-out with no check-in and never enqueues', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      await expectLater(
        controller.capture(type: AttendanceEventType.checkOut, today: _today()),
        throwsA(
          isA<AttendanceRuleException>().having(
            (e) => e.message,
            'message',
            contains('harus Check In terlebih dahulu'),
          ),
        ),
      );
      expect(syncService.lastEnqueued, isNull);
    });

    test('blocks a check-out captured before the check-in time', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      await expectLater(
        controller.capture(
          type: AttendanceEventType.checkOut,
          today: _today(checkInTime: '08:00'),
          at: DateTime(2026, 7, 12, 7),
        ),
        throwsA(
          isA<AttendanceRuleException>().having(
            (e) => e.message,
            'message',
            contains('Check Out harus setelah'),
          ),
        ),
      );
      expect(syncService.lastEnqueued, isNull);
    });

    test('allows a WFO check-out inside the radius after check-in', () async {
      final syncService = RecordingSyncService();
      final container = containerFor(automatic: true, syncService: syncService);
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      await controller.capture(
        type: AttendanceEventType.checkOut,
        office: _office,
        latitude: 3.5952,
        longitude: 98.6722,
        today: _today(checkInTime: '08:00'),
        at: DateTime(2026, 7, 12, 17),
      );

      expect(syncService.lastEnqueued?.type, AttendanceEventType.checkOut);
    });

    test(
      'a pending offline check-in allows a later offline check-out',
      () async {
        final now = DateTime.now();
        final store = _SeededStore([
          AttendanceQueueEntry(
            clientEventId: 'seed-checkin',
            userId: 7,
            type: AttendanceEventType.checkIn,
            workMode: 'wfh',
            capturedAt: formatCapturedAt(
              now.subtract(const Duration(hours: 1)),
            ),
            createdAt: now,
          ),
        ]);
        final syncService = RecordingSyncService();
        final container = containerWith(syncService: syncService, store: store);
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        // No server dashboard (offline): the still-pending check-in must satisfy
        // both the "requires a check-in" and "after the check-in" rules.
        await controller.capture(type: AttendanceEventType.checkOut);

        expect(syncService.lastEnqueued?.type, AttendanceEventType.checkOut);
      },
    );
  });
}
