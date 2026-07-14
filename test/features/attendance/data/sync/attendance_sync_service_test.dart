import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/data/sync/attendance_sync_service.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [AttendanceQueueStore] keyed by client event id.
class _FakeQueueStore implements AttendanceQueueStore {
  final Map<String, AttendanceQueueEntry> entries = {};

  @override
  Future<void> save(AttendanceQueueEntry entry) async {
    entries[entry.clientEventId] = entry;
  }

  @override
  Future<List<AttendanceQueueEntry>> pendingEntries(int userId) async {
    final pending =
        entries.values
            .where(
              (e) =>
                  e.userId == userId && e.status == QueuedEventStatus.pending,
            )
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return pending;
  }

  @override
  Future<List<AttendanceQueueEntry>> allEntries(int userId) async =>
      entries.values.where((e) => e.userId == userId).toList();

  @override
  Future<int> pendingCount(int userId) async => entries.values
      .where((e) => e.userId == userId && e.status == QueuedEventStatus.pending)
      .length;

  @override
  Future<void> purgeSyncedBefore(int userId, DateTime cutoff) async {
    entries.removeWhere(
      (_, e) =>
          e.userId == userId &&
          e.status == QueuedEventStatus.synced &&
          e.createdAt.isBefore(cutoff),
    );
  }
}

/// A repository whose `syncEvent` returns a per-event scripted result (falling
/// back to [fallback]) and counts how many times it was called.
class _ScriptedRepository implements AttendanceRepository {
  _ScriptedRepository({
    this.byEventId = const {},
    ApiResult<AttendanceModel>? fallback,
  }) : fallback = fallback ?? Success(_ok);

  final Map<String, ApiResult<AttendanceModel>> byEventId;
  final ApiResult<AttendanceModel> fallback;

  final List<String> calls = [];

  @override
  Future<ApiResult<AttendanceModel>> syncEvent(
    AttendanceQueueEntry entry,
  ) async {
    calls.add(entry.clientEventId);
    return byEventId[entry.clientEventId] ?? fallback;
  }

