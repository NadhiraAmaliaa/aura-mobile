import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/device_time_providers.dart';
import '../../../../core/device/device_time_settings.dart';
import '../../../../core/location/location_result.dart';
import '../../data/local/attendance_queue_entry.dart';
import '../../data/models/attendance_models.dart';
import '../geofence_evaluation.dart';
import '../providers/attendance_dashboard_notifier.dart';
import '../providers/attendance_locations_provider.dart';
import '../providers/attendance_queue_controller.dart';
import '../providers/automatic_time_notifier.dart';
import '../providers/current_location_notifier.dart';
import '../providers/current_location_state.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh the current location every time the page opens, before any
    // attendance action, so submissions use a fresh fix. Also drain any events
    // left pending from a previous session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
          );
      if (!mounted) return;
      _showCaptureOutcome(entry, syncedMessage: 'Check In berhasil.');
    } on AutomaticTimeDisabledException catch (e) {
      if (!mounted) return;
      _handleAutomaticTimeBlocked(e);
    } finally {
      if (mounted) setState(() => _pendingAction = null);
    }
  }

  /// Surfaces the automatic-clock block: refreshes the status notifier so the
  /// notice appears and the buttons disable, then explains why via a snackbar.
  void _handleAutomaticTimeBlocked(AutomaticTimeDisabledException e) {
    ref.read(automaticTimeStatusProvider.notifier).refresh();
    _showSnack(e.message);
  }

  /// Guards every work mode against a spoofed/mocked GPS fix. The location
  /// service rejects a mocked fix as a [LocationFailureKind.mocked] failure;
  /// this surfaces that reason and blocks submission. Returns `true` when the
  /// fix is trusted (or the failure was unrelated to mocking).
  bool _ensureLocationTrusted() {
    final state = ref.read(currentLocationProvider);
    if (state is LocationError && state.kind == LocationFailureKind.mocked) {
      _showSnack(state.message);
      return false;
    }
    return true;
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

    _showSnack(switch (verdict) {
      GeofenceOutside(:final location, :final distanceMeters) =>
        'Anda di luar radius kantor ${location.name} '
            '(${distanceMeters.round()} m).',
      GeofenceNoLocations() => 'Belum ada lokasi kantor yang dikonfigurasi.',
      _ => 'Lokasi tidak valid untuk WFO.',
    });
    return null;
  }

  /// Turns a captured queue entry into a user-facing snackbar.
  void _showCaptureOutcome(
    AttendanceQueueEntry entry, {
    required String syncedMessage,
  }) {
    _showSnack(switch (entry.status) {
      QueuedEventStatus.synced => syncedMessage,
      QueuedEventStatus.pending =>
        'Absensi tersimpan. Akan dikirim otomatis saat online.',
      QueuedEventStatus.rejected =>
        entry.lastError ?? 'Absensi ditolak oleh server.',
    });
  }

  Future<void> _onCheckOutPressed(String? workMode) async {
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
          );
      if (!mounted) return;
      _showCaptureOutcome(entry, syncedMessage: 'Check Out berhasil.');
    } on AutomaticTimeDisabledException catch (e) {
      if (!mounted) return;
      _handleAutomaticTimeBlocked(e);
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

    final position = switch (locationState) {
      LocationReady(:final position) => position,
      _ => null,
    };

    final today = switch (dashboard) {
      AsyncData(:final value) => value.today,
      _ => null,
    };
    final attendance = today?.attendance;
    final onLeave = today?.leave != null;

    // Fold in today's queued (offline) actions so the screen reflects a capture
    // immediately — before it has synced to the server-backed dashboard.
    final pendingActions = ref.watch(pendingAttendanceActionsProvider);
    final hasCheckedIn = attendance != null || pendingActions.hasCheckIn;
    final hasCheckedOut =
        attendance?.checkOutTime != null || pendingActions.hasCheckOut;
    // Work mode to gate an offline WFO check-out: the server record if present,
    // otherwise the queued check-in's mode.
    final checkOutWorkMode =
        attendance?.workMode ?? pendingActions.checkInWorkMode;

    final isCheckingIn = _pendingAction == _PendingAction.checkIn;
    final isCheckingOut = _pendingAction == _PendingAction.checkOut;
    final isBusy = isCheckingIn || isCheckingOut;

    // Offline-friendly: the dashboard resolves to cached data when unreachable,
    // so check-in stays enabled. A truly empty state (error, no cache) still
    // blocks until the user can load once.
    final canCheckIn =
        !isBusy &&
        !autoTimeBlocked &&
        dashboard is AsyncData &&
        !hasCheckedIn &&
        !onLeave;
    final canCheckOut =
        !isBusy && !autoTimeBlocked && hasCheckedIn && !hasCheckedOut;

    return Scaffold(
      appBar: AppBar(title: const Text('Presensi')),
      body: Column(
        children: [
          SizedBox(
            height: _mapSectionHeight,
            width: double.infinity,
            child: CheckInMap(userPosition: position),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _LiveDateTimeCard(),
                const _PendingSyncNotice(),
                if (autoTimeBlocked) ...[
                  const SizedBox(height: 12),
                  _AutoTimeNotice(
                    onOpenSettings: () => ref
                        .read(deviceTimeSettingsProvider)
                        .openDateTimeSettings(),
                  ),
                ],
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
                Text(
                  'Histori absensi hari ini',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _TodayHistoryTable(
                  attendance: attendance,
                  loading: dashboard is AsyncLoading,
                ),
              ],
            ),
          ),
        ],
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

/// Green card that shows the current date and time, ticking every second.
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _formatIndoDateTime(_now),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 18),
                SizedBox(width: 8),
                Text('Check In'),
              ],
            ),
    );
  }
}

class _CheckOutButton extends StatelessWidget {
  const _CheckOutButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onError,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 18),
                SizedBox(width: 8),
                Text('Check Out'),
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
                Icons.location_off,
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

/// Warns that attendance is blocked because the device clock is set manually,
/// and offers a shortcut to the system Date & Time settings. The block clears
/// automatically once the user returns with the automatic clock enabled.
class _AutoTimeNotice extends StatelessWidget {
  const _AutoTimeNotice({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                Icons.schedule,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Aktifkan Tanggal & Waktu otomatis (termasuk zona waktu '
                  'otomatis) untuk melakukan absensi.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Today's attendance history rendered as a lightweight table.
class _TodayHistoryTable extends StatelessWidget {
  const _TodayHistoryTable({required this.attendance, required this.loading});

  final AttendanceModel? attendance;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const _HistoryHeader(),
          const Divider(height: 1),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada absensi hari ini.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _HistoryDataRow(row: rows[i]),
            ],
        ],
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
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('No', style: style)),
          Expanded(flex: 2, child: Text('Jam', style: style)),
          Expanded(flex: 3, child: Text('Latitude', style: style)),
          Expanded(flex: 3, child: Text('Longitude', style: style)),
          Expanded(flex: 2, child: Text('Status', style: style)),
        ],
      ),
    );
  }
}

class _HistoryDataRow extends StatelessWidget {
  const _HistoryDataRow({required this.row});

  final _HistoryRow row;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('${row.no}', style: style)),
          Expanded(flex: 2, child: Text(row.jam, style: style)),
          Expanded(
            flex: 3,
            child: Text(
              row.lat ?? '-',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.long ?? '-',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 2, child: Text(row.status, style: style)),
        ],
      ),
    );
  }
}
