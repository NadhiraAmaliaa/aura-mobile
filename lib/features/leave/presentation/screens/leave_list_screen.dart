import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../data/models/leave_models.dart';
import '../providers/leave_list_notifier.dart';
import '../providers/leave_list_state.dart';
import '../widgets/leave_status_chip.dart';

/// A paginated, newest-first list of the intern's leave requests for one
/// [LeaveListFilter] (pending or history).
///
/// Infinite scroll appends the next page as the user nears the end;
/// pull-to-refresh reloads from the first page. Tapping a tile opens the
/// read-only detail screen.
class LeaveListScreen extends ConsumerWidget {
  const LeaveListScreen({required this.filter, super.key});

  final LeaveListFilter filter;

  String get _title => switch (filter) {
    LeaveListFilter.pending => 'Menunggu Persetujuan',
    LeaveListFilter.history => 'Riwayat Pengajuan',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(leaveListProvider(filter));

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(leaveListProvider(filter).notifier).refresh(),
        child: switch (list) {
          AsyncData(:final value) => _LeaveList(filter: filter, state: value),
          AsyncError(:final error) => _ErrorView(
            message: error is AppException
                ? error.message
                : 'Gagal memuat data pengajuan.',
            onRetry: () =>
                ref.read(leaveListProvider(filter).notifier).refresh(),
          ),
          _ => const _LoadingView(),
        },
      ),
    );
  }
}

class _LeaveList extends ConsumerWidget {
  const _LeaveList({required this.filter, required this.state});

  final LeaveListFilter filter;
  final LeaveListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isEmpty) {
      return _EmptyView(filter: filter);
    }

    final itemCount = state.items.length + 1;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (state.hasMore &&
            !state.isLoadingMore &&
            metrics.pixels >= metrics.maxScrollExtent - 200) {
          ref.read(leaveListProvider(filter).notifier).loadMore();
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
          return _LeaveTile(request: state.items[index]);
        },
      ),
    );
  }
}

class _LeaveTile extends StatelessWidget {
  const _LeaveTile({required this.request});

  final LeaveRequestModel request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.pushNamed(
          RouteNames.leaveDetail,
          pathParameters: {'id': request.id.toString()},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.typeLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  LeaveStatusChip(
                    label: request.statusLabel,
                    status: request.status,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                request.requestNumber,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _dateRange(request),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${request.totalDays} hari',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateRange(LeaveRequestModel request) {
    final start = request.startDate;
    final end = request.endDate;
    if (start == null) return '-';
    if (end == null || end == start) return formatIndoDate(start);
    return '${formatIndoDate(start)} - ${formatIndoDate(end)}';
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
  const _EmptyView({required this.filter});

  final LeaveListFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = switch (filter) {
      LeaveListFilter.pending =>
        'Belum ada pengajuan yang menunggu persetujuan.',
      LeaveListFilter.history => 'Belum ada riwayat pengajuan.',
    };
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 160),
        Icon(
          Icons.inbox_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          message,
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
