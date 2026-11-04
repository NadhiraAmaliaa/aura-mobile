import 'dart:async';
import 'dart:math' as math;

import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/domain/repositories/attendance_repository.dart';

/// A record dated [date] with deterministic times and status.
AttendanceModel historyRecord(
  String date, {
  String? checkIn = '07:52',
  String? checkOut = '17:01',
  String status = 'present',
  String statusLabel = 'Hadir',
}) => AttendanceModel(
  id: int.parse(date.replaceAll('-', '')),
  attendanceDate: date,
  checkInTime: checkIn,
  checkOutTime: checkOut,
  status: status,
  statusLabel: statusLabel,
  workMode: 'wfo',
  workModeLabel: 'WFO',
);

/// [count] records in [month] on days [count]..1, newest first.
List<AttendanceModel> monthRecords(String month, int count) => [
  for (var day = count; day >= 1; day--)
    historyRecord('$month-${day.toString().padLeft(2, '0')}'),
];

typedef HeldHistoryCall = ({
  String? month,
  int page,
  Completer<ApiResult<AttendanceHistoryModel>> completer,
});

typedef HeldDashboardCall = ({
  String? month,
  Completer<ApiResult<AttendanceDashboardModel>> completer,
});

/// In-memory attendance backend for the history screen.
///
/// Serves pages of [recordsByMonth] (already newest first) and the recap in
/// [summaryByMonth], recording every call. With [hold] set, calls stay
/// pending until released, so tests can control response order.
class FakeHistoryRepository implements AttendanceRepository {
  FakeHistoryRepository({
    Map<String, List<AttendanceModel>>? recordsByMonth,
    Map<String, MonthlySummaryModel>? summaryByMonth,
    this.perPage = 15,
  }) : recordsByMonth = recordsByMonth ?? {},
       summaryByMonth = summaryByMonth ?? {};

  final Map<String, List<AttendanceModel>> recordsByMonth;
  final Map<String, MonthlySummaryModel> summaryByMonth;
  final int perPage;

  /// Keep calls pending until [releaseHistory] / [releaseDashboard].
  bool hold = false;

  /// Failures keyed by `"<month>#<page>"` for history, `"<month>"` for the
  /// recap. Present keys fail every matching call until removed.
  final historyFailures = <String, AppException>{};
  final dashboardFailures = <String, AppException>{};

  final historyCalls = <({String? month, int page})>[];
  final dashboardCalls = <String?>[];
  final heldHistory = <HeldHistoryCall>[];
  final heldDashboard = <HeldDashboardCall>[];

  /// The scripted result for one history page, as the backend would page it.
  ApiResult<AttendanceHistoryModel> historyPage(String? month, int page) {
    final failure = historyFailures['$month#$page'];
    if (failure != null) return Failure(failure);

    final records = recordsByMonth[month] ?? const <AttendanceModel>[];
    final lastPage = math.max(1, (records.length / perPage).ceil());
    final start = math.min((page - 1) * perPage, records.length);
    final end = math.min(start + perPage, records.length);
    return Success(
      AttendanceHistoryModel(
        items: records.sublist(start, end),
        pagination: PaginationModel(
          currentPage: page,
          perPage: perPage,
          total: records.length,
          lastPage: lastPage,
          hasMore: page < lastPage,
        ),
      ),
    );
  }

  /// The scripted recap for [month], wrapped in a dashboard payload.
  ApiResult<AttendanceDashboardModel> dashboardFor(String? month) {
    final failure = dashboardFailures['$month'];
    if (failure != null) return Failure(failure);

    return Success(
      AttendanceDashboardModel(
        today: const AttendanceTodayModel(
          date: '2026-09-18',
          isWorkingDay: true,
          workHours: WorkHoursModel(start: '08:00', end: '15:00'),
        ),
        summary: summaryByMonth[month] ?? MonthlySummaryModel(month: month!),
      ),
    );
  }

  @override
  Future<ApiResult<AttendanceHistoryModel>> history({
    int? page,
    int? perPage,
    String? month,
  }) {
    final resolvedPage = page ?? 1;
    historyCalls.add((month: month, page: resolvedPage));
    if (!hold) return Future.value(historyPage(month, resolvedPage));

    final completer = Completer<ApiResult<AttendanceHistoryModel>>();
    heldHistory.add((month: month, page: resolvedPage, completer: completer));
    return completer.future;
  }

  @override
  Future<ApiResult<AttendanceDashboardModel>> dashboard({String? month}) {
    dashboardCalls.add(month);
    if (!hold) return Future.value(dashboardFor(month));

    final completer = Completer<ApiResult<AttendanceDashboardModel>>();
    heldDashboard.add((month: month, completer: completer));
    return completer.future;
  }

  /// Completes the oldest held history call for [month] / [page], with
  /// [result] or the scripted page.
  void releaseHistory(
    String month,
    int page, [
    ApiResult<AttendanceHistoryModel>? result,
  ]) {
    final call = heldHistory.firstWhere(
      (call) => call.month == month && call.page == page,
    );
    heldHistory.remove(call);
    call.completer.complete(result ?? historyPage(month, page));
  }

  /// Completes the oldest held recap call for [month].
  void releaseDashboard(String month) {
    final call = heldDashboard.firstWhere((call) => call.month == month);
    heldDashboard.remove(call);
    call.completer.complete(dashboardFor(month));
  }

  @override
  Future<ApiResult<AttendanceModel>> syncEvent(AttendanceQueueEntry entry) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<AttendanceLocationModel>>> locations() =>
      throw UnimplementedError();
}
