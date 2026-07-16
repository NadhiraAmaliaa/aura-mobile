import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/leave/data/leave_providers.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/data/models/leave_submission.dart';
import 'package:aura_mobile/features/leave/data/repositories/leave_repository.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_list_notifier.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_list_state.dart';
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
  Future<ApiResult<void>> downloadApprovedPdf(LeaveRequestModel request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) =>
      throw UnimplementedError();
}

ProviderContainer _container(_FakeLeaveRepository repository) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [leaveRepositoryProvider.overrideWithValue(repository)],
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
  });
}
