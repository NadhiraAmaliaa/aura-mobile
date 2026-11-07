import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/device/device_time_providers.dart';
import '../../../../core/device/device_time_settings.dart';
import '../../../../core/device/trusted_time_service.dart';
import '../../../../core/location/location_result.dart';
import '../../data/local/attendance_queue_entry.dart';
import '../../data/models/attendance_models.dart';
import '../attendance_day.dart';
import '../geofence_evaluation.dart';
import '../providers/attendance_dashboard_notifier.dart';
import '../providers/attendance_locations_provider.dart';
import '../providers/attendance_queue_controller.dart';
import '../providers/automatic_time_notifier.dart';
import '../providers/current_location_notifier.dart';
import '../providers/current_location_state.dart';
import '../providers/trusted_attendance_date_provider.dart';
import '../providers/trusted_time_status_notifier.dart';
import '../widgets/attendance_map.dart';

/// Work mode that requires on-site (office radius) validation.
const _workModeWfo = 'wfo';

/// The attendance action currently in progress (acquiring a fix / submitting).
enum _PendingAction { checkIn, checkOut }

/// Selectable attendance types shown in the "JENIS ABSENSI" sheet.
const _attendanceTypes = <({String value, String label, String hint})>[
  (value: _workModeWfo, label: 'WFO', hint: 'Bekerja dari kantor'),
  (value: 'wfh', label: 'WFH', hint: 'Bekerja dari rumah'),
  (value: 'dinas', label: 'Dinas', hint: 'Dinas luar / tugas lapangan'),
];

// Presensi palette. Heading, page background, divider and shadow are the AURA
// tokens used on Home, Dashboard and History; the date card, actions, badge
// and table colours come from the approved Presensi reference design. Kept
// local until a shared AURA palette exists. There is deliberately no Theme
// override: the map overlays read the app theme and must render as before.
const _heading = Color(0xFF123F69);
const _navy = Color(0xFF0B2559);
const _bodyMuted = Color(0xFF58636A);
const _divider = Color(0xFFE6ECF1);
const _surfaceShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);
const _pageGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFE5EFFB), Color(0xFFF5F8F8)],
  stops: [0, 0.7],
);
const _dateCardBackground = Color(0xFFD9EEE3);
const _dateIconBackground = Color(0xFFF1F8F0);
const _dateIconGreen = Color(0xFF5ABF5F);
const _checkInColor = Color(0xFFF9A431);
const _checkOutColor = Color(0xFFE84A4D);

/// Disabled actions blend their fill this far toward [_disabledBlend]: muted
/// and desaturated, yet deep enough for the white label and spinner.
const _disabledBlend = Color(0xFF7D8794);
const _disabledBlendAmount = 0.45;
const _sectionBadge = Color(0xFF6AB3E9);
const _tableHeader = Color(0xFF194875);
const _checkInStatusBackground = Color(0xFFDDEEDC);
const _checkInStatusText = Color(0xFF1E6B3F);
const _checkOutStatusBackground = Color(0xFFCEE4FC);

/// Dedicated attendance (presensi) page reached from the summary page's
/// "Presensi Magang" button.
///
/// Hosts the live map, the current date/time, today's attendance history and
/// the Check In / Check Out actions. The device location is refreshed on open
/// so any attendance action starts from a fresh fix. All submission flows
/// through the existing check-in / check-out controllers — this screen is a
/// UI/navigation shell only and does not change any business rules.
class AttendancePresenceScreen extends ConsumerStatefulWidget {
  const AttendancePresenceScreen({super.key});

  @override
  ConsumerState<AttendancePresenceScreen> createState() =>
      _AttendancePresenceScreenState();
}

