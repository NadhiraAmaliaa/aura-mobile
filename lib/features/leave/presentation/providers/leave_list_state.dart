import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/leave_models.dart';

part 'leave_list_state.freezed.dart';

/// Which section of the intern's leave requests a list is showing.
///
/// Maps directly to the backend `filter` query parameter on
/// `GET /leave-requests`.
enum LeaveListFilter {
  /// Requests still awaiting a decision ("Menunggu Persetujuan").
  pending,

  /// Processed requests — approved or rejected ("Riwayat Pengajuan").
  history;

  /// The backend query value for this filter.
  String get query => switch (this) {
    LeaveListFilter.pending => 'pending',
    LeaveListFilter.history => 'history',
  };
}

/// Accumulated leave requests for a list screen.
///
/// The initial page load is represented by the surrounding `AsyncValue`
/// (loading) on the notifier; this state carries the records fetched so far
/// plus the pagination cursor. [isLoadingMore] drives the footer spinner while
/// the next page is appended.
@freezed
abstract class LeaveListState with _$LeaveListState {
  const factory LeaveListState({
    @Default(<LeaveRequestModel>[]) List<LeaveRequestModel> items,
    LeavePaginationModel? pagination,
    @Default(false) bool isLoadingMore,
  }) = _LeaveListState;

  const LeaveListState._();

  /// Whether another page is available to fetch.
  bool get hasMore => pagination?.hasMore ?? false;

  /// Whether there are no records at all (used for the empty state).
  bool get isEmpty => items.isEmpty;
}
