import 'dart:async';

import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/data/sync/attendance_sync_service.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// In-memory [AttendanceQueueStore] keyed by client event id.
class _FakeQueueStore implements AttendanceQueueStore {
  final Map<String, AttendanceQueueEntry> entries = {};

  @override
  Future<void> save(AttendanceQueueEntry entry) async {
    entries[entry.clientEventId] = entry;
  }

  @override
  Future<bool> updateIfPresent(AttendanceQueueEntry entry) async {
    if (!entries.containsKey(entry.clientEventId)) return false;
    entries[entry.clientEventId] = entry;
    return true;
  }

  @override
  Future<void> replacePendingCheckOut(AttendanceQueueEntry entry) async {
    entries.removeWhere(
      (_, e) =>
          e.userId == entry.userId &&
          e.type == AttendanceEventType.checkOut &&
          e.status == QueuedEventStatus.pending &&
          e.capturedAt.substring(0, 10) == entry.capturedAt.substring(0, 10),
    );
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

/// A repository whose [syncEvent] always fails as if offline, but parks the
/// [gatedEventId]'s sync on [gate] so a test can control the exact interleave
/// between two concurrent enqueues.
class _GatedOfflineRepository implements AttendanceRepository {
  _GatedOfflineRepository({required this.gatedEventId, required this.gate});

  final String gatedEventId;
  final Future<void> gate;

  @override
  Future<ApiResult<AttendanceModel>> syncEvent(
    AttendanceQueueEntry entry,
  ) async {
    if (entry.clientEventId == gatedEventId) await gate;
    return const Failure(NetworkException());
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

AttendanceQueueEntry _checkOut(
  String id, {
  required String capturedAt,
  int owner = _userId,
}) {
  return AttendanceQueueEntry(
    clientEventId: id,
    userId: owner,
    type: AttendanceEventType.checkOut,
    latitude: '3.5952000',
    longitude: '98.6722000',
    capturedAt: capturedAt,
    createdAt: DateTime.parse(capturedAt),
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

  // Regression: two near-simultaneous same-day offline check-out captures must
  // never leave more than one pending row. Uses the real sqflite store so the
  // atomicity of replacePendingCheckOut is exercised end to end.
  group('enqueue check-out compaction under concurrency', () {
    late Database db;
    late SqfliteAttendanceQueueStore realStore;

    setUpAll(sqfliteFfiInit);

    setUp(() async {
      db = await openAppDatabase(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      );
      realStore = SqfliteAttendanceQueueStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('two simultaneous same-day offline check-outs leave exactly one '
        'pending, holding the latest captured_at', () async {
      // 'co-A' parks inside syncEvent until the gate opens; 'co-B' fails
      // (offline) immediately. This forces the exact interleave that used to
      // resurrect a compacted-away check-out:
      //   compaction(A) inserts A -> compaction(B) deletes A, inserts B
      //   -> B fails offline and stays pending
      //   -> A's gated offline sync finally fails and tries to persist.
      final gate = Completer<void>();
      final repository = _GatedOfflineRepository(
        gatedEventId: 'co-A',
        gate: gate.future,
      );
      final service = AttendanceSyncService(
        realStore,
        repository,
        clock: () => DateTime(2026, 7, 12, 14, 5),
      );

      // co-B is captured a few seconds after co-A, so it holds the latest
      // captured_at and must be the survivor.
      final fA = service.enqueue(
        _checkOut('co-A', capturedAt: '2026-07-12T15:00:00+07:00'),
      );
      final fB = service.enqueue(
        _checkOut('co-B', capturedAt: '2026-07-12T15:00:05+07:00'),
      );

      // B settles fully first: the queue now holds only the newest capture.
      await fB;

      // Releasing A lets its offline sync fail; the old insert-or-replace
      // persistence would resurrect co-A here, yielding two pending rows.
      gate.complete();
      await fA;

      final pending = await realStore.pendingEntries(_userId);
      expect(pending, hasLength(1));
      expect(pending.single.clientEventId, 'co-B');
      expect(pending.single.type, AttendanceEventType.checkOut);
      expect(pending.single.capturedAt, '2026-07-12T15:00:05+07:00');
      expect(await realStore.pendingCount(_userId), 1);
    });
  });
}
