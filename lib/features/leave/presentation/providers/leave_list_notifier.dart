import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/leave_providers.dart';
import 'leave_list_state.dart';

part 'leave_list_notifier.g.dart';

/// Loads and paginates a section of the intern's leave requests.
///
/// One instance per [LeaveListFilter] (pending / history). The first page is
/// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
/// screen renders loading / error / data exhaustively. Subsequent pages are
/// appended via [loadMore], which keeps the current data visible and toggles
/// [LeaveListState.isLoadingMore].
@riverpod
class LeaveListNotifier extends _$LeaveListNotifier {
  @override
  Future<LeaveListState> build(LeaveListFilter filter) => _loadFirstPage();

  /// Re-fetch from the first page, showing a full loading state.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFirstPage);
  }

  /// Fetch and append the next page. No-op while loading, on error, or when the
  /// last page has already been reached.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = (current.pagination?.currentPage ?? 1) + 1;
    final result = await ref
        .read(leaveRepositoryProvider)
        .list(filter: filter.query, page: nextPage);

    state = result.fold(
      onSuccess: (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          pagination: page.pagination,
          isLoadingMore: false,
        ),
      ),
      // Surface the error but keep the already-loaded records visible.
      onFailure: (_) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }

  Future<LeaveListState> _loadFirstPage() async {
    final result = await ref
        .read(leaveRepositoryProvider)
        .list(filter: filter.query, page: 1);
    return result.fold(
      onSuccess: (page) =>
          LeaveListState(items: page.items, pagination: page.pagination),
      onFailure: (exception) => throw exception,
    );
  }
}
