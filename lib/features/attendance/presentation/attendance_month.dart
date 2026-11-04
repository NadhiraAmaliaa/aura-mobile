/// Calendar-month helpers for the attendance history filter.
///
/// A month travels as the backend's `yyyy-MM` key: the `month` query parameter
/// of both `/attendance/history` and `/attendance/dashboard`, and the
/// `summary.month` the dashboard echoes back.
library;

import '../../../core/error/app_exception.dart';
import '../../../shared/utils/indo_date.dart';
import '../data/models/attendance_models.dart';
import 'attendance_day.dart';

/// Raised when a response does not belong to the requested month (e.g. a
/// backend that ignores the `month` filter). Its data is never shown, so
/// months can't silently mix.
const attendanceMonthMismatch = UnknownException(
  message: 'Data tidak sesuai dengan bulan yang dipilih. Silakan coba lagi.',
);

/// The `yyyy-MM` key for [year] and 1-based [month].
String attendanceMonthKeyOf(int year, int month) =>
    '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

/// The `yyyy-MM` key of [moment]'s local calendar month.
String attendanceMonthKey(DateTime moment) =>
    attendanceDateKey(moment).substring(0, 7);

/// Parses a `yyyy-MM` key, or the month of a `yyyy-MM-dd` date. Returns null
/// when the value is missing or malformed.
({int year, int month})? parseAttendanceMonth(String? value) {
  if (value == null) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})(?:$|-)').firstMatch(value);
  if (match == null) return null;
  final month = int.parse(match[2]!);
  if (month < 1 || month > 12) return null;
  return (year: int.parse(match[1]!), month: month);
}

/// [key] moved by [months] calendar months (negative moves back).
String shiftAttendanceMonth(String key, int months) {
  final parsed = parseAttendanceMonth(key)!;
  final index = parsed.year * 12 + parsed.month - 1 + months;
  return attendanceMonthKeyOf(index ~/ 12, index % 12 + 1);
}

/// A `yyyy-MM` key as e.g. "Juli 2026". Returns the raw key if malformed.
String formatAttendanceMonth(String key) {
  final parsed = parseAttendanceMonth(key);
  if (parsed == null) return key;
  return '${indoMonthName(parsed.month)} ${parsed.year}';
}

/// The month the history opens on.
///
/// Prefers the trusted current date, then the server month of the dashboard
/// snapshot the user came from. The device clock is only a last resort: the
/// month is a view filter, so a wrong default is harmless and the server
/// stays authoritative for every value shown.
String initialHistoryMonth({
  String? trustedDate,
  String? dashboardMonth,
  required DateTime now,
}) {
  for (final candidate in [trustedDate, dashboardMonth]) {
    final parsed = parseAttendanceMonth(candidate);
    if (parsed != null) return attendanceMonthKeyOf(parsed.year, parsed.month);
  }
  return attendanceMonthKey(now);
}

/// The selectable months, inclusive: from the internship start month up to
/// [latest]. A start after [latest] (an internship that has not begun) offers
/// [latest] only; without a usable start date the twelve months ending at
/// [latest] are offered.
({String first, String last}) historyMonthRange({
  required String latest,
  String? internStartDate,
}) {
  final start = parseAttendanceMonth(internStartDate);
  if (start == null) {
    return (first: shiftAttendanceMonth(latest, -11), last: latest);
  }
  final startKey = attendanceMonthKeyOf(start.year, start.month);
  // `yyyy-MM` keys order chronologically as plain strings.
  return (
    first: startKey.compareTo(latest) <= 0 ? startKey : latest,
    last: latest,
  );
}

/// Whether every record is dated inside the `yyyy-MM` [month].
bool attendanceItemsInMonth(List<AttendanceModel> items, String month) =>
    items.every((item) => item.attendanceDate?.startsWith('$month-') ?? false);
