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

// The card surface of the leave landing page's cards.
const _cardRadius = 20.0;
const _cardShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);

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

/// Colours and icon of a request type: soft pink for sakit, pastel green for
/// izin, the AURA blue for anything else.
class _TypeAccent {
  const _TypeAccent({required this.tint, required this.foreground, this.asset});

  /// Behind the type icon and the day count.
  final Color tint;

  /// The day count's icon and text, dark enough to read on [tint].
  final Color foreground;

  /// The type's icon; types without one get a generic Material icon.
  final String? asset;

  static const sakit = _TypeAccent(
    tint: Color(0xFFFFE5E8),
    foreground: Color(0xFFC62F3B),
    asset: 'assets/images/leave/sakit.png',
  );
  static const izin = _TypeAccent(
    tint: Color(0xFFE3F4DC),
    foreground: Color(0xFF237A12),
    asset: 'assets/images/leave/izin.png',
  );
  static const other = _TypeAccent(
    tint: Color(0xFFE3EEFF),
    foreground: AuraForm.navy,
  );

  static _TypeAccent of(String type) => switch (type) {
    'sakit' => sakit,
    'izin' => izin,
    _ => other,
  };
}

/// One leave request: its type icon, type and number with the status badge,
/// the date range and, when known, the day count. Shared by the pending and
/// history lists.
class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.request});

  final LeaveRequestModel request;

  static const _tileSize = 48.0;
  static const _iconSize = 30.0;
  static const _headerGap = 12.0;
  static const _badgeGap = 8.0;
  static const _dateIconSize = 18.0;
  static const _dateIconGap = 8.0;

  // Zero letter spacing overrides the inherited M3 body tracking, as on Home.
  static const _titleStyle = TextStyle(
    color: AuraForm.heading,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );
  static const _numberStyle = TextStyle(
    color: AuraForm.bodyMuted,
    fontSize: 13,
    height: 1.3,
    letterSpacing: 0,
  );
  static const _dateStyle = TextStyle(
    color: AuraForm.heading,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    final accent = _TypeAccent.of(request.type);
    final borderRadius = BorderRadius.circular(_cardRadius);
    final totalDays = request.totalDays;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [_cardShadow],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
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
                  ..._header(context, accent, constraints.maxWidth),
                  const SizedBox(height: 14),
                  _dates(context, constraints.maxWidth),
                  // Hidden rather than "null hari" when the count is unknown.
                  if (totalDays != null) ...[
                    const SizedBox(height: 10),
                    _DaysPill(days: totalDays, accent: accent),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The type tile with the type and number beside it, in [maxWidth]. The
  /// status badge follows the type while both fit on one line and comes
  /// after the number otherwise. When the number does not fit beside the
  /// tile either, it moves under the tile, so it never breaks mid-number.
  List<Widget> _header(
    BuildContext context,
    _TypeAccent accent,
    double maxWidth,
  ) {
    final besideTile = maxWidth - _tileSize - _headerGap;
    final badge = _StatusBadge(
      label: request.statusLabel,
      status: request.status,
    );
    final title = Text(request.typeLabel, style: _titleStyle);
    final number = Text(request.requestNumber, style: _numberStyle);
    final badgeBesideTitle =
        AuraForm.textSize(context, request.typeLabel, _titleStyle).width +
            _badgeGap +
            _StatusBadge.widthOf(context, request.statusLabel) <=
        besideTile;
    final numberBesideTile =
        AuraForm.textSize(context, request.requestNumber, _numberStyle).width <=
        besideTile;

    return [
      Row(
        crossAxisAlignment: numberBesideTile
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          _TypeTile(accent: accent),
          const SizedBox(width: _headerGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badgeBesideTitle)
                  Row(
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: _badgeGap),
                      badge,
                    ],
                  )
                else
                  title,
                if (numberBesideTile) ...[
                  const SizedBox(height: 2),
                  number,
                  if (!badgeBesideTitle) ...[const SizedBox(height: 8), badge],
                ],
              ],
            ),
          ),
        ],
      ),
      if (!numberBesideTile) ...[
        const SizedBox(height: 8),
        number,
        if (!badgeBesideTitle) ...[const SizedBox(height: 8), badge],
      ],
    ];
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

/// The type icon on its tinted rounded square.
class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.accent});

  final _TypeAccent accent;

  @override
  Widget build(BuildContext context) {
    final asset = accent.asset;
    return SizedBox.square(
      dimension: _LeaveCard._tileSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.tint,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: Center(
          // Decorative: the type is read from the title next to it.
          child: asset != null
              ? Image.asset(
                  asset,
                  width: _LeaveCard._iconSize,
                  height: _LeaveCard._iconSize,
                  excludeFromSemantics: true,
                )
              : Icon(
                  Icons.event_note_outlined,
                  size: 26,
                  color: accent.foreground,
                ),
        ),
      ),
    );
  }
}

/// The request's status as a pill: light blue while pending, green once
/// approved, soft red when rejected and neutral for anything else.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.status});

  final String label;
  final String status;

  static const _padding = EdgeInsets.symmetric(horizontal: 12, vertical: 5);
  static const _style = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );

  /// The badge's width for [label] at the current text scale.
  static double widthOf(BuildContext context, String label) =>
      AuraForm.textSize(context, label, _style).width + _padding.horizontal;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (status) {
      'pending' => (const Color(0xFFD9F1F8), const Color(0xFF155A7A)),
      'approved' => (const Color(0xFFDDF3E1), const Color(0xFF1E6B2E)),
      'rejected' => (const Color(0xFFFDE3E3), const Color(0xFFB3261E)),
      _ => (const Color(0xFFECEFF3), AuraForm.bodyMuted),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: _padding,
        child: Text(label, style: _style.copyWith(color: foreground)),
      ),
    );
  }
}

/// "N hari" on the type's tint, with a small calendar icon.
class _DaysPill extends StatelessWidget {
  const _DaysPill({required this.days, required this.accent});

  final int days;
  final _TypeAccent accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.tint,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: accent.foreground,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$days hari',
                style: TextStyle(
                  color: accent.foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
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