class _AttendancePresenceScreenState
    extends ConsumerState<AttendancePresenceScreen>
    with WidgetsBindingObserver {
  static const double _mapSectionHeight = 260;

  /// Which action is currently acquiring a fresh fix / submitting, so the
  /// pressed button shows progress and both buttons stay disabled meanwhile.
  _PendingAction? _pendingAction;

  /// Guards [_promptAutoTimeBlocked] so the hard-block dialog is shown one at a
  /// time — first detection, resume re-check and capture attempts never stack.
  bool _autoTimeDialogOpen = false;

  /// Guards [_promptMockLocationBlocked] so the dialog is shown one at a time.
  bool _mockLocationDialogOpen = false;

  /// Guards [_promptTrustedTimeBlocked] so the dialog is shown one at a time.
  bool _trustedTimeDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh the current location every time the page opens, before any
    // attendance action, so submissions use a fresh fix. Also drain any events
    // left pending from a previous session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(currentLocationProvider.notifier).fetch();
      ref.read(attendanceQueueControllerProvider.notifier).flush();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app returns to the foreground (e.g. after the user enabled GPS
    // from the settings screen, or handled the system dialog), automatically
    // re-attempt a fresh fix so attendance state continues without a manual
    // retry. Only re-fetch when we don't already have a usable fix so a normal
    // resume never re-prompts once location is on.
    if (state != AppLifecycleState.resumed) return;
    final locationState = ref.read(currentLocationProvider);
    if (locationState is LocationError || locationState is LocationIdle) {
      ref.read(currentLocationProvider.notifier).fetch();
    }
    // Re-check the device automatic-clock setting so the block clears itself
    // once the user enables it from the Date & Time settings screen.
    ref.read(automaticTimeStatusProvider.notifier).refresh();
    // Re-check trusted time: reconnecting refreshes the anchor via the HTTP
    // interceptor, so the block clears itself once the device is back online.
    ref.read(trustedTimeStatusProvider.notifier).refresh();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Surfaces a blocking business-rule failure (duplicate check-in, check-out
  /// before check-in, geofence / mock-location rejection, automatic-clock
  /// block) as a modal dialog the user must acknowledge. Success, queued-offline
  /// and sync progress stay as lightweight snackbars.
  Future<void> _showAlert(
    String message, {
    String title = 'Tidak dapat melakukan absensi',
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _onCheckInPressed() async {
    final type = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AttendanceTypeSheet(),
    );
    if (type == null || !mounted) return;

    setState(() => _pendingAction = _PendingAction.checkIn);
    try {
      // Always submit against a fresh fix rather than the one captured on open.
      final position = await ref
          .read(currentLocationProvider.notifier)
          .acquireFresh();
      if (!mounted) return;

      // Reject spoofed/mocked GPS for every work mode before submitting.
      if (!_ensureLocationTrusted()) return;

      // WFO must be inside an office radius; WFH skips validation; Dinas defers
      // to the server's business rules. For WFO we also freeze the matched
      // office as the geofence snapshot sent to the backend.
      AttendanceLocationModel? office;
      if (type == _workModeWfo) {
        office = await _resolveOfficeForWfo(position);
        if (office == null) return;
      }

      final entry = await ref
          .read(attendanceQueueControllerProvider.notifier)
          .capture(
            type: AttendanceEventType.checkIn,
            workMode: type,
            latitude: position?.latitude,
            longitude: position?.longitude,
            office: office,
            today: _todaySnapshot(),
          );
      if (!mounted) return;
      _showCaptureOutcome(entry, syncedMessage: 'Check In berhasil.');
    } on AutomaticTimeDisabledException {
      if (!mounted) return;
      _handleAutomaticTimeBlocked();
    } on TrustedTimeUnavailableException {
      if (!mounted) return;
      _handleTrustedTimeBlocked();
    } on AttendanceRuleException catch (error) {
      // A deterministic business rule (duplicate, past cutoff, outside radius)
      // blocked the capture before it was queued: show it as the block dialog.
      if (!mounted) return;
      _showAlert(error.message);
    } catch (error) {
      // Never let a capture fail silently: any other error (fresh-fix failure,
      // office lookup / cache read, queue write, unexpected server response)
      // must still reach the user as a dialog instead of just resetting the
      // button with no feedback.
      if (!mounted) return;
      _showAlert('Absensi gagal diproses. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _pendingAction = null);
    }
  }

  /// Surfaces the automatic-clock hard block from a capture attempt: refreshes
  /// the status notifier (disables the buttons) then shows the block dialog.
  void _handleAutomaticTimeBlocked() {
    ref.read(automaticTimeStatusProvider.notifier).refresh();
    unawaited(_promptAutoTimeBlocked());
  }

  /// Surfaces the trusted-time block from a capture attempt: refreshes the
  /// status notifier (disables the buttons) then shows the block dialog.
  void _handleTrustedTimeBlocked() {
    ref.read(trustedTimeStatusProvider.notifier).refresh();
    unawaited(_promptTrustedTimeBlocked());
  }

  /// Shows the trusted-time hard block while no valid time anchor exists (fresh
  /// install, or the anchor was invalidated by a device reboot). Reuses the
  /// AGHRIS-style non-dismissible dialog: the user must acknowledge, after which
  /// they are sent back to the attendance dashboard. Reconnecting re-establishes
  /// the anchor via the HTTP interceptor and clears the block. Only one dialog
  /// is ever shown at a time so repeated detections never stack.
  Future<void> _promptTrustedTimeBlocked() async {
    if (_trustedTimeDialogOpen || !mounted) return;
    _trustedTimeDialogOpen = true;
    await showTrustedTimeBlockedDialog(context);
    _trustedTimeDialogOpen = false;
    if (!mounted) return;
    // Never let the user linger on the capture page without verified time.
    if (context.canPop()) context.pop();
  }

  /// Shows the AGHRIS-style hard block while the device clock is manual. The
  /// dialog cannot be dismissed by tapping outside or the system back button,
  /// so the user must choose: open the system Date & Time settings, or leave
  /// the attendance page (OK). Only one dialog is ever shown at a time, so
  /// repeated detections (first open, resume re-check, capture attempt) never
  /// stack or loop.
  Future<void> _promptAutoTimeBlocked() async {
    if (_autoTimeDialogOpen || !mounted) return;
    _autoTimeDialogOpen = true;
    final choice = await showAutoTimeBlockedDialog(context);
    _autoTimeDialogOpen = false;
    if (!mounted) return;
    switch (choice) {
      case AutoTimeBlockedChoice.openSettings:
        // Reuse the existing shortcut; the resume re-check clears the block or
        // re-prompts if the user comes back with it still disabled.
        await ref.read(deviceTimeSettingsProvider).openDateTimeSettings();
      case AutoTimeBlockedChoice.dismissed:
        // Never let the user linger on the capture page while the clock is
        // still manual — send them back to the attendance dashboard.
        if (context.canPop()) context.pop();
    }
  }

  /// Shows a blocking dialog when a mock/fake/simulated location is detected.
  ///
  /// Unlike the auto-time dialog, the user stays on the page after dismissal
  /// because they may need to disable a fake GPS app and retry via the inline
  /// error notice. The buttons remain disabled until a non-mocked fix succeeds.
  Future<void> _promptMockLocationBlocked() async {
    if (_mockLocationDialogOpen || !mounted) return;
    _mockLocationDialogOpen = true;
    await showMockLocationBlockedDialog(context);
    _mockLocationDialogOpen = false;
  }

  /// Guards every work mode against a spoofed/mocked GPS fix. The location
  /// service rejects a mocked fix as a [LocationFailureKind.mocked] failure;
  /// this surfaces that reason and blocks submission. Returns `true` when the
  /// fix is trusted (or the failure was unrelated to mocking).
  bool _ensureLocationTrusted() {
    final state = ref.read(currentLocationProvider);
    if (state is LocationError && state.kind == LocationFailureKind.mocked) {
      _showAlert(state.message);
      return false;
    }
    return true;
  }

  /// Today's server-backed snapshot (attendance, work hours, working-day flag),
  /// passed to [AttendanceQueueController.capture] so it can locally enforce the
  /// duplicate / cutoff / ordering rules against the same data the backend uses.
  /// `null` when the dashboard has not resolved (offline with no cache).
  AttendanceTodayModel? _todaySnapshot() {
    return switch (ref.read(attendanceDashboardProvider)) {
      AsyncData(:final value) => value.today,
      _ => null,
    };
  }

  /// Whether today's check-in has been recorded — from the server-backed
  /// dashboard or a still-pending offline capture. Gates a check-out so it is
  /// never captured out of order (mirrors the backend ordering rule, but also
  /// holds offline where the server can't reject it).
  bool _hasCheckedInToday() {
    final today = switch (ref.read(attendanceDashboardProvider)) {
      AsyncData(:final value) => value.today,
      _ => null,
    };
    final attendance = _currentDayAttendance(
      today,
      ref.read(trustedAttendanceDateProvider).value,
    );
    final serverCheckedIn = attendance?.checkInTime != null;
    return serverCheckedIn ||
        ref.read(pendingAttendanceActionsProvider).hasCheckIn;
  }

  /// Resolves the office a WFO action is standing in, mirroring the check-in
  /// policy. Uses the live office list when available, otherwise the on-device
  /// cache (so it still works offline). Returns the matched office, or `null`
  /// after showing a snackbar when the action may not proceed.
  Future<AttendanceLocationModel?> _resolveOfficeForWfo(
    GeoPosition? position,
  ) async {
    if (position == null) {
      _showSnack('Ambil lokasi Anda terlebih dahulu.');
      return null;
    }
    final offices = await ref.read(geofenceOfficesProvider.future);
    if (!mounted) return null;

    final verdict = evaluateGeofence(
      offices,
      position.latitude,
      position.longitude,
    );
    if (verdict is GeofenceInside) return verdict.location;

    _showAlert(switch (verdict) {
      GeofenceOutside(:final location, :final distanceMeters) =>
        'Anda di luar radius kantor ${location.name} '
            '(${distanceMeters.round()} m).',
      GeofenceNoLocations() =>
        'Lokasi presensi belum tersedia\n'
            'Silakan hubungi administrator untuk mengonfigurasi lokasi presensi',
      _ => 'Lokasi tidak valid untuk WFO.',
    });
    return null;
  }

  /// Turns a captured queue entry into user feedback: a blocking dialog for a
  /// server rejection (a business-rule failure), otherwise a lightweight
  /// snackbar for success or an offline-queued capture.
  void _showCaptureOutcome(
    AttendanceQueueEntry entry, {
    required String syncedMessage,
  }) {
    switch (entry.status) {
      case QueuedEventStatus.synced:
        _showSnack(syncedMessage);
      case QueuedEventStatus.pending:
        _showSnack('Absensi tersimpan. Akan dikirim otomatis saat online.');
      case QueuedEventStatus.rejected:
        _showAlert(entry.lastError ?? 'Absensi ditolak oleh server.');
    }
  }

  Future<void> _onCheckOutPressed(String? workMode) async {
    // A check-out is only valid after today's check-in. The backend enforces
    // this too, but offline there is no server to reject it — without this
    // guard an out-of-order check-out would be silently queued and only fail
    // later at sync. Blocks the capture entirely, online or offline.
    if (!_hasCheckedInToday()) {
      _showAlert('Anda harus Check In terlebih dahulu sebelum Check Out.');
      return;
    }
    setState(() => _pendingAction = _PendingAction.checkOut);
    try {
      // Always submit against a fresh fix rather than the one captured on open.
      final position = await ref
          .read(currentLocationProvider.notifier)
          .acquireFresh();
      if (!mounted) return;

      // Reject spoofed/mocked GPS for every work mode before submitting.
      if (!_ensureLocationTrusted()) return;

      // The work mode was fixed at check-in; only WFO is validated on-site.
      AttendanceLocationModel? office;
      if (workMode == _workModeWfo) {
        office = await _resolveOfficeForWfo(position);
        if (office == null) return;
      }

      final entry = await ref
          .read(attendanceQueueControllerProvider.notifier)
          .capture(
            type: AttendanceEventType.checkOut,
            latitude: position?.latitude,
            longitude: position?.longitude,
            office: office,
            today: _todaySnapshot(),
          );
      if (!mounted) return;
      _showCaptureOutcome(entry, syncedMessage: 'Check Out berhasil.');
    } on AutomaticTimeDisabledException {
      if (!mounted) return;
      _handleAutomaticTimeBlocked();
    } on TrustedTimeUnavailableException {
      if (!mounted) return;
      _handleTrustedTimeBlocked();
    } on AttendanceRuleException catch (error) {
      // A deterministic business rule (missing check-in, out-of-order,
      // outside radius) blocked the capture before it was queued.
      if (!mounted) return;
      _showAlert(error.message);
    } catch (error) {
      // Never let a capture fail silently: surface any other error as a dialog
      // instead of just resetting the button with no feedback.
      if (!mounted) return;
      _showAlert('Absensi gagal diproses. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _pendingAction = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(currentLocationProvider);
    final dashboard = ref.watch(attendanceDashboardProvider);
    // `false` = device clock is manual; block attendance. `null`/`true` allow.
    final autoTimeBlocked =
        ref.watch(automaticTimeStatusProvider).value == false;
    // Trusted-time gate. `true` = a valid anchor exists for this boot session;
    // `null` (loading) = a verification attempt is still in flight — disable the
    // buttons without a dialog; `false` = verified unavailable — block + dialog.
    final trustedTimeStatus = ref.watch(trustedTimeStatusProvider);
    final trustedTimeReady = trustedTimeStatus.value == true;

    // Hard block: whenever the clock resolves to manual (first load or a resume
    // re-check), surface the AGHRIS-style block dialog. The prompt is guarded
    // so it never stacks or loops.
    ref.listen<AsyncValue<bool?>>(automaticTimeStatusProvider, (_, next) {
      if (next.value == false) unawaited(_promptAutoTimeBlocked());
    });

    // Trusted-time block: whenever no valid anchor exists (first load or a
    // resume re-check), surface the block dialog. The prompt is guarded so it
    // never stacks or loops.
    ref.listen<AsyncValue<bool>>(trustedTimeStatusProvider, (_, next) {
      if (next.value == false) unawaited(_promptTrustedTimeBlocked());
    });

    // Mock-location hard block: whenever a location fetch returns a mocked fix,
    // surface the blocking dialog and disable the attendance buttons — mirrors
    // the automatic-time pattern.
    final mockLocationBlocked = switch (locationState) {
      LocationError(:final kind) => kind == LocationFailureKind.mocked,
      _ => false,
    };

    ref.listen<CurrentLocationState>(currentLocationProvider, (_, next) {
      if (next is LocationError && next.kind == LocationFailureKind.mocked) {
        unawaited(_promptMockLocationBlocked());
      }
    });

    final position = switch (locationState) {
      LocationReady(:final position) => position,
      _ => null,
    };

    final today = switch (dashboard) {
      AsyncData(:final value) => value.today,
      _ => null,
    };
    // A snapshot cached on an earlier day is not today's record: it neither
    // fills today's history nor fixes the check-out work mode.
    final attendance = _currentDayAttendance(
      today,
      ref.watch(trustedAttendanceDateProvider).value,
    );

    // Fold in today's queued (offline) actions so the screen reflects a capture
    // immediately — before it has synced to the server-backed dashboard.
    final pendingActions = ref.watch(pendingAttendanceActionsProvider);
    // Work mode to gate an offline WFO check-out: the server record if present,
    // otherwise the queued check-in's mode.
    final checkOutWorkMode =
        attendance?.workMode ?? pendingActions.checkInWorkMode;

    final isCheckingIn = _pendingAction == _PendingAction.checkIn;
    final isCheckingOut = _pendingAction == _PendingAction.checkOut;
    final isBusy = isCheckingIn || isCheckingOut;

    // Buttons are gated by technical constraints — an in-flight capture, the
    // automatic-clock hard block, and mock-location detection. Business rules
    // (already checked in, leave, check-out ordering) are decided by the
    // backend, which returns a friendly message shown as a dialog.
    final canCheckIn =
        !isBusy && !autoTimeBlocked && trustedTimeReady && !mockLocationBlocked;
    final canCheckOut =
        !isBusy && !autoTimeBlocked && trustedTimeReady && !mockLocationBlocked;

    // Same page background and transparent AppBar as Home, Dashboard and
    // History. Only the page is painted — no Theme override — so the map and
    // the coordinates card render exactly as before.
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: _pageGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Presensi'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: _heading,
          titleTextStyle: const TextStyle(
            color: _heading,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: _mapSectionHeight,
              width: double.infinity,
              child: CheckInMap(userPosition: position),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const _LiveDateTimeCard(),
                  const _PendingSyncNotice(),
                  if (locationState is LocationError) ...[
                    const SizedBox(height: 12),
                    _LocationErrorNotice(
                      error: locationState,
                      onRetry: () =>
                          ref.read(currentLocationProvider.notifier).fetch(),
                      onOpenLocationSettings: () => ref
                          .read(currentLocationProvider.notifier)
                          .openLocationSettings(),
                      onOpenAppSettings: () => ref
                          .read(currentLocationProvider.notifier)
                          .openAppSettings(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _CoordinatesCard(
                    position: position,
                    loading: locationState is LocationLoading,
                    onRefresh: () =>
                        ref.read(currentLocationProvider.notifier).fetch(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CheckInButton(
                          busy: isCheckingIn,
                          onPressed: canCheckIn ? _onCheckInPressed : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CheckOutButton(
                          busy: isCheckingOut,
                          onPressed: canCheckOut
                              ? () => _onCheckOutPressed(checkOutWorkMode)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _HistorySectionTitle(),
                  const SizedBox(height: 12),
                  _TodayHistoryTable(
                    attendance: attendance,
                    loading: dashboard is AsyncLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that asks the user which type of attendance to record.
class _AttendanceTypeSheet extends StatefulWidget {
  const _AttendanceTypeSheet();

  @override
  State<_AttendanceTypeSheet> createState() => _AttendanceTypeSheetState();
}

class _AttendanceTypeSheetState extends State<_AttendanceTypeSheet> {
  String _selected = _attendanceTypes.first.value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'JENIS ABSENSI',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selected,
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
              child: Column(
                children: [
                  for (final type in _attendanceTypes)
                    RadioListTile<String>(
                      value: type.value,
                      title: Text(type.label),
                      subtitle: Text(type.hint),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_selected),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Absen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows an inline notice when attendance events are queued but not yet synced,
/// with a manual retry. Renders nothing when the queue is drained.
class _PendingSyncNotice extends ConsumerStatefulWidget {
  const _PendingSyncNotice();

  @override
  ConsumerState<_PendingSyncNotice> createState() => _PendingSyncNoticeState();
}

class _PendingSyncNoticeState extends ConsumerState<_PendingSyncNotice> {
  bool _flushing = false;

  Future<void> _flush() async {
    if (_flushing) return;
    setState(() => _flushing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final summary = await ref
          .read(attendanceQueueControllerProvider.notifier)
          .flush();
      if (!mounted) return;

      final String message;
      if (summary.synced > 0 && summary.stillPending == 0) {
        message = '${summary.synced} absensi berhasil dikirim.';
      } else if (summary.rejected > 0 && summary.stillPending == 0) {
        message = 'Absensi ditolak server. Periksa detailnya.';
      } else if (summary.stillPending > 0) {
        message = 'Gagal mengirim: ${_pendingReason()}';
      } else {
        message = 'Tidak ada absensi untuk dikirim.';
      }
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Gagal mengirim: $error')));
    } finally {
      if (mounted) setState(() => _flushing = false);
    }
  }

  /// The error recorded on the oldest entry still awaiting sync, so the user
  /// sees the concrete reason (timeout, connection refused, server error, …)
  /// instead of a silent no-op.
  String _pendingReason() {
    final entries =
        ref.read(attendanceQueueControllerProvider).asData?.value ??
        const <AttendanceQueueEntry>[];
    final pending = entries
        .where((entry) => entry.status == QueuedEventStatus.pending)
        .toList();
    final reason = pending.isNotEmpty ? pending.last.lastError : null;
    return (reason == null || reason.isEmpty)
        ? 'menunggu koneksi. Coba lagi.'
        : reason;
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingAttendanceCountProvider);
    if (pending == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 20,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$pending absensi menunggu dikirim.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: _flushing ? null : _flush,
              child: _flushing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft mint card (from the Presensi reference) that shows the current date
/// and time, ticking every second.
class _LiveDateTimeCard extends StatefulWidget {
  const _LiveDateTimeCard();

  @override
  State<_LiveDateTimeCard> createState() => _LiveDateTimeCardState();
}

class _LiveDateTimeCardState extends State<_LiveDateTimeCard> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _dateCardBackground,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Padding(
        // 7 + 40dp circle + 7 = 54dp at normal text size (was 68dp).
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: _dateIconBackground,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: _dateIconGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatIndoDateTime(_now),
                style: const TextStyle(
                  color: _heading,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  // Fixed-width digits so the ticking seconds don't jitter.
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats [dt] as e.g. "Rabu 8 Juli 2026, 15:43:01" (Indonesian).
String _formatIndoDateTime(DateTime dt) {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = [
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
  final day = days[dt.weekday - 1];
  final month = months[dt.month - 1];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  final ss = dt.second.toString().padLeft(2, '0');
  return '$day ${dt.day} $month ${dt.year}, $hh:$mm:$ss';
}

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _AttendanceActionButton(
      label: 'Check In',
      icon: Icons.login_rounded,
      color: _checkInColor,
      busy: busy,
      onPressed: onPressed,
    );
  }
}

class _CheckOutButton extends StatelessWidget {
  const _CheckOutButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _AttendanceActionButton(
      label: 'Check Out',
      icon: Icons.logout_rounded,
      color: _checkOutColor,
      busy: busy,
      onPressed: onPressed,
    );
  }
}

/// Flat, pill-shaped attendance action in its reference colour, without any
/// shadow.
///
/// A `null` [onPressed] disables it and swaps in a muted fill; [busy] replaces
/// the label with a white spinner.
class _AttendanceActionButton extends StatelessWidget {
  const _AttendanceActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Color.lerp(
          color,
          _disabledBlend,
          _disabledBlendAmount,
        ),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
        // Flat in every state: no hover/press elevation.
        elevation: 0,
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                // Shrinks rather than wraps under large text, so the two
                // pills keep one height side by side.
                Flexible(
                  child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
                ),
              ],
            ),
    );
  }
}

/// Verification read-out of the current GPS coordinates and accuracy.
///
/// Surfaces the raw latitude/longitude (and the reported horizontal accuracy)
/// so the fix can be eyeballed against the office location before checking in.
class _CoordinatesCard extends StatelessWidget {
  const _CoordinatesCard({
    required this.position,
    required this.loading,
    required this.onRefresh,
  });

  final GeoPosition? position;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = position;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Koordinat Anda',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                if (loading && pos == null)
                  Text('Mengambil lokasi…', style: theme.textTheme.bodySmall)
                else if (pos == null)
                  Text(
                    'Lokasi belum tersedia',
                    style: theme.textTheme.bodySmall,
                  )
                else ...[
                  Text(
                    '${pos.latitude.toStringAsFixed(7)}, '
                    '${pos.longitude.toStringAsFixed(7)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (pos.accuracy != null)
                    Text(
                      'Akurasi ±${pos.accuracy!.toStringAsFixed(0)} m',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: loading ? null : onRefresh,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Perbarui lokasi',
          ),
        ],
      ),
    );
  }
}

class _LocationErrorNotice extends StatelessWidget {
  const _LocationErrorNotice({
    required this.error,
    required this.onRetry,
    required this.onOpenLocationSettings,
    required this.onOpenAppSettings,
  });
  final LocationError error;

  /// Re-run the location flow. For a disabled service this re-triggers the
  /// in-app system dialog (the primary path); for a transient error it simply
  /// retries the fix.
  final VoidCallback onRetry;

  /// Open the OS location-services screen — the fallback when the in-app
  /// resolution dialog is unavailable on the device.
  final VoidCallback onOpenLocationSettings;

  /// Open the app's settings page (for a permanently denied permission).
  final VoidCallback onOpenAppSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serviceDisabled = error.kind == LocationFailureKind.serviceDisabled;
    final deniedForever =
        error.kind == LocationFailureKind.permissionDeniedForever;
    final mocked = error.kind == LocationFailureKind.mocked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                mocked ? Icons.gps_off : Icons.location_off,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          if (mocked)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 34),
              child: Text(
                'Check In dan Check Out dinonaktifkan selama lokasi '
                'tidak dapat diverifikasi.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (serviceDisabled) ...[
                TextButton(
                  onPressed: onOpenLocationSettings,
                  child: const Text('Buka Pengaturan'),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Aktifkan GPS'),
                ),
              ] else if (deniedForever)
                TextButton(
                  onPressed: onOpenAppSettings,
                  child: const Text('Buka Pengaturan'),
                )
              else
                TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          ),
        ],
      ),
    );
  }
}

/// The action the user chose in the automatic date & time hard-block dialog.
enum AutoTimeBlockedChoice {
  /// OK — acknowledge and leave the attendance page (the clock is still manual).
  dismissed,

  /// Buka Pengaturan — open the system Date & Time settings.
  openSettings,
}

/// Shows the AGHRIS-style hard block for a manual device clock.
///
/// The dialog is non-dismissible (no barrier tap, no back button) so the user
/// must pick an action: [AutoTimeBlockedChoice.openSettings] to open the system
/// Date & Time screen, or [AutoTimeBlockedChoice.dismissed] (OK) which the
/// caller uses to navigate the user off the capture page. Attendance stays
/// blocked either way until the automatic clock (and time zone) is enabled.
Future<AutoTimeBlockedChoice> showAutoTimeBlockedDialog(BuildContext context) {
  return showDialog<AutoTimeBlockedChoice>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Tanggal & waktu tidak otomatis'),
        content: const Text(
          'Aktifkan Tanggal & Waktu Otomatis serta Zona Waktu Otomatis '
          'untuk melakukan presensi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(AutoTimeBlockedChoice.dismissed),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(AutoTimeBlockedChoice.openSettings),
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    ),
  ).then((choice) => choice ?? AutoTimeBlockedChoice.dismissed);
}

/// Shows the hard block while no valid trusted-time anchor exists (fresh
/// install, or a post-reboot device that is still offline).
///
/// Reuses the auto-time navigation pattern: the dialog is non-dismissible (no
/// barrier tap, no back button) with a single OK action, after which the caller
/// navigates the user off the capture page. Reconnecting re-establishes the
/// anchor via the HTTP interceptor and clears the block.
Future<void> showTrustedTimeBlockedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Waktu perangkat belum terverifikasi'),
        content: const Text(
          'Hubungkan ke internet terlebih dahulu untuk memverifikasi waktu '
          'sebelum melakukan absensi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

/// Shows a blocking dialog when a mock/fake/simulated location is detected.
///
/// The dialog prevents attendance from proceeding until the mock provider is
/// disabled. Unlike the auto-time dialog it does not navigate the user away —
/// they stay on the page so they can disable the fake GPS app and retry via
/// the inline error notice.
Future<void> showMockLocationBlockedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Lokasi tidak dapat diverifikasi'),
      content: const Text(
        'Lokasi palsu terdeteksi. Presensi tidak dapat dilakukan '
        'karena lokasi Anda tidak dapat diverifikasi.\n\n'
        'Jika Anda menggunakan aplikasi Fake GPS atau Mock Location, '
        'nonaktifkan terlebih dahulu, lalu coba lagi.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Mengerti'),
        ),
      ],
    ),
  );
}

/// [today]'s attendance record when the snapshot belongs to the trusted
/// [currentDate] (or that date is unknown); `null` for a snapshot cached on
/// another day.
AttendanceModel? _currentDayAttendance(
  AttendanceTodayModel? today,
  String? currentDate,
) {
  if (today == null || isOtherAttendanceDay(today.date, currentDate)) {
    return null;
  }
  return today.attendance;
}

/// "Histori absensi hari ini" heading: a light-blue clock badge and the title.
class _HistorySectionTitle extends StatelessWidget {
  const _HistorySectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: _sectionBadge,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(7),
            child: Icon(Icons.schedule_rounded, size: 20, color: Colors.white),
          ),
        ),
        SizedBox(width: 12),
        // Wraps under large text instead of overflowing.
        Flexible(
          child: Text(
            'Histori absensi hari ini',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal inset of the header and rows inside the history table.
const _tableInset = 8.0;

/// Space kept on each side of a history cell's content.
const _cellPadding = 6.0;

const _headerIconSize = 14.0;
const _headerIconGap = 4.0;
const _statusPillPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 4);

const _headerTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.2,
);
const _cellTextStyle = TextStyle(
  color: _navy,
  fontSize: 13,
  fontWeight: FontWeight.w500,
  fontFeatures: [FontFeature.tabularFigures()],
);
const _statusTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

/// The history table's columns, in display order.
enum _HistoryColumn {
  no('No'),
  jam('Jam', Icons.schedule_rounded),
  latitude('Latitude', Icons.location_on_outlined),
  longitude('Longitude', Icons.location_on_outlined),
  status('Status', Icons.layers_outlined);

  const _HistoryColumn(this.label, [this.icon]);

  final String label;
  final IconData? icon;
}

/// Column widths for the history table within [available] width.
///
/// Each column gets its content width — the widest of its header and the
/// [rows]' cells, measured at the current text scale, plus padding — and any
/// spare width is shared equally. When the content is wider than [available]
/// the widths add up to more, and the table scrolls sideways.
List<double> _historyColumnWidths(
  BuildContext context,
  List<_HistoryRow> rows,
  double available,
) {
  final baseStyle = DefaultTextStyle.of(context).style;
  final textScaler = MediaQuery.textScalerOf(context);
  final textDirection = Directionality.of(context);

  double textWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: baseStyle.merge(style)),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final width = painter.width.ceilToDouble();
    painter.dispose();
    return width;
  }

  final content = [
    for (final column in _HistoryColumn.values)
      [
            (column.icon == null ? 0.0 : _headerIconSize + _headerIconGap) +
                textWidth(column.label, _headerTextStyle),
            for (final row in rows)
              column == _HistoryColumn.status
                  ? textWidth(row.status, _statusTextStyle) +
                        _statusPillPadding.horizontal
                  : textWidth(row.cell(column), _cellTextStyle),
          ].reduce(math.max) +
          2 * _cellPadding,
  ];
  final spare =
      available - 2 * _tableInset - content.fold(0.0, (sum, w) => sum + w);
  final extra = spare > 0 ? spare / content.length : 0.0;
  return [for (final width in content) width + extra];
}

/// Today's attendance history as a five-column table: a navy header over
/// white rows.
///
/// Every column is at least as wide as its widest header or cell, so values
/// are never truncated. Spare width is shared between the columns; when the
/// screen is too narrow (small phones, large text) the table scrolls sideways
/// inside its rounded container instead.
class _TodayHistoryTable extends StatelessWidget {
  const _TodayHistoryTable({required this.attendance, required this.loading});

  final AttendanceModel? attendance;
  final bool loading;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    final rows = <_HistoryRow>[];
    final a = attendance;
    if (a != null && a.checkInTime != null) {
      rows.add(
        _HistoryRow(
          no: rows.length + 1,
          jam: a.checkInTime!,
          lat: a.checkInLatitude,
          long: a.checkInLongitude,
          status: 'Masuk',
        ),
      );
    }
    if (a != null && a.checkOutTime != null) {
      rows.add(
        _HistoryRow(
          no: rows.length + 1,
          jam: a.checkOutTime!,
          lat: a.checkOutLatitude,
          long: a.checkOutLongitude,
          status: 'Pulang',
        ),
      );
    }

    // Rows only appear once the dashboard has resolved, as before.
    final visibleRows = loading ? const <_HistoryRow>[] : rows;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        boxShadow: [_surfaceShadow],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final widths = _historyColumnWidths(
                  context,
                  visibleRows,
                  constraints.maxWidth,
                );
                final tableWidth =
                    widths.fold(0.0, (sum, w) => sum + w) + 2 * _tableInset;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HistoryHeader(widths: widths),
                        for (var i = 0; i < visibleRows.length; i++) ...[
                          if (i > 0)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                              color: _divider,
                            ),
                          _HistoryDataRow(row: visibleRows[i], widths: widths),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(color: _navy)),
              )
            else if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 18,
                      color: _bodyMuted,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Belum ada absensi hari ini.',
                        style: TextStyle(color: _bodyMuted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow {
  const _HistoryRow({
    required this.no,
    required this.jam,
    required this.status,
    this.lat,
    this.long,
  });

  final int no;
  final String jam;
  final String? lat;
  final String? long;
  final String status;

  /// The text shown for this row in [column].
  String cell(_HistoryColumn column) => switch (column) {
    _HistoryColumn.no => '$no',
    _HistoryColumn.jam => jam,
    _HistoryColumn.latitude => lat ?? '-',
    _HistoryColumn.longitude => long ?? '-',
    _HistoryColumn.status => status,
  };
}

/// Navy header row; each label (with its icon) is centred over its column.
class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.widths});

  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _tableHeader),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _tableInset,
          vertical: 13,
        ),
        child: Row(
          children: [
            for (final column in _HistoryColumn.values)
              SizedBox(
                width: widths[column.index],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (column.icon case final icon?) ...[
                      Icon(icon, size: _headerIconSize, color: Colors.white),
                      const SizedBox(width: _headerIconGap),
                    ],
                    Text(
                      column.label,
                      maxLines: 1,
                      softWrap: false,
                      style: _headerTextStyle,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One white data row; values are centred under their column headers.
class _HistoryDataRow extends StatelessWidget {
  const _HistoryDataRow({required this.row, required this.widths});

  final _HistoryRow row;
  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _tableInset,
        vertical: 12,
      ),
      child: Row(
        children: [
          for (final column in _HistoryColumn.values)
            SizedBox(
              width: widths[column.index],
              child: column == _HistoryColumn.status
                  ? Center(child: _StatusPill(row.status))
                  : Text(
                      row.cell(column),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      style: _cellTextStyle,
                    ),
            ),
        ],
      ),
    );
  }
}

/// Small rounded badge for a history row's status (Masuk / Pulang).
class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      'Masuk' => (_checkInStatusBackground, _checkInStatusText),
      _ => (_checkOutStatusBackground, _navy),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: _statusPillPadding,
        child: Text(
          status,
          maxLines: 1,
          softWrap: false,
          style: _statusTextStyle.copyWith(color: foreground),
        ),
      ),
    );
  }
}
