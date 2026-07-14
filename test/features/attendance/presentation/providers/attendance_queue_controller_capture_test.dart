import 'package:aura_mobile/core/device/device_time_providers.dart';
import 'package:aura_mobile/core/device/device_time_settings.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/sync/attendance_sync_service.dart';
import 'package:aura_mobile/features/attendance/data/sync/sync_providers.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_queue_controller.dart';
import 'package:aura_mobile/features/auth/presentation/providers/current_user_provider.dart';
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
      attendanceSyncServiceProvider.overrideWith((ref) async => syncService),
      attendanceQueueStoreProvider.overrideWith((ref) async => _DummyStore()),
      connectivityChangesProvider.overrideWith((ref) => const Stream.empty()),
    ],
  );
  return container;
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
      final container = containerFor(automatic: false, syncService: syncService);
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
}
