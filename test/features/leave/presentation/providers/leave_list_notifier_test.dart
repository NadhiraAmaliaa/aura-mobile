import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/auth/presentation/providers/current_user_provider.dart';
import 'package:aura_mobile/features/leave/data/leave_providers.dart';
import 'package:aura_mobile/features/leave/data/local/leave_list_cache_store.dart';
import 'package:aura_mobile/features/leave/data/local/leave_offline_providers.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/data/models/leave_submission.dart';
import 'package:aura_mobile/features/leave/data/repositories/leave_repository.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_list_notifier.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_list_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LeaveRequestModel _request(int id) => LeaveRequestModel(
  id: id,
  requestNumber: 'LR-2026-000$id',
  type: 'izin',
  typeLabel: 'Izin',
  reason: 'Alasan $id',
  status: 'pending',
  statusLabel: 'Menunggu',
);

LeaveListModel _page({
  required List<int> ids,
  required int currentPage,
  required bool hasMore,
}) => LeaveListModel(
  items: ids.map(_request).toList(),
  pagination: LeavePaginationModel(
    currentPage: currentPage,
    lastPage: hasMore ? currentPage + 1 : currentPage,
    total: 99,
    hasMore: hasMore,
  ),
);

/// A repository whose `list` returns a scripted page per requested page number
/// and records the (filter, page) pairs it was called with.
class _FakeLeaveRepository implements LeaveRepository {
  _FakeLeaveRepository(this._pages);

  final Map<int, ApiResult<LeaveListModel>> _pages;
  final List<({String? filter, int? page})> listCalls = [];

  @override
  Future<ApiResult<LeaveListModel>> list({
    String? filter,
    int? page,
    int? perPage,
  }) async {
    listCalls.add((filter: filter, page: page));
    return _pages[page ?? 1] ??
        Failure(const UnknownException(message: 'no page scripted'));
  }

  @override
  Future<ApiResult<LeaveRequestModel>> detail(int id) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<LeaveRequestModel>> submit(LeaveSubmission submission) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> printApprovedPdf(LeaveRequestModel request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) =>
      throw UnimplementedError();
}

/// Connectivity stub reporting a fixed transport so the offline branch is
/// deterministic.
class _FakeConnectivity implements Connectivity {
  _FakeConnectivity({required this.connected});

  final bool connected;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      connected ? [ConnectivityResult.wifi] : [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

/// In-memory leave-list cache keyed by (userId, filter), counting saves.
class _FakeLeaveCache implements LeaveListCacheStore {
  final Map<String, LeaveListModel> _byKey = {};
  int saves = 0;

  String _key(int userId, String filter) => '$userId:$filter';

  void seed(int userId, String filter, LeaveListModel page) {
    _byKey[_key(userId, filter)] = page;
  }

  @override
  Future<LeaveListModel?> read(int userId, String filter) async =>
      _byKey[_key(userId, filter)];

  @override
  Future<void> save(int userId, String filter, LeaveListModel page) async {
    _byKey[_key(userId, filter)] = page;
    saves++;
  }
}

ProviderContainer _container(
  _FakeLeaveRepository repository, {
  bool connected = true,
  _FakeLeaveCache? cache,
  int? userId = 7,
}) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      leaveRepositoryProvider.overrideWithValue(repository),
      currentUserIdProvider.overrideWithValue(userId),
      connectivityProvider.overrideWithValue(
        _FakeConnectivity(connected: connected),
      ),
      leaveListCacheStoreProvider.overrideWith(
        (ref) async => cache ?? _FakeLeaveCache(),
      ),
    ],
  );
}

