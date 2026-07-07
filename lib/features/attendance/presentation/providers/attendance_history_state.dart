import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/attendance_models.dart';

part 'attendance_history_state.freezed.dart';

/// Accumulated attendance history for the list screen.
///
/// The initial page load is represented by the surrounding `AsyncValue`
/// (loading) on the notifier; this state carries the records fetched so far
/// plus the pagination cursor. [isLoadingMore] drives the footer spinner while
/// the next page is appended.
@freezed
abstract class AttendanceHistoryState with _$AttendanceHistoryState {
  const factory AttendanceHistoryState({
    @Default(<AttendanceModel>[]) List<AttendanceModel> items,
    PaginationModel? pagination,
    @Default(false) bool isLoadingMore,
  }) = _AttendanceHistoryState;

  const AttendanceHistoryState._();

  /// Whether another page is available to fetch.
  bool get hasMore => pagination?.hasMore ?? false;

  /// Whether there are no records at all (used for the empty state).
  bool get isEmpty => items.isEmpty;
}
