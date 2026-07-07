/// Indonesian date formatting helpers for user-facing screens.
///
/// Kept dependency-free (no `intl` locale setup yet) so features stay
/// self-contained. If locale-aware formatting is adopted later, these can be
/// replaced by an `intl` wrapper without touching call sites.
const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const _weekdays = [
  'Senin', // DateTime.monday == 1
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

/// Formats an ISO `yyyy-MM-dd` string as e.g. "6 Juli 2026".
/// Returns the raw input if it cannot be parsed.
String formatIndoDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return iso;
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// Formats an ISO `yyyy-MM-dd` string as e.g. "Senin, 6 Juli 2026".
/// Returns the raw input if it cannot be parsed.
String formatIndoDateWithWeekday(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return iso;
  return '${_weekdays[date.weekday - 1]}, ${formatIndoDate(iso)}';
}
