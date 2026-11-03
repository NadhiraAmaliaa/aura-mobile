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
  required AttendanceSyncService syncService,
  required AttendanceQueueStore store,
  TrustedTimeService? trustedTime,
}) {
  return ProviderContainer.test(
    overrides: [
      currentUserIdProvider.overrideWithValue(7),
      deviceTimeSettingsProvider.overrideWithValue(
        FakeDeviceTimeSettings(true),
      ),
      trustedTimeServiceProvider.overrideWith(
        (ref) async => trustedTime ?? _PassthroughTrustedTimeService(),
      ),
      attendanceSyncServiceProvider.overrideWith((ref) async => syncService),
      attendanceQueueStoreProvider.overrideWith((ref) async => store),
      connectivityChangesProvider.overrideWith((ref) => const Stream.empty()),
    ],
  );
}

/// A trusted clock pinned to [instant], or unavailable with [error].
class _FixedTrustedTime implements TrustedTimeService {
  _FixedTrustedTime(DateTime this.instant) : error = null;

  _FixedTrustedTime.unavailable(TrustedTimeUnavailableException this.error)
    : instant = null;

  final DateTime? instant;
  final TrustedTimeUnavailableException? error;

  @override
  Future<DateTime> now() async {
    final error = this.error;
    if (error != null) throw error;
    return instant!;
  }

  @override
  Future<bool> get isAvailable async => error == null;

  @override
  Future<void> setAnchor(DateTime serverTimeUtc) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A sync service for a device that stays offline: every capture is queued in
/// [entries] and left pending.
class _OfflineSyncService extends AttendanceSyncService {
  _OfflineSyncService(this.entries) : super(_DummyStore(), _DummyRepository());

  final List<AttendanceQueueEntry> entries;

