// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AttendanceHistoryNotifier)
final attendanceHistoryProvider = AttendanceHistoryNotifierFamily._();

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
final class AttendanceHistoryNotifierProvider
    extends
        $AsyncNotifierProvider<
          AttendanceHistoryNotifier,
          AttendanceHistoryState
        > {
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
  AttendanceHistoryNotifierProvider._({
    required AttendanceHistoryNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attendanceHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendanceHistoryNotifierHash();

  @override
  String toString() {
    return r'attendanceHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AttendanceHistoryNotifier create() => AttendanceHistoryNotifier();

  @override
  bool operator ==(Object other) {
    return other is AttendanceHistoryNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendanceHistoryNotifierHash() =>
    r'13a3a432d85f938d78c25f187b664f7ac0e2ca07';

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

final class AttendanceHistoryNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AttendanceHistoryNotifier,
          AsyncValue<AttendanceHistoryState>,
          AttendanceHistoryState,
          FutureOr<AttendanceHistoryState>,
          String
        > {
  AttendanceHistoryNotifierFamily._()
    : super(
        retry: null,
        name: r'attendanceHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  AttendanceHistoryNotifierProvider call(String month) =>
      AttendanceHistoryNotifierProvider._(argument: month, from: this);

  @override
  String toString() => r'attendanceHistoryProvider';
}

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

abstract class _$AttendanceHistoryNotifier
    extends $AsyncNotifier<AttendanceHistoryState> {
  late final _$args = ref.$arg as String;
  String get month => _$args;

  FutureOr<AttendanceHistoryState> build(String month);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
