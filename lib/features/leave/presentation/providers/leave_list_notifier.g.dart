// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and paginates a section of the intern's leave requests.
///
/// One instance per [LeaveListFilter] (pending / history). The first page is
/// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
/// screen renders loading / error / data exhaustively. Subsequent pages are
/// appended via [loadMore], which keeps the current data visible and toggles
/// [LeaveListState.isLoadingMore].

@ProviderFor(LeaveListNotifier)
final leaveListProvider = LeaveListNotifierFamily._();

/// Loads and paginates a section of the intern's leave requests.
///
/// One instance per [LeaveListFilter] (pending / history). The first page is
/// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
/// screen renders loading / error / data exhaustively. Subsequent pages are
/// appended via [loadMore], which keeps the current data visible and toggles
/// [LeaveListState.isLoadingMore].
final class LeaveListNotifierProvider
    extends $AsyncNotifierProvider<LeaveListNotifier, LeaveListState> {
  /// Loads and paginates a section of the intern's leave requests.
  ///
  /// One instance per [LeaveListFilter] (pending / history). The first page is
  /// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
  /// screen renders loading / error / data exhaustively. Subsequent pages are
  /// appended via [loadMore], which keeps the current data visible and toggles
  /// [LeaveListState.isLoadingMore].
  LeaveListNotifierProvider._({
    required LeaveListNotifierFamily super.from,
    required LeaveListFilter super.argument,
  }) : super(
         retry: null,
         name: r'leaveListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leaveListNotifierHash();

  @override
  String toString() {
    return r'leaveListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LeaveListNotifier create() => LeaveListNotifier();

  @override
  bool operator ==(Object other) {
    return other is LeaveListNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leaveListNotifierHash() => r'e8c1d3662f11b43b32d54bb1b3c941f3eb47fced';

/// Loads and paginates a section of the intern's leave requests.
///
/// One instance per [LeaveListFilter] (pending / history). The first page is
/// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
/// screen renders loading / error / data exhaustively. Subsequent pages are
/// appended via [loadMore], which keeps the current data visible and toggles
/// [LeaveListState.isLoadingMore].

final class LeaveListNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          LeaveListNotifier,
          AsyncValue<LeaveListState>,
          LeaveListState,
          FutureOr<LeaveListState>,
          LeaveListFilter
        > {
  LeaveListNotifierFamily._()
    : super(
        retry: null,
        name: r'leaveListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads and paginates a section of the intern's leave requests.
  ///
  /// One instance per [LeaveListFilter] (pending / history). The first page is
  /// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
  /// screen renders loading / error / data exhaustively. Subsequent pages are
  /// appended via [loadMore], which keeps the current data visible and toggles
  /// [LeaveListState.isLoadingMore].

  LeaveListNotifierProvider call(LeaveListFilter filter) =>
      LeaveListNotifierProvider._(argument: filter, from: this);

  @override
  String toString() => r'leaveListProvider';
}

/// Loads and paginates a section of the intern's leave requests.
///
/// One instance per [LeaveListFilter] (pending / history). The first page is
/// fetched in `build()` and surfaced as `AsyncValue<LeaveListState>` so the
/// screen renders loading / error / data exhaustively. Subsequent pages are
/// appended via [loadMore], which keeps the current data visible and toggles
/// [LeaveListState.isLoadingMore].

abstract class _$LeaveListNotifier extends $AsyncNotifier<LeaveListState> {
  late final _$args = ref.$arg as LeaveListFilter;
  LeaveListFilter get filter => _$args;

  FutureOr<LeaveListState> build(LeaveListFilter filter);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LeaveListState>, LeaveListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LeaveListState>, LeaveListState>,
              AsyncValue<LeaveListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
