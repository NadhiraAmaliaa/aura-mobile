import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../app/router/routes.dart';
import '../../data/models/attendance_models.dart';
import '../providers/attendance_dashboard_notifier.dart';
import '../widgets/location_card.dart';

/// Attendance landing / dashboard.
///
/// Slice 1: read-only. Shows today's working hours and check-in/out status plus
/// the monthly recap. The check-in flow and history land in later slices.
class AttendanceDashboardScreen extends ConsumerWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(attendanceDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            icon: const Icon(Icons.history),
            onPressed: () => context.pushNamed(RouteNames.attendanceHistory),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(attendanceDashboardProvider.notifier).refresh(),
        child: switch (dashboard) {
          AsyncData(:final value) => _DashboardContent(data: value),
          AsyncError(:final error) => _ErrorView(
            message: error is AppException
                ? error.message
                : 'Gagal memuat data absensi.',
            onRetry: () =>
                ref.read(attendanceDashboardProvider.notifier).refresh(),
          ),
          _ => const _LoadingView(),
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    // Wrapped in a scroll view so RefreshIndicator has a scrollable child.
    return ListView(
      children: const [
        SizedBox(height: 240),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 160),
        Icon(
          Icons.cloud_off_outlined,
          size: 56,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final AttendanceDashboardModel data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TodayCard(today: data.today),
        const SizedBox(height: 16),
        const LocationCard(),
        const SizedBox(height: 24),
        Text(
          'Rekapitulasi Presensi Bulan',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _SummaryGrid(summary: data.summary),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today});

  final AttendanceTodayModel today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attendance = today.attendance;
    final workHours = today.workHours;

    final hoursLabel = (workHours.start != null && workHours.end != null)
        ? '${workHours.start} - ${workHours.end}'
        : 'Hari libur';

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jam Kerja Hari Ini',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hoursLabel,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Text(
              'Absensi hari ini, ${_formatIndoDate(today.date)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TimeColumn(
                  icon: Icons.login,
                  label: 'Check In',
                  time: attendance?.checkInTime ?? '--:--',
                ),
                _TimeColumn(
                  icon: Icons.logout,
                  label: 'Check Out',
                  time: attendance?.checkOutTime ?? '--:--',
                ),
              ],
            ),
            if (attendance != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(attendance.statusLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (attendance.workModeLabel != null)
                    Chip(
                      label: Text(attendance.workModeLabel!),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ] else if (today.leave != null) ...[
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.event_busy_outlined, size: 18),
                label: Text('Sedang ${today.leave!.typeLabel}'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.icon,
    required this.label,
    required this.time,
  });

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          time,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final MonthlySummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, int value})>[
      (label: 'Hadir', value: summary.hadir),
      (label: 'Terlambat', value: summary.terlambat),
      (label: 'Izin', value: summary.izin),
      (label: 'Sakit', value: summary.sakit),
      (label: 'Dinas Luar', value: summary.dinas),
      (label: 'Tidak Absen', value: summary.tidakAbsen),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        for (final item in items)
          _SummaryTile(label: item.label, value: item.value),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats an ISO `yyyy-MM-dd` string as e.g. "6 Juli 2026".
///
/// Kept inline (no shared formatter / intl locale setup yet) so Slice 1 stays
/// self-contained; a shared formatter can absorb this later.
String _formatIndoDate(String iso) {
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

  final date = DateTime.tryParse(iso);
  if (date == null) return iso;

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
