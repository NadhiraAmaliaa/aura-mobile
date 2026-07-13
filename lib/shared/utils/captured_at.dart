import 'package:intl/intl.dart';

/// Formats [dateTime] as an ISO-8601 string **with the device's UTC offset**,
/// e.g. `2026-07-12T14:03:07+07:00`.
///
/// This is the `captured_at` value sent to the backend. Dart's
/// [DateTime.toIso8601String] drops the offset for local times, but the backend
/// treats `captured_at` as an authoritative instant, so the offset must be
/// explicit: the server (Asia/Jakarta) parses it to the correct wall-clock even
/// if the device is in another timezone.
String formatCapturedAt(DateTime dateTime) {
  final local = dateTime.toLocal();
  final base = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(local);
  return '$base${_formatOffset(local.timeZoneOffset)}';
}

String _formatOffset(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final abs = offset.abs();
  final hours = abs.inHours.toString().padLeft(2, '0');
  final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');
  return '$sign$hours:$minutes';
}
