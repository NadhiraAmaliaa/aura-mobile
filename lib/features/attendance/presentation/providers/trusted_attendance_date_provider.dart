import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/device/trusted_time_providers.dart';
import '../../../../core/device/trusted_time_service.dart';
import '../attendance_day.dart';

part 'trusted_attendance_date_provider.g.dart';

/// How often a watching screen re-reads the trusted date, so a long-lived
/// session (Home stays mounted) notices a calendar-day rollover even when no
/// API response refreshes the anchor (e.g. offline across midnight).
const _recheckInterval = Duration(seconds: 30);

/// The current attendance date (`yyyy-MM-dd`) from the trusted clock, for
/// display only.
///
/// Lets the attendance sections tell a dashboard snapshot cached on an earlier
/// day apart from today's. Emits `null` while trusted time is unavailable (no
/// anchor yet, or one invalidated by a reboot); the device clock is never used
/// as a fallback. Capture does not read this provider: it takes its own trusted
/// moment at the time of capture.
///
/// Re-evaluated whenever the anchor changes and on a short interval. It only
/// reads the local trusted clock — it never fetches, caches or refreshes
/// attendance data.
@riverpod
Stream<String?> trustedAttendanceDate(Ref ref) async* {
  final service = await ref.watch(trustedTimeServiceProvider.future);
  // Disposed while the service was resolving: allocate nothing, since
  // `ref.onDispose` below would throw and leak the listener and timer.
  if (!ref.mounted) return;

  final recheck = StreamController<void>();
  void onChange() => recheck.add(null);
  service.anchorChanges.addListener(onChange);
  final timer = Timer.periodic(_recheckInterval, (_) => onChange());
  ref.onDispose(() {
    service.anchorChanges.removeListener(onChange);
    timer.cancel();
    recheck.close();
  });

  var current = await _trustedDateKey(service);
  yield current;
  await for (final _ in recheck.stream) {
    final next = await _trustedDateKey(service);
    if (next != current) {
      current = next;
      yield next;
    }
  }
}

Future<String?> _trustedDateKey(TrustedTimeService service) async {
  try {
    return attendanceDateKey(await service.now());
  } on Object {
    // No valid anchor (fresh install, post-reboot) or a clock failure: the
    // date cannot be trusted, so it is reported as unknown.
    return null;
  }
}
