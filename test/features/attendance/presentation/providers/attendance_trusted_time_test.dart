import 'package:aura_mobile/core/device/device_time_providers.dart';
import 'package:aura_mobile/core/device/device_time_settings.dart';
import 'package:aura_mobile/core/device/trusted_time_providers.dart';
import 'package:aura_mobile/core/device/trusted_time_service.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
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

/// A fake TrustedTimeService that returns a predetermined time.
class FakeTrustedTimeService implements TrustedTimeService {
  FakeTrustedTimeService({
    required this.trustedNow,
    this.shouldThrow = false,
  });

  DateTime trustedNow;
  bool shouldThrow;

  @override
  Future<DateTime> now() async {
    if (shouldThrow) {
      throw const TrustedTimeUnavailableException();
    }
    return trustedNow;
  }

  @override
  Future<bool> get isAvailable async => !shouldThrow;

  @override
  Future<void> setAnchor(DateTime serverTimeUtc) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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

ProviderContainer _container({
  required bool? automatic,
  required RecordingSyncService syncService,
  required FakeTrustedTimeService trustedTime,
}) {
  return ProviderContainer.test(
    overrides: [
      currentUserIdProvider.overrideWithValue(7),
      deviceTimeSettingsProvider.overrideWithValue(
        FakeDeviceTimeSettings(automatic),
      ),
      trustedTimeServiceProvider.overrideWith(
        (ref) async => trustedTime,
      ),
      attendanceSyncServiceProvider.overrideWith((ref) async => syncService),
      attendanceQueueStoreProvider.overrideWith((ref) async => _DummyStore()),
      connectivityChangesProvider.overrideWith((ref) => const Stream.empty()),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -- Scenario 1: Android Automatic Time OFF → attendance blocked.
  test('Android auto-time OFF blocks capture before TrustedTime', () async {
    final syncService = RecordingSyncService();
    final trustedTime = FakeTrustedTimeService(
      trustedNow: DateTime.utc(2026, 8, 17, 10, 0, 0),
    );
    final container = _container(
      automatic: false,
      syncService: syncService,
      trustedTime: trustedTime,
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

  // -- Scenario 2: Android Automatic Time ON + valid anchor → trusted capture.
  test('Android auto-time ON + valid anchor → capture succeeds', () async {
    final syncService = RecordingSyncService();
    final trustedTime = FakeTrustedTimeService(
      trustedNow: DateTime.utc(2026, 8, 17, 10, 0, 0),
    );
    final container = _container(
      automatic: true,
      syncService: syncService,
      trustedTime: trustedTime,
    );
    addTearDown(container.dispose);

    await container.read(attendanceQueueControllerProvider.future);
    final controller = container.read(
      attendanceQueueControllerProvider.notifier,
    );

    await controller.capture(type: AttendanceEventType.checkIn);

    expect(syncService.lastEnqueued, isNotNull);
    expect(syncService.lastEnqueued!.type, AttendanceEventType.checkIn);
    // capturedAt should be formatted from the trusted UTC time converted to
    // local, NOT from DateTime.now().
    final expectedCapturedAt = formatCapturedAt(
      DateTime.utc(2026, 8, 17, 10, 0, 0).toLocal(),
    );
    expect(syncService.lastEnqueued!.capturedAt, expectedCapturedAt);
  });

  // -- Scenario 3: iOS + valid anchor → trusted capture succeeds.
  test('iOS (null auto-time) + valid anchor → capture succeeds', () async {
    final syncService = RecordingSyncService();
    final trustedTime = FakeTrustedTimeService(
      trustedNow: DateTime.utc(2026, 8, 17, 14, 0, 0),
    );
    final container = _container(
      automatic: null, // iOS
      syncService: syncService,
      trustedTime: trustedTime,
    );
    addTearDown(container.dispose);

    await container.read(attendanceQueueControllerProvider.future);
    final controller = container.read(
      attendanceQueueControllerProvider.notifier,
    );

    await controller.capture(type: AttendanceEventType.checkIn);

    expect(syncService.lastEnqueued, isNotNull);
  });

  // -- Scenario 4: Offline with valid anchor → Check In succeeds locally.
  test('offline + valid anchor → Check In succeeds', () async {
    final syncService = RecordingSyncService();
    final trustedTime = FakeTrustedTimeService(
      trustedNow: DateTime.utc(2026, 8, 17, 8, 30, 0),
    );
    final container = _container(
      automatic: true,
      syncService: syncService,
      trustedTime: trustedTime,
    );
    addTearDown(container.dispose);

    await container.read(attendanceQueueControllerProvider.future);
    final controller = container.read(
      attendanceQueueControllerProvider.notifier,
    );

    final result = await controller.capture(
      type: AttendanceEventType.checkIn,
    );

    expect(result.type, AttendanceEventType.checkIn);
  });

  // -- Scenario 5: Offline with valid anchor → Check Out succeeds locally.
  test('offline + valid anchor → Check Out succeeds', () async {
    final syncService = RecordingSyncService();
    // Use a trusted time that stays on the same local calendar date as the
    // seeded check-in, regardless of the device's timezone.
    final checkInLocal = DateTime(2026, 8, 17, 8, 0, 0);
    final checkOutLocal = DateTime(2026, 8, 17, 17, 0, 0);

    final trustedTime = FakeTrustedTimeService(
      trustedNow: checkOutLocal.toUtc(),
    );

    // Pre-seed a check-in so check-out is allowed.
    final seededStore = _SeededStore([
      AttendanceQueueEntry(
        clientEventId: 'ci-1',
        userId: 7,
        type: AttendanceEventType.checkIn,
        capturedAt: formatCapturedAt(checkInLocal),
        createdAt: checkInLocal,
      ),
    ]);

    final container = ProviderContainer.test(
      overrides: [
        currentUserIdProvider.overrideWithValue(7),
        deviceTimeSettingsProvider.overrideWithValue(
          FakeDeviceTimeSettings(true),
        ),
        trustedTimeServiceProvider.overrideWith(
          (ref) async => trustedTime,
        ),
        attendanceSyncServiceProvider.overrideWith(
          (ref) async => syncService,
        ),
        attendanceQueueStoreProvider.overrideWith(
          (ref) async => seededStore,
        ),
        connectivityChangesProvider.overrideWith(
          (ref) => const Stream.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(attendanceQueueControllerProvider.future);
    final controller = container.read(
      attendanceQueueControllerProvider.notifier,
    );

    final result = await controller.capture(
      type: AttendanceEventType.checkOut,
    );

    expect(result.type, AttendanceEventType.checkOut);
  });

  // -- Scenario 9/10: Reboot + offline → attendance blocked.
  test('TrustedTime unavailable → capture throws', () async {
    final syncService = RecordingSyncService();
    final trustedTime = FakeTrustedTimeService(
      trustedNow: DateTime.utc(2026, 8, 17, 10, 0, 0),
      shouldThrow: true,
    );
    final container = _container(
      automatic: true,
      syncService: syncService,
      trustedTime: trustedTime,
    );
    addTearDown(container.dispose);

    await container.read(attendanceQueueControllerProvider.future);
    final controller = container.read(
      attendanceQueueControllerProvider.notifier,
    );

    await expectLater(
      controller.capture(type: AttendanceEventType.checkIn),
      throwsA(isA<TrustedTimeUnavailableException>()),
    );
    expect(syncService.lastEnqueued, isNull);
  });

  // -- Scenario 7: Confirm no DateTime.now() fallback on Android.
  test('Android auto-time ON but no anchor → capture throws, no fallback',
      () async {
    final syncService = RecordingSyncService();
    final trustedTime = FakeTrustedTimeService(
      trustedNow: DateTime.utc(2026, 8, 17, 10, 0, 0),
      shouldThrow: true, // No valid anchor
    );
    final container = _container(
      automatic: true, // Auto-time ON
      syncService: syncService,
      trustedTime: trustedTime,
    );
    addTearDown(container.dispose);

    await container.read(attendanceQueueControllerProvider.future);
    final controller = container.read(
      attendanceQueueControllerProvider.notifier,
    );

    // Even though auto-time is ON, the capture should fail because
    // TrustedTime has no valid anchor — NOT fall back to DateTime.now().
    await expectLater(
      controller.capture(type: AttendanceEventType.checkIn),
      throwsA(isA<TrustedTimeUnavailableException>()),
    );
    expect(syncService.lastEnqueued, isNull);
  });

  // -- Scenario 18: Timezone representation does not corrupt the intended
  //    attendance calendar date.
  test('trusted UTC time converts to local with correct offset in capturedAt',
      () async {
    final syncService = RecordingSyncService();
    // A UTC time that is still "today" in UTC but might be "tomorrow" in
    // Asia/Jakarta (UTC+7): 2026-08-17T20:00:00Z = 2026-08-18T03:00:00+07:00.
    final trustedTime = FakeTrustedTimeService(
      trustedNow: DateTime.utc(2026, 8, 17, 20, 0, 0),
    );
    final container = _container(
      automatic: true,
      syncService: syncService,
      trustedTime: trustedTime,
    );
    addTearDown(container.dispose);

    await container.read(attendanceQueueControllerProvider.future);
    final controller = container.read(
      attendanceQueueControllerProvider.notifier,
    );

    await controller.capture(type: AttendanceEventType.checkIn);

    final capturedAt = syncService.lastEnqueued!.capturedAt;
    // The capturedAt string should be formatted from the local representation
    // of the trusted time, with the device's UTC offset explicitly included.
    final expectedCapturedAt = formatCapturedAt(
      DateTime.utc(2026, 8, 17, 20, 0, 0).toLocal(),
    );
    expect(capturedAt, expectedCapturedAt);
  });
}

/// A queue store pre-seeded with entries for testing.
class _SeededStore implements AttendanceQueueStore {
  _SeededStore(this.seed);

  final List<AttendanceQueueEntry> seed;

  @override
  Future<List<AttendanceQueueEntry>> allEntries(int userId) async =>
      seed.where((e) => e.userId == userId).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
