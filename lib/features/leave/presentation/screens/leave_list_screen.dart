import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../../../shared/widgets/aura_form.dart';
import '../../data/models/leave_models.dart';
import '../providers/leave_list_notifier.dart';
import '../providers/leave_list_state.dart';
import '../widgets/leave_request_visuals.dart';

/// A paginated, newest-first list of the intern's leave requests for one
/// [LeaveListFilter] (pending or history).
///
/// Infinite scroll appends the next page as the user nears the end;
/// pull-to-refresh reloads from the first page. Tapping a card opens the
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

    return AuraPageScaffold(
      title: _title,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(leaveListProvider(filter).notifier).refresh(),
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
    final horizontal = AuraForm.pageInset(MediaQuery.sizeOf(context).width);

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
      child: Column(
        children: [
          if (state.isOffline) const _OfflineBanner(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return _ListFooter(
                    isLoadingMore: state.isLoadingMore,
                    hasMore: state.hasMore,
                  );
                }
                return _LeaveCard(request: state.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Non-blocking notice shown above a cached list while the device is offline.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Anda sedang offline. Menampilkan data terakhir yang tersimpan.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One leave request: its type icon, type and number with the status badge,
/// the date range and, when known, the day count. Shared by the pending and
/// history lists.
class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.request});

  final LeaveRequestModel request;

  static const _dateIconSize = 18.0;
  static const _dateIconGap = 8.0;

  // Zero letter spacing overrides the inherited M3 body tracking, as on Home.
  static const _dateStyle = TextStyle(
    color: AuraForm.heading,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    final accent = LeaveTypeAccent.of(request.type);
    final totalDays = request.totalDays;

    return LeaveCardSurface(
      child: InkWell(
        borderRadius: LeaveCardSurface.borderRadius,
        onTap: () => context.pushNamed(
          RouteNames.leaveDetail,
          pathParameters: {'id': request.id.toString()},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LeaveRequestHeading(request: request),
                const SizedBox(height: 14),
                _dates(context, constraints.maxWidth),
                // Hidden rather than "null hari" when the count is unknown.
                if (totalDays != null) ...[
                  const SizedBox(height: 10),
                  LeaveDaysPill(days: totalDays, accent: accent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The date range beside a calendar icon centred on its first line, in
  /// [maxWidth]. A range too long for one line breaks after its dash first,
  /// so each date stays whole while it fits on a line.
  Widget _dates(BuildContext context, double maxWidth) {
    final start = request.startDate;
    final end = request.endDate;
    final parts = start == null
        ? const ['-']
        : end == null || end == start
        ? [formatIndoDate(start)]
        : ['${formatIndoDate(start)} –', formatIndoDate(end)];
    final textWidth = maxWidth - _dateIconSize - _dateIconGap;
    final whole = parts.join(' ');
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(_dateStyle.fontSize!) *
        _dateStyle.height!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: ((lineHeight - _dateIconSize) / 2).clamp(0, double.infinity),
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            size: _dateIconSize,
            color: AuraForm.heading,
          ),
        ),
        const SizedBox(width: _dateIconGap),
        Expanded(
          child:
              parts.length == 1 ||
                  AuraForm.textSize(context, whole, _dateStyle).width <=
                      textWidth
              ? Text(whole, style: _dateStyle)
              // Read as one range.
              : MergeSemantics(
                  child: Wrap(
                    spacing: AuraForm.textSize(context, ' ', _dateStyle).width,
                    children: [
                      for (final part in parts) Text(part, style: _dateStyle),
                    ],
                  ),
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

  static const _end = 'Tidak ada data lagi';
  static const _endStyle = TextStyle(
    color: AuraForm.bodyMuted,
    fontSize: 13,
    letterSpacing: 0,
  );
  static const _lineGap = 12.0;

  /// Shortest hairline worth drawing beside the end marker.
  static const _minLine = 24.0;

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const text = Text(_end, style: _endStyle);
            final fits =
                AuraForm.textSize(context, _end, _endStyle).width +
                    2 * (_lineGap + _minLine) <=
                constraints.maxWidth;
            // Between two hairlines, as in the reference design, while the
            // marker fits on one line between them; centred on its own
            // otherwise.
            if (!fits) {
              return const Text(
                _end,
                style: _endStyle,
                textAlign: TextAlign.center,
              );
            }
            return const Row(
              children: [
                Expanded(
                  child: Divider(color: AuraForm.fieldBorder, height: 1),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _lineGap),
                  child: text,
                ),
                Expanded(
                  child: Divider(color: AuraForm.fieldBorder, height: 1),
                ),
              ],
            );
          },
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
    final message = switch (filter) {
      LeaveListFilter.pending =>
        'Belum ada pengajuan yang menunggu persetujuan.',
      LeaveListFilter.history => 'Belum ada riwayat pengajuan.',
    };
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 160),
        const Icon(Icons.inbox_outlined, size: 56, color: AuraForm.bodyMuted),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AuraForm.heading,
            fontSize: 14,
            height: 1.4,
          ),
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
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AuraForm.heading,
            fontSize: 14,
            height: 1.4,
          ),
        ),
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