  @override
  Future<AttendanceQueueEntry> enqueue(AttendanceQueueEntry entry) async {
    entries.add(entry);
    return entry;
  }
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
  String date = '2026-07-12',
  bool isWorkingDay = true,
  String? end = '17:00',
  String? checkInTime,
  String? checkOutTime,
}) {
  return AttendanceTodayModel(
    date: date,
    isWorkingDay: isWorkingDay,
    workHours: WorkHoursModel(start: '08:00', end: end),
    attendance: checkInTime == null
        ? null
        : AttendanceModel(
            id: 1,
            status: 'present',
            statusLabel: 'Hadir',
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
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
          at: DateTime(2026, 7, 12, 9),
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

  group('AttendanceQueueController.capture across calendar days', () {
    Future<AttendanceQueueController> controllerFrom(
      ProviderContainer container,
    ) async {
      await container.read(attendanceQueueControllerProvider.future);
      return container.read(attendanceQueueControllerProvider.notifier);
    }

    // Monday's server snapshot (checked in and out), still cached afterwards.
    final monday = _today(
      date: '2026-07-13',
      checkInTime: '08:00',
      checkOutTime: '17:00',
    );

    AttendanceQueueEntry pendingCheckIn(DateTime at) => AttendanceQueueEntry(
      clientEventId: 'seed-${at.toIso8601String()}',
      userId: 7,
      type: AttendanceEventType.checkIn,
      workMode: 'wfh',
      capturedAt: formatCapturedAt(at),
      createdAt: at,
    );

    Matcher ruleViolation(String message) => throwsA(
      isA<AttendanceRuleException>().having(
        (e) => e.message,
        'message',
        contains(message),
      ),
    );

    test(
      "an earlier day's cached check-in does not block today's check-in",
      () async {
        final syncService = RecordingSyncService();
        final container = containerFor(
          automatic: true,
          syncService: syncService,
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        await controller.capture(
          type: AttendanceEventType.checkIn,
          workMode: 'wfh',
          today: monday,
          at: DateTime(2026, 7, 14, 8),
        );

        expect(syncService.lastEnqueued?.type, AttendanceEventType.checkIn);
      },
    );

    test(
      "today's pending check-in still blocks a duplicate behind an old snapshot",
      () async {
        final syncService = RecordingSyncService();
        final container = containerWith(
          syncService: syncService,
          store: _SeededStore([pendingCheckIn(DateTime(2026, 7, 14, 8))]),
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        await expectLater(
          controller.capture(
            type: AttendanceEventType.checkIn,
            workMode: 'wfh',
            today: monday,
            at: DateTime(2026, 7, 14, 9),
          ),
          ruleViolation('sudah melakukan check in'),
        );
        expect(syncService.lastEnqueued, isNull);
      },
    );

    test(
      'a pending check-in from an earlier day does not block today',
      () async {
        final syncService = RecordingSyncService();
        final container = containerWith(
          syncService: syncService,
          store: _SeededStore([pendingCheckIn(DateTime(2026, 7, 13, 8))]),
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        await controller.capture(
          type: AttendanceEventType.checkIn,
          workMode: 'wfh',
          at: DateTime(2026, 7, 14, 8),
        );

        expect(syncService.lastEnqueued?.type, AttendanceEventType.checkIn);
      },
    );

    test(
      "an old snapshot's check-in does not satisfy today's check-out",
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
            today: monday,
            at: DateTime(2026, 7, 14, 17),
          ),
          ruleViolation('harus Check In terlebih dahulu'),
        );
        expect(syncService.lastEnqueued, isNull);
      },
    );

    test(
      "today's pending check-in orders a check-out, not the old snapshot's",
      () async {
        final syncService = RecordingSyncService();
        final container = containerWith(
          syncService: syncService,
          store: _SeededStore([pendingCheckIn(DateTime(2026, 7, 14, 9))]),
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        // After Monday's 08:00 but before today's 09:00 check-in.
        await expectLater(
          controller.capture(
            type: AttendanceEventType.checkOut,
            today: monday,
            at: DateTime(2026, 7, 14, 8, 30),
          ),
          ruleViolation('harus setelah waktu Check In'),
        );
        expect(syncService.lastEnqueued, isNull);

        await controller.capture(
          type: AttendanceEventType.checkOut,
          today: monday,
          at: DateTime(2026, 7, 14, 17),
        );
        expect(syncService.lastEnqueued?.type, AttendanceEventType.checkOut);
      },
    );

    test(
      "an earlier day's working hours are not applied as today's cutoff",
      () async {
        final syncService = RecordingSyncService();
        final container = containerFor(
          automatic: true,
          syncService: syncService,
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        // Monday's 17:00 end time says nothing about Tuesday. With no
        // current-day schedule the capture is queued exactly as with no
        // snapshot, and the backend re-checks the cutoff from captured_at.
        await controller.capture(
          type: AttendanceEventType.checkIn,
          workMode: 'wfh',
          today: _today(date: '2026-07-13', end: '17:00'),
          at: DateTime(2026, 7, 14, 18),
        );

        expect(syncService.lastEnqueued?.type, AttendanceEventType.checkIn);
      },
    );

    test('one old snapshot never stands in for several offline days', () async {
      final entries = <AttendanceQueueEntry>[];
      final container = containerWith(
        syncService: _OfflineSyncService(entries),
        store: _SeededStore(entries),
      );
      addTearDown(container.dispose);
      final controller = await controllerFrom(container);

      // Tuesday to Thursday offline, the cached snapshot still Monday's.
      for (final day in [14, 15, 16]) {
        await controller.capture(
          type: AttendanceEventType.checkIn,
          workMode: 'wfh',
          today: monday,
          at: DateTime(2026, 7, day, 8),
        );
        await expectLater(
          controller.capture(
            type: AttendanceEventType.checkIn,
            workMode: 'wfh',
            today: monday,
            at: DateTime(2026, 7, day, 9),
          ),
          ruleViolation('sudah melakukan check in'),
        );
        await controller.capture(
          type: AttendanceEventType.checkOut,
          today: monday,
          at: DateTime(2026, 7, day, 17),
        );
      }

      expect(
        entries.map((e) => (e.type, e.capturedAt.substring(0, 10))).toList(),
        [
          (AttendanceEventType.checkIn, '2026-07-14'),
          (AttendanceEventType.checkOut, '2026-07-14'),
          (AttendanceEventType.checkIn, '2026-07-15'),
          (AttendanceEventType.checkOut, '2026-07-15'),
          (AttendanceEventType.checkIn, '2026-07-16'),
          (AttendanceEventType.checkOut, '2026-07-16'),
        ],
      );
      expect(entries.every((e) => e.status == QueuedEventStatus.pending), true);
    });

    test(
      'the capture date comes from trusted time, not the device clock',
      () async {
        // The device clock reads the real current date; the trusted clock says
        // 14 July. Only the trusted date decides which snapshot is today's.
        final syncService = RecordingSyncService();
        final container = containerWith(
          syncService: syncService,
          store: _SeededStore(const []),
          trustedTime: _FixedTrustedTime(DateTime(2026, 7, 14, 9).toUtc()),
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        await expectLater(
          controller.capture(
            type: AttendanceEventType.checkIn,
            workMode: 'wfh',
            today: _today(date: '2026-07-14', checkInTime: '08:00'),
          ),
          ruleViolation('sudah melakukan check in'),
        );

        await controller.capture(
          type: AttendanceEventType.checkIn,
          workMode: 'wfh',
          today: monday,
        );
        expect(
          syncService.lastEnqueued?.capturedAt,
          startsWith('2026-07-14T09:00'),
        );
      },
    );

    test(
      'unavailable trusted time after a reboot still blocks capture',
      () async {
        final syncService = RecordingSyncService();
        final container = containerWith(
          syncService: syncService,
          store: _SeededStore(const []),
          trustedTime: _FixedTrustedTime.unavailable(
            const TrustedTimeUnavailableException(
              TrustedTimeUnavailableException.rebootMessage,
            ),
          ),
        );
        addTearDown(container.dispose);
        final controller = await controllerFrom(container);

        await expectLater(
          controller.capture(
            type: AttendanceEventType.checkIn,
            workMode: 'wfh',
            today: monday,
          ),
          throwsA(
            isA<TrustedTimeUnavailableException>().having(
              (e) => e.message,
              'message',
              TrustedTimeUnavailableException.rebootMessage,
            ),
          ),
        );
        expect(syncService.lastEnqueued, isNull);
      },
    );
  });
}