  @override
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AttendanceHistoryModel>> history({
    int? page,
    int? perPage,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<List<AttendanceLocationModel>>> locations() =>
      throw UnimplementedError();
}

const _ok = AttendanceModel(id: 1, status: 'present', statusLabel: 'Hadir');

const _userId = 7;

AttendanceQueueEntry _entry(
  String id, {
  int owner = _userId,
  DateTime? createdAt,
}) {
  return AttendanceQueueEntry(
    clientEventId: id,
    userId: owner,
    type: AttendanceEventType.checkIn,
    workMode: 'wfo',
    latitude: '3.5952000',
    longitude: '98.6722000',
    capturedAt: '2026-07-12T14:03:07+07:00',
    createdAt: createdAt ?? DateTime(2026, 7, 12, 14, 3, 7),
  );
}

void main() {
  late _FakeQueueStore store;

  setUp(() => store = _FakeQueueStore());

  AttendanceSyncService serviceWith(
    _ScriptedRepository repository, {
    DateTime Function()? clock,
  }) {
    return AttendanceSyncService(
      store,
      repository,
      clock: clock ?? () => DateTime(2026, 7, 12, 14, 5),
    );
  }

  group('enqueue', () {
    test('persists then marks the entry synced on success', () async {
      final service = serviceWith(_ScriptedRepository());

      final result = await service.enqueue(_entry('a'));

      expect(result.status, QueuedEventStatus.synced);
      expect(result.attempts, 1);
      expect(result.syncedAt, DateTime(2026, 7, 12, 14, 5));
      expect(store.entries['a']!.status, QueuedEventStatus.synced);
    });

    test('marks the entry rejected on a validation failure', () async {
      final service = serviceWith(
        _ScriptedRepository(
          byEventId: {
            'a': const Failure(
              ValidationException(message: 'Di luar radius kantor.'),
            ),
          },
        ),
      );

      final result = await service.enqueue(_entry('a'));

      expect(result.status, QueuedEventStatus.rejected);
      expect(result.lastError, 'Di luar radius kantor.');
    });

    test('keeps the entry pending on a network failure', () async {
      final service = serviceWith(
        _ScriptedRepository(
          byEventId: {'a': const Failure(NetworkException())},
        ),
      );

      final result = await service.enqueue(_entry('a'));

      expect(result.status, QueuedEventStatus.pending);
      expect(result.attempts, 1);
      expect(result.lastError, isNotNull);
    });

    test('keeps the entry pending on a 5xx server error', () async {
      final service = serviceWith(
        _ScriptedRepository(
          byEventId: {'a': const Failure(ServerException(statusCode: 503))},
        ),
      );

      final result = await service.enqueue(_entry('a'));

      expect(result.status, QueuedEventStatus.pending);
    });

    test('rejects on a non-auth 4xx server error', () async {
      final service = serviceWith(
        _ScriptedRepository(
          byEventId: {'a': const Failure(ServerException(statusCode: 409))},
        ),
      );

      final result = await service.enqueue(_entry('a'));

      expect(result.status, QueuedEventStatus.rejected);
    });

    test(
      'keeps the entry pending on a 401 so it retries after re-auth',
      () async {
        final service = serviceWith(
          _ScriptedRepository(
            byEventId: {'a': const Failure(UnauthorizedException())},
          ),
        );

        final result = await service.enqueue(_entry('a'));

        expect(result.status, QueuedEventStatus.pending);
      },
    );
  });

  group('flush', () {
    test('syncs all pending entries oldest first', () async {
      await store.save(_entry('old', createdAt: DateTime(2026, 7, 12, 8)));
      await store.save(_entry('new', createdAt: DateTime(2026, 7, 12, 10)));
      final repository = _ScriptedRepository();
      final service = serviceWith(repository);

      final summary = await service.flush(_userId);

      expect(repository.calls, ['old', 'new']);
      expect(summary.synced, 2);
      expect(summary.rejected, 0);
      expect(summary.stillPending, 0);
    });

    test('stops at the first transient failure', () async {
      await store.save(_entry('first', createdAt: DateTime(2026, 7, 12, 8)));
      await store.save(_entry('second', createdAt: DateTime(2026, 7, 12, 9)));
      await store.save(_entry('third', createdAt: DateTime(2026, 7, 12, 10)));
      final repository = _ScriptedRepository(
        byEventId: {'second': const Failure(NetworkException())},
      );
      final service = serviceWith(repository);

      final summary = await service.flush(_userId);

      // 'third' is never attempted.
      expect(repository.calls, ['first', 'second']);
      expect(summary.synced, 1);
      expect(summary.stillPending, 2);
      expect(store.entries['third']!.status, QueuedEventStatus.pending);
    });

    test('counts a terminal rejection and keeps going', () async {
      await store.save(_entry('bad', createdAt: DateTime(2026, 7, 12, 8)));
      await store.save(_entry('good', createdAt: DateTime(2026, 7, 12, 9)));
      final repository = _ScriptedRepository(
        byEventId: {
          'bad': const Failure(ValidationException(message: 'Ditolak.')),
        },
      );
      final service = serviceWith(repository);

      final summary = await service.flush(_userId);

      expect(repository.calls, ['bad', 'good']);
      expect(summary.synced, 1);
      expect(summary.rejected, 1);
      expect(summary.stillPending, 0);
    });

    test('does not re-send already synced or rejected entries', () async {
      await store.save(
        _entry('done').copyWith(status: QueuedEventStatus.synced),
      );
      await store.save(
        _entry('nope').copyWith(status: QueuedEventStatus.rejected),
      );
      final repository = _ScriptedRepository();
      final service = serviceWith(repository);

      final summary = await service.flush(_userId);

      expect(repository.calls, isEmpty);
      expect(summary.synced, 0);
    });

    test('only syncs the requested user\'s pending entries', () async {
      await store.save(_entry('a-in', createdAt: DateTime(2026, 7, 12, 8)));
      await store.save(
        _entry('b-in', owner: 8, createdAt: DateTime(2026, 7, 12, 9)),
      );
      final repository = _ScriptedRepository();
      final service = serviceWith(repository);

      final summary = await service.flush(_userId);

      // Account 8's entry is never sent under account 7's flush.
      expect(repository.calls, ['a-in']);
      expect(summary.synced, 1);
      expect(store.entries['b-in']!.status, QueuedEventStatus.pending);
    });
  });
}
