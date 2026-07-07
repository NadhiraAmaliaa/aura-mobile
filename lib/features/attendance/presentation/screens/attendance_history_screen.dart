import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../data/models/attendance_models.dart';
import '../providers/attendance_history_notifier.dart';
import '../providers/attendance_history_state.dart';

/// Read-only attendance history: a paginated, newest-first list of records.
///
/// Slice 2: reuses the same `AttendanceModel` as the dashboard. Infinite scroll
/// appends the next page as the user nears the end; pull-to-refresh reloads
/// from the first page.
class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(attendanceHistoryProvider.notifier).refresh(),
        child: switch (history) {
          AsyncData(:final value) => _HistoryList(state: value),
          AsyncError(:final error) => _ErrorView(
            message: error is AppException
                ? error.message
                : 'Gagal memuat riwayat absensi.',
            onRetry: () =>
                ref.read(attendanceHistoryProvider.notifier).refresh(),
          ),
          _ => const _LoadingView(),
        },
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.state});

  final AttendanceHistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isEmpty) {
      return const _EmptyView();
    }

    // Trailing footer slot: a loader while paging, nothing otherwise.
    final itemCount = state.items.length + 1;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (state.hasMore &&
            !state.isLoadingMore &&
            metrics.pixels >= metrics.maxScrollExtent - 200) {
          ref.read(attendanceHistoryProvider.notifier).loadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _ListFooter(
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
            );
          }
          return _HistoryTile(record: state.items[index]);
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final AttendanceModel record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = record.attendanceDate != null
        ? formatIndoDateWithWeekday(record.attendanceDate!)
        : '-';

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(label: record.statusLabel, status: record.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimeCell(
                    icon: Icons.login,
                    label: 'Masuk',
                    time: record.checkInTime ?? '--:--',
                  ),
                ),
                Expanded(
                  child: _TimeCell(
                    icon: Icons.logout,
                    label: 'Pulang',
                    time: record.checkOutTime ?? '--:--',
                  ),
                ),
                if (record.workModeLabel != null)
                  Expanded(
                    child: _TimeCell(
                      icon: Icons.work_outline,
                      label: 'Mode',
                      time: record.workModeLabel!,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Map the backend status to a tone. Unknown statuses fall back to neutral.
    final (Color bg, Color fg) = switch (status) {
      'present' => (scheme.primaryContainer, scheme.onPrimaryContainer),
      'late' => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      'sick' ||
      'permission' => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      'absent' => (scheme.errorContainer, scheme.onErrorContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
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
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: muted),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.isLoadingMore, required this.hasMore});

  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Tidak ada data lagi',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 240),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 160),
        Icon(
          Icons.event_note_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'Belum ada riwayat absensi.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
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
