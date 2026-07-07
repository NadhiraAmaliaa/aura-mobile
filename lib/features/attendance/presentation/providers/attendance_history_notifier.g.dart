// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and paginates the intern's attendance history.
///
/// The first page is fetched in `build()` and surfaced as
/// `AsyncValue<AttendanceHistoryState>` so the screen renders loading / error /
/// data exhaustively. Subsequent pages are appended via [loadMore], which keeps
/// the current data visible and toggles [AttendanceHistoryState.isLoadingMore].

@ProviderFor(AttendanceHistoryNotifier)
final attendanceHistoryProvider = AttendanceHistoryNotifierProvider._();

/// Loads and paginates the intern's attendance history.
///
/// The first page is fetched in `build()` and surfaced as
/// `AsyncValue<AttendanceHistoryState>` so the screen renders loading / error /
/// data exhaustively. Subsequent pages are appended via [loadMore], which keeps
/// the current data visible and toggles [AttendanceHistoryState.isLoadingMore].
final class AttendanceHistoryNotifierProvider
    extends
        $AsyncNotifierProvider<
          AttendanceHistoryNotifier,
          AttendanceHistoryState
        > {
  /// Loads and paginates the intern's attendance history.
  ///
  /// The first page is fetched in `build()` and surfaced as
  /// `AsyncValue<AttendanceHistoryState>` so the screen renders loading / error /
  /// data exhaustively. Subsequent pages are appended via [loadMore], which keeps
  /// the current data visible and toggles [AttendanceHistoryState.isLoadingMore].
  AttendanceHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceHistoryNotifierHash();

  @$internal
  @override
  AttendanceHistoryNotifier create() => AttendanceHistoryNotifier();
}

String _$attendanceHistoryNotifierHash() =>
    r'fb3e54a849ba989d6034add6600b8b7854f46c4f';

/// Loads and paginates the intern's attendance history.
///
/// The first page is fetched in `build()` and surfaced as
/// `AsyncValue<AttendanceHistoryState>` so the screen renders loading / error /
/// data exhaustively. Subsequent pages are appended via [loadMore], which keeps
/// the current data visible and toggles [AttendanceHistoryState.isLoadingMore].

abstract class _$AttendanceHistoryNotifier
    extends $AsyncNotifier<AttendanceHistoryState> {
  FutureOr<AttendanceHistoryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AttendanceHistoryState>, AttendanceHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AttendanceHistoryState>,
                AttendanceHistoryState
              >,
              AsyncValue<AttendanceHistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
