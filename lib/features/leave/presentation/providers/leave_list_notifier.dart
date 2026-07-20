import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/connectivity_providers.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/leave_providers.dart';
import '../../data/local/leave_list_cache_store.dart';
import '../../data/local/leave_offline_providers.dart';
import '../../data/models/leave_models.dart';
import 'leave_list_state.dart';

part 'leave_list_notifier.g.dart';

/// Loads and paginates a section of the intern's leave requests.
///
/// One instance per [LeaveListFilter] (pending / history). The first page is
/// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
/// screen renders loading / error / data exhaustively. Subsequent pages are
/// appended via [loadMore], which keeps the current data visible and toggles
/// [LeaveListState.isLoadingMore].
///
/// Cache-first / network-refresh: on open, a cached first-page snapshot for the
/// current user is shown immediately when present; when online, the latest data
/// is fetched in the background and swapped in on success, replacing the cache.
/// When offline with a cached snapshot, it stays on screen flagged as offline
/// (a non-blocking notice). When offline with no cache, an offline error is
/// surfaced. Cached data is a read-only snapshot — never authoritative for
/// submissions (those stay online-only).
@riverpod
class LeaveListNotifier extends _$LeaveListNotifier {
  bool _disposed = false;

  @override
  Future<LeaveListState> build(LeaveListFilter filter) {
    ref.onDispose(() => _disposed = true);
    return _initialLoad(preferCacheFirst: true);
  }

  /// Re-fetch from the first page, showing a full loading state. Forces a
  /// network attempt (falling back to cache only if the device is offline).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _initialLoad(preferCacheFirst: false));
  }

  /// Fetch and append the next page. No-op while loading, on error, or when the
  /// last page has already been reached. Pagination is online-only — offline
  /// snapshots only ever hold the first page.
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

  /// The cache-first / network flow shared by [build] and [refresh].
  ///
  /// When [preferCacheFirst] and a cached snapshot exists, it is returned
  /// immediately (and, if online, a background refresh is kicked off). Otherwise
  /// the network is queried, with the cache used as an offline fallback.
  Future<LeaveListState> _initialLoad({required bool preferCacheFirst}) async {
    final userId = ref.read(currentUserIdProvider);
    final cache = await ref.read(leaveListCacheStoreProvider.future);
    final cached = userId == null
        ? null
        : await cache.read(userId, filter.query);
    final online = hasConnectivity(
      await ref.read(connectivityProvider).checkConnectivity(),
    );

    if (preferCacheFirst && cached != null) {
      if (online) {
        // Show the cache now; refresh in the background and swap on success.
        unawaited(_backgroundRefresh());
        return _cacheState(cached, isOffline: false);
      }
      return _cacheState(cached, isOffline: true);
    }

    if (!online) {
      // No cache to show (or a forced refresh) while offline: return a cached
      // snapshot when one exists, otherwise surface an offline error state.
      if (cached != null) return _cacheState(cached, isOffline: true);
      throw const NetworkException(
        message: 'Anda sedang offline dan belum ada data tersimpan.',
      );
    }

    final result = await ref
        .read(leaveRepositoryProvider)
        .list(filter: filter.query, page: 1);
    return switch (result) {
      Success(:final data) => await _networkState(cache, userId, data),
      // A rejected session must surface so the UI can re-auth.
      Failure(:final exception) when exception is UnauthorizedException =>
        throw exception,
      // Unreachable server / timeout / 5xx → fall back to a cached snapshot when
      // one exists, otherwise surface the error.
      Failure(:final exception) =>
        cached != null
            ? _cacheState(cached, isOffline: false)
            : throw exception,
    };
  }

  /// Fetches the first page in the background and swaps it in on success,
  /// replacing the cache. Best-effort: any failure keeps the cached data that is
  /// already on screen.
  Future<void> _backgroundRefresh() async {
    try {
      final result = await ref
          .read(leaveRepositoryProvider)
          .list(filter: filter.query, page: 1);
      if (_disposed || result is! Success<LeaveListModel>) return;

      final userId = ref.read(currentUserIdProvider);
      final cache = await ref.read(leaveListCacheStoreProvider.future);
      await _save(cache, userId, result.data);
      if (_disposed) return;
      state = AsyncData(_networkStateFrom(result.data));
    } on Object {
      // Background refresh is best-effort; keep the cached snapshot on failure.
    }
  }

  Future<LeaveListState> _networkState(
    LeaveListCacheStore cache,
    int? userId,
    LeaveListModel page,
  ) async {
    await _save(cache, userId, page);
    return _networkStateFrom(page);
  }

  LeaveListState _networkStateFrom(LeaveListModel page) =>
      LeaveListState(items: page.items, pagination: page.pagination);

  LeaveListState _cacheState(LeaveListModel page, {required bool isOffline}) =>
      LeaveListState(
        items: page.items,
        pagination: page.pagination,
        isFromCache: true,
        isOffline: isOffline,
      );

  /// Persists [page] as this user's snapshot for the current filter.
  /// Best-effort: a cache write failure must not break the live load, and an
  /// unknown owner is skipped.
  Future<void> _save(
    LeaveListCacheStore cache,
    int? userId,
    LeaveListModel page,
  ) async {
    if (userId == null) return;
    try {
      await cache.save(userId, filter.query, page);
    } on Object {
      // Ignore — the live payload is authoritative; the cache is an optimisation.
    }
  }
}
