import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/location_result.dart';
import '../../data/models/attendance_models.dart';
import '../geofence_evaluation.dart';
import '../providers/attendance_dashboard_notifier.dart';
import '../providers/attendance_locations_provider.dart';
import '../providers/check_in_notifier.dart';
import '../providers/check_in_state.dart';
import '../providers/check_out_notifier.dart';
import '../providers/check_out_state.dart';
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
    extends ConsumerState<AttendancePresenceScreen> {
  static const double _mapSectionHeight = 260;

  /// Which action is currently acquiring a fresh fix / submitting, so the
  /// pressed button shows progress and both buttons stay disabled meanwhile.
  _PendingAction? _pendingAction;

  @override
  void initState() {
    super.initState();
    // Refresh the current location every time the page opens, before any
    // attendance action, so submissions use a fresh fix.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentLocationProvider.notifier).fetch();
    });
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
      // to the server's business rules.
      if (type == _workModeWfo && !_ensureWithinOfficeRadius(position)) {
        return;
      }

      await ref
          .read(checkInControllerProvider.notifier)
          .submit(
            workMode: type,
            latitude: position?.latitude,
            longitude: position?.longitude,
          );
    } finally {
      if (mounted) setState(() => _pendingAction = null);
    }
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

  /// Guards WFO submissions against the office radius, mirroring the check-in
  /// policy. Returns `true` when submission may proceed; otherwise shows a
  /// snackbar and returns `false`.
  bool _ensureWithinOfficeRadius(GeoPosition? position) {
    if (position == null) {
      _showSnack('Ambil lokasi Anda terlebih dahulu.');
      return false;
    }
    final offices = switch (ref.read(attendanceLocationsProvider)) {
      AsyncData(:final value) => value,
      _ => const <AttendanceLocationModel>[],
    };
    final verdict = evaluateGeofence(
      offices,
      position.latitude,
      position.longitude,
    );
    if (verdict is GeofenceInside) return true;

    _showSnack(switch (verdict) {
      GeofenceOutside(:final location, :final distanceMeters) =>
        'Anda di luar radius kantor ${location.name} '
            '(${distanceMeters.round()} m).',
      GeofenceNoLocations() => 'Belum ada lokasi kantor yang dikonfigurasi.',
      _ => 'Lokasi tidak valid untuk WFO.',
    });
    return false;
  }

  Future<void> _onCheckOutPressed(AttendanceModel attendance) async {
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
      if (attendance.workMode == _workModeWfo &&
          !_ensureWithinOfficeRadius(position)) {
        return;
      }

      await ref
          .read(checkOutControllerProvider.notifier)
          .submit(latitude: position?.latitude, longitude: position?.longitude);
    } finally {
      if (mounted) setState(() => _pendingAction = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(currentLocationProvider);
    final dashboard = ref.watch(attendanceDashboardProvider);
    final checkInState = ref.watch(checkInControllerProvider);
    final checkOutState = ref.watch(checkOutControllerProvider);

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
    final hasCheckedIn = attendance != null;
    final hasCheckedOut = attendance?.checkOutTime != null;

    final isCheckingIn =
        checkInState is CheckInSubmitting ||
        _pendingAction == _PendingAction.checkIn;
    final isCheckingOut =
        checkOutState is CheckOutSubmitting ||
        _pendingAction == _PendingAction.checkOut;
    final isBusy = isCheckingIn || isCheckingOut;

    final canCheckIn =
        !isBusy && dashboard is AsyncData && !hasCheckedIn && !onLeave;
    final canCheckOut = !isBusy && hasCheckedIn && !hasCheckedOut;

    ref.listen<CheckInState>(checkInControllerProvider, (_, next) {
      switch (next) {
        case CheckInSuccess():
          _showSnack('Check In berhasil.');
        case CheckInFailure(:final message):
          _showSnack(message);
        default:
          break;
      }
    });
    ref.listen<CheckOutState>(checkOutControllerProvider, (_, next) {
      switch (next) {
        case CheckOutSuccess():
          _showSnack('Check Out berhasil.');
        case CheckOutFailure(:final message):
          _showSnack(message);
        default:
          break;
      }
    });

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
                if (locationState is LocationError) ...[
                  const SizedBox(height: 12),
                  _LocationErrorNotice(
                    message: locationState.message,
                    onRetry: () =>
                        ref.read(currentLocationProvider.notifier).fetch(),
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
                            ? () => _onCheckOutPressed(attendance)
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
  const _LocationErrorNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
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
