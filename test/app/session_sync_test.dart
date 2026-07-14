import 'package:aura_mobile/app/session_sync.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:aura_mobile/features/attendance/data/local/offline_providers.dart';
import 'package:aura_mobile/features/attendance/data/sync/attendance_sync_service.dart';
import 'package:aura_mobile/features/attendance/data/sync/sync_providers.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:aura_mobile/features/auth/data/auth_providers.dart';
import 'package:aura_mobile/features/auth/data/models/auth_models.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal authenticated auth repository. Only [currentToken] and [me] are
/// exercised by the session bootstrap.
class _AuthedRepository implements AuthRepository {
  const _AuthedRepository(this.user);

  final UserModel user;

  @override
  Future<String?> currentToken() async => 'valid-token';

  @override
  Future<ApiResult<UserModel>> me() async => Success(user);

  @override
  Future<UserModel?> cachedUser() async => user;

  @override
  Future<ApiResult<void>> logout() async => const Success<void>(null);

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) =>
      throw UnimplementedError();
}

/// An unauthenticated auth repository (no token) — the session stays on login.
class _AnonymousRepository implements AuthRepository {
  const _AnonymousRepository();

  @override
  Future<String?> currentToken() async => null;

  @override
  Future<ApiResult<UserModel>> me() => throw UnimplementedError();

  @override
  Future<UserModel?> cachedUser() async => null;

  @override
  Future<ApiResult<void>> logout() async => const Success<void>(null);

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) =>
      throw UnimplementedError();
}

/// A sync service that only counts [flush] calls; the queue plumbing beneath is
/// never touched (the base ctor gets throwing dummies it will not call).
class _CountingSyncService extends AttendanceSyncService {
  _CountingSyncService() : super(_DummyStore(), _DummyRepository());

  int flushes = 0;

  @override
  Future<SyncSummary> flush(int userId) async {
    flushes++;
    return const SyncSummary(synced: 0, rejected: 0, stillPending: 0);
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

const _user = UserModel(id: 7, name: 'Intern Satu', role: 'intern');

void main() {
  // The queue controller subscribes to connectivity changes on build; the
  // binding must exist even though that stream is overridden below.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sessionQueueSync', () {
    test('flushes the queue once the session is authenticated', () async {
      final syncService = _CountingSyncService();
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            const _AuthedRepository(_user),
          ),
          attendanceSyncServiceProvider.overrideWith(
            (ref) async => syncService,
          ),
          attendanceQueueStoreProvider.overrideWith(
            (ref) async => _DummyStore(),
          ),
          connectivityChangesProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
        ],
      );
      final sub = container.listen(sessionQueueSyncProvider, (_, _) {});
      addTearDown(sub.close);

      // Let the auth bootstrap resolve to authenticated, then let the
      // fire-and-forget flush run.
      await container.read(authProvider.future);
      await pumpEventQueue();

      expect(syncService.flushes, greaterThanOrEqualTo(1));
    });

    test('never touches the queue while unauthenticated', () async {
      final syncService = _CountingSyncService();
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            const _AnonymousRepository(),
          ),
          attendanceSyncServiceProvider.overrideWith(
            (ref) async => syncService,
          ),
          attendanceQueueStoreProvider.overrideWith(
            (ref) async => _DummyStore(),
          ),
          connectivityChangesProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
        ],
      );
      final sub = container.listen(sessionQueueSyncProvider, (_, _) {});
      addTearDown(sub.close);

      await container.read(authProvider.future);
      await pumpEventQueue();

      expect(syncService.flushes, isZero);
    });
  });
}
