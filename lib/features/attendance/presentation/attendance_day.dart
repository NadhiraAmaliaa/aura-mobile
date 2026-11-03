/// Calendar-day helpers that keep a cached dashboard snapshot from standing in
/// for another day's attendance.
///
/// The dashboard's `today.date` is the backend's `yyyy-MM-dd` attendance date,
/// and a snapshot is only authoritative for that one day. Once the trusted
/// clock has moved on (offline across midnight, or a long-lived session), its
/// check-in / check-out describe a past day, not the current one.
library;

/// The local calendar date of [moment] in the dashboard's `yyyy-MM-dd` form.
///
/// Uses the device-local date, matching the backend, which derives
/// `attendance_date` from the offset carried by `captured_at`.
String attendanceDateKey(DateTime moment) {
  final local = moment.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-'
      '${twoDigits(local.month)}-${twoDigits(local.day)}';
}

/// Whether a snapshot dated [snapshotDate] belongs to a different calendar day
/// than the trusted [currentDate].
///
/// An unknown [currentDate] (trusted time unavailable) never marks a snapshot
/// as another day: there is no trusted date to compare against, so callers
/// keep their existing behaviour. Capture never relies on this — it always has
/// its own trusted moment or is blocked.
bool isOtherAttendanceDay(String snapshotDate, String? currentDate) =>
    currentDate != null && snapshotDate != currentDate;
