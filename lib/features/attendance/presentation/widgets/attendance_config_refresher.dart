import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_providers.dart';
import '../providers/attendance_dashboard_notifier.dart';
import '../providers/attendance_locations_provider.dart';

/// Silently refreshes the attendance configuration — working hours (from the
/// dashboard) and the office locations / radius — while the attendance section
/// is visible, on two triggers:
///
///  * the app returns to the foreground (`resumed`), and
///  * connectivity is restored (an offline → online transition).
///
/// The refresh is deliberately *in place*: the dashboard uses
/// [AttendanceDashboardNotifier.silentRefresh] (keeps the last good snapshot,
/// swaps only on success) and the office list is re-read through
/// [attendanceLocationsProvider], whose consumers use
/// `AsyncValue.when(skipLoadingOnRefresh: true)` so the map keeps its current
/// markers instead of flashing the loader. This wrapper never touches the
/// capture / offline-queue / sync / geofence paths — it only re-reads the same
/// configuration the screens already display, so it cannot alter any attendance
/// business rule.
///
/// ## Mount it once, on the `/attendance` parent route only
///
/// The attendance routes are nested (`/attendance` → `presence` / `history`),
/// and the children are reached with `context.pushNamed`. GoRouter renders
/// nested routes as a Navigator stack, so the parent dashboard page stays
/// mounted (offstage) underneath a pushed child. Wrapping *both* the dashboard
/// and the presence screen would therefore keep two instances alive at once —
/// two lifecycle observers and two connectivity listeners — firing the refresh
/// twice on every resume / reconnect. Mounting this only on the always-present
/// parent (the dashboard) gives exactly one observer for the whole section.
///
/// The refresh still reaches the child screens because it drives the *shared*
/// [attendanceDashboardProvider] and [attendanceLocationsProvider] that the
/// presence screen also watches. On the dashboard itself the office list is not
/// watched, so invalidating it is a harmless no-op; only the presence screen
/// (which renders the map) actually re-fetches offices.
class AttendanceConfigRefresher extends ConsumerStatefulWidget {
  const AttendanceConfigRefresher({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AttendanceConfigRefresher> createState() =>
      _AttendanceConfigRefresherState();
}

class _AttendanceConfigRefresherState
    extends ConsumerState<AttendanceConfigRefresher>
    with WidgetsBindingObserver {
  /// Guards against a near-simultaneous resume + connectivity double-trigger
  /// (waking from sleep commonly fires both): a second trigger while a refresh
  /// is still in flight is coalesced into the one already running.
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refreshConfig());
  }

  /// Re-fetch the attendance configuration. Both sources are offline-resilient
  /// and keep their last value on failure, so this is safe to fire eagerly.
  Future<void> _refreshConfig() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      ref.invalidate(attendanceLocationsProvider);
      await ref.read(attendanceDashboardProvider.notifier).silentRefresh();
    } finally {
      _refreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh once on every offline → online transition. The first emission is
    // treated as the baseline (no refresh) so simply opening the screen never
    // double-fetches on top of the initial load.
    ref.listen(connectivityChangesProvider, (previous, next) {
      final current = next.asData?.value;
      if (current == null) return;
      final isOnline = hasConnectivity(current);
      final previousResults = previous?.asData?.value;
      final wasOnline = previousResults == null
          ? true
          : hasConnectivity(previousResults);
      if (isOnline && !wasOnline) unawaited(_refreshConfig());
    });

    return widget.child;
  }
}
