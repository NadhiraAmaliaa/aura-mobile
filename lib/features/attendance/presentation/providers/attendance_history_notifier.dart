import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/attendance_providers.dart';
import 'attendance_history_state.dart';

part 'attendance_history_notifier.g.dart';

/// Loads and paginates the intern's attendance history.
///
/// The first page is fetched in `build()` and surfaced as
/// `AsyncValue<AttendanceHistoryState>` so the screen renders loading / error /
/// data exhaustively. Subsequent pages are appended via [loadMore], which keeps
/// the current data visible and toggles [AttendanceHistoryState.isLoadingMore].
@riverpod
class AttendanceHistoryNotifier extends _$AttendanceHistoryNotifier {
  @override
  Future<AttendanceHistoryState> build() => _loadFirstPage();

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
        .read(attendanceRepositoryProvider)
        .history(page: nextPage);

    state = result.fold(
      onSuccess: (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          pagination: page.pagination,
          isLoadingMore: false,
        ),
      ),
      onFailure: (exception) {
        // Surface the error but keep the already-loaded records visible.
        return AsyncData(current.copyWith(isLoadingMore: false));
      },
    );
  }

  Future<AttendanceHistoryState> _loadFirstPage() async {
    final result = await ref
        .read(attendanceRepositoryProvider)
        .history(page: 1);
    return result.fold(
      onSuccess: (page) => AttendanceHistoryState(
        items: page.items,
        pagination: page.pagination,
      ),
      onFailure: (exception) => throw exception,
    );
  }
}