void main() {
  group('LeaveListNotifier', () {
    test('loads the first page with the filter query on build', () async {
      final repository = _FakeLeaveRepository({
        1: Success(_page(ids: [1, 2], currentPage: 1, hasMore: false)),
      });
      final container = _container(repository);

      final state = await container.read(
        leaveListProvider(LeaveListFilter.pending).future,
      );

      expect(state.items.map((e) => e.id), [1, 2]);
      expect(state.hasMore, isFalse);
      expect(repository.listCalls.single.filter, 'pending');
      expect(repository.listCalls.single.page, 1);
    });

    test('loadMore appends the next page and advances the cursor', () async {
      final repository = _FakeLeaveRepository({
        1: Success(_page(ids: [1, 2], currentPage: 1, hasMore: true)),
        2: Success(_page(ids: [3, 4], currentPage: 2, hasMore: false)),
      });
      final container = _container(repository);
      final notifier = container.read(
        leaveListProvider(LeaveListFilter.history).notifier,
      );

      await container.read(leaveListProvider(LeaveListFilter.history).future);
      await notifier.loadMore();

      final state = container
          .read(leaveListProvider(LeaveListFilter.history))
          .value!;
      expect(state.items.map((e) => e.id), [1, 2, 3, 4]);
      expect(state.hasMore, isFalse);
      expect(repository.listCalls.map((c) => c.page), [1, 2]);
      expect(repository.listCalls.every((c) => c.filter == 'history'), isTrue);
    });

    test('loadMore is a no-op when there are no more pages', () async {
      final repository = _FakeLeaveRepository({
        1: Success(_page(ids: [1], currentPage: 1, hasMore: false)),
      });
      final container = _container(repository);
      final notifier = container.read(
        leaveListProvider(LeaveListFilter.pending).notifier,
      );

      await container.read(leaveListProvider(LeaveListFilter.pending).future);
      await notifier.loadMore();

      expect(repository.listCalls, hasLength(1));
    });

    test('surfaces an error when the first page fails', () async {
      final repository = _FakeLeaveRepository({
        1: Failure(const NetworkException()),
      });
      final container = _container(repository);

      await expectLater(
        container.read(leaveListProvider(LeaveListFilter.pending).future),
        throwsA(isA<NetworkException>()),
      );
    });

    test('keeps existing items when loadMore fails', () async {
      final repository = _FakeLeaveRepository({
        1: Success(_page(ids: [1, 2], currentPage: 1, hasMore: true)),
        2: Failure(const NetworkException()),
      });
      final container = _container(repository);
      final notifier = container.read(
        leaveListProvider(LeaveListFilter.history).notifier,
      );

      await container.read(leaveListProvider(LeaveListFilter.history).future);
      await notifier.loadMore();

      final state = container
          .read(leaveListProvider(LeaveListFilter.history))
          .value!;
      expect(state.items.map((e) => e.id), [1, 2]);
      expect(state.isLoadingMore, isFalse);
    });

    test('shows cached data without hitting the network when offline', () async {
      final repository = _FakeLeaveRepository({});
      final cache = _FakeLeaveCache()
        ..seed(
          7,
          LeaveListFilter.pending.query,
          _page(ids: [1, 2, 3], currentPage: 1, hasMore: false),
        );
      final container = _container(repository, connected: false, cache: cache);

      final state = await container.read(
        leaveListProvider(LeaveListFilter.pending).future,
      );

      expect(state.items.map((e) => e.id), [1, 2, 3]);
      expect(state.isFromCache, isTrue);
      expect(state.isOffline, isTrue);
      expect(repository.listCalls, isEmpty);
    });

    test('caches the payload after a successful fetch', () async {
      final repository = _FakeLeaveRepository({
        1: Success(_page(ids: [1, 2], currentPage: 1, hasMore: false)),
      });
      final cache = _FakeLeaveCache();
      final container = _container(repository, cache: cache);

      final state = await container.read(
        leaveListProvider(LeaveListFilter.pending).future,
      );

      expect(state.items.map((e) => e.id), [1, 2]);
      expect(state.isFromCache, isFalse);
      expect(cache.saves, 1);
      expect(
        (await cache.read(7, LeaveListFilter.pending.query))!.items.map(
          (e) => e.id,
        ),
        [1, 2],
      );
    });

    test('keeps the existing cache when a refresh fails', () async {
      final repository = _FakeLeaveRepository({
        1: Failure(const NetworkException()),
      });
      final cache = _FakeLeaveCache()
        ..seed(
          7,
          LeaveListFilter.pending.query,
          _page(ids: [1, 2], currentPage: 1, hasMore: false),
        );
      final container = _container(repository, cache: cache);

      final state = await container.read(
        leaveListProvider(LeaveListFilter.pending).future,
      );
      // Let the background refresh run and fail.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(state.items.map((e) => e.id), [1, 2]);
      expect(cache.saves, 0);
      expect(
        (await cache.read(7, LeaveListFilter.pending.query))!.items.map(
          (e) => e.id,
        ),
        [1, 2],
      );
    });

    test('throws when offline and no cache has ever been stored', () async {
      final repository = _FakeLeaveRepository({});
      final container = _container(repository, connected: false);

      await expectLater(
        container.read(leaveListProvider(LeaveListFilter.pending).future),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
