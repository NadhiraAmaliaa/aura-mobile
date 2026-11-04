import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import '../attendance_month.dart';
import 'attendance_history_state.dart';

part 'attendance_history_notifier.g.dart';

/// Loads and paginates the intern's attendance history for one `yyyy-MM`
/// [month].
///
/// One provider instance per month: a month switch watches a different
/// instance, so a late response for the previous month can never land in the
/// newly selected one. The first page is fetched in `build()` and surfaced as
/// `AsyncValue<AttendanceHistoryState>` so the screen renders loading / error /
/// data exhaustively. Subsequent pages are appended via [loadMore], which keeps
/// the current data visible and toggles [AttendanceHistoryState.isLoadingMore].
///
/// The backend lists existing records on working days only; nothing is
/// synthesised here for days without a record.
@riverpod
class AttendanceHistoryNotifier extends _$AttendanceHistoryNotifier {
  /// Bumped by every [refresh]. A load started under an older generation
  /// belongs to a superseded list and is dropped. (Identity of `state.value`
  /// is not enough: `AsyncLoading` keeps the previous value.)
  int _generation = 0;

  @override
  Future<AttendanceHistoryState> build(String month) => _loadFirstPage();

  /// Re-fetch from the first page, showing a full loading state.
  Future<void> refresh() async {
    // Captured before the await: a ref is no longer mounted once its provider
    // is disposed or rebuilt, which also marks this load as superseded.
    final loadRef = ref;
    final generation = ++_generation;

    state = const AsyncLoading();
    final next = await AsyncValue.guard(_loadFirstPage);

    if (!loadRef.mounted || generation != _generation) return;
    state = next;
  }

  /// Fetch and append the next page. No-op while loading, after a failed page
  /// (until [retryLoadMore]), on error, or once the last page is reached.
  Future<void> loadMore() async {
    // `state.value` survives into a refresh's loading state; never page then.
    final current = state.value;
    if (current == null || state.isLoading || !current.canLoadMore) return;

    final loadRef = ref;
    final generation = _generation;
    final loading = current.copyWith(isLoadingMore: true);
    state = AsyncData(loading);

    final nextPage = (current.pagination?.currentPage ?? 1) + 1;
    final result = await ref
        .read(attendanceRepositoryProvider)
        .history(page: nextPage, month: month);

    // Drop the page when the provider was disposed or rebuilt, or the list was
    // refreshed meanwhile: it belongs to a superseded list.
    if (!loadRef.mounted || generation != _generation) return;

    state = AsyncData(switch (result) {
      Success(:final data) when attendanceItemsInMonth(data.items, month) =>
        loading.copyWith(
          items: [...loading.items, ...data.items],
          pagination: data.pagination,
          isLoadingMore: false,
        ),
      // Keep the loaded records visible and let the footer offer a retry.
      _ => loading.copyWith(isLoadingMore: false, loadMoreFailed: true),
    });
  }

  /// Retry the page that failed in [loadMore].
  Future<void> retryLoadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || !current.loadMoreFailed) return;

    state = AsyncData(current.copyWith(loadMoreFailed: false));
    await loadMore();
  }

  Future<AttendanceHistoryState> _loadFirstPage() async {
    final result = await ref
        .read(attendanceRepositoryProvider)
        .history(page: 1, month: month);
    return switch (result) {
      Success(:final data) when attendanceItemsInMonth(data.items, month) =>
        AttendanceHistoryState(items: data.items, pagination: data.pagination),
      Success() => throw attendanceMonthMismatch,
      Failure(:final exception) => throw exception,
    };
  }
}
