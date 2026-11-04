import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/models/attendance_models.dart';
import '../attendance_month.dart';
import '../providers/attendance_history_month_provider.dart';
import '../providers/attendance_history_notifier.dart';
import '../providers/attendance_history_state.dart';

// Palette reused verbatim from attendance_dashboard_screen.dart (itself taken
// from Home). Kept local until a shared AURA palette exists.
const _heading = Color(0xFF123F69);
const _bodyMuted = Color(0xFF58636A);
const _navy = Color(0xFF194875);
const _divider = Color(0xFFE6ECF1);
const _lateTime = Color(0xFFB06A0C);
const _surfaceShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);

/// Page gutter and content width, matching Home and the dashboard.
double _gutter(double screenWidth) => screenWidth < 360 ? 16 : 18;
const _maxContentWidth = 680.0;

/// Statuses recorded without any clock (approved leave, or an administrative
/// absence). Such a row shows the backend status label instead of empty times.
const attendanceStatusOnlyStatuses = {'sick', 'permission', 'absent'};

/// Placeholder for a missing check-in or check-out time.
const attendanceMissingTime = '--:--';

/// Display text for one history row, derived only from the record itself.
///
/// [day] and [weekday] come from `attendance_date`. When the record has no
/// clock at all and its status is a leave/absence ([attendanceStatusOnlyStatuses])
/// only [statusLabel] is shown (the backend's own label). Otherwise both times
/// are shown, a missing one as [attendanceMissingTime]; nothing is inferred.
typedef AttendanceHistoryRowText = ({
  String day,
  String weekday,
  String? checkIn,
  String? checkOut,
  String? statusLabel,
});

/// Builds the [AttendanceHistoryRowText] for [record].
AttendanceHistoryRowText attendanceHistoryRowText(AttendanceModel record) {
  final iso = record.attendanceDate;
  final date = iso == null ? null : DateTime.tryParse(iso);
  final day = date == null ? '-' : '${date.day}';
  final weekday = iso == null ? '' : (indoWeekdayName(iso) ?? '');

  final hasNoClock = record.checkInTime == null && record.checkOutTime == null;
  if (hasNoClock && attendanceStatusOnlyStatuses.contains(record.status)) {
    return (
      day: day,
      weekday: weekday,
      checkIn: null,
      checkOut: null,
      statusLabel: record.statusLabel,
    );
  }

  return (
    day: day,
    weekday: weekday,
    checkIn: record.checkInTime ?? attendanceMissingTime,
    checkOut: record.checkOutTime ?? attendanceMissingTime,
    statusLabel: null,
  );
}

/// Width of [text] rendered in [style] at the current text scale, rounded up.
double _textWidth(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: DefaultTextStyle.of(context).style.merge(style),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  try {
    return painter.width.ceilToDouble();
  } finally {
    painter.dispose();
  }
}

/// Attendance history for one selected month: a month selector, the month's
/// six-category recap and its paginated, newest-first records.
///
/// The recap comes from the dashboard endpoint and the list from the history
/// endpoint, both for the same `month`. Each month is a separate provider
/// instance, so switching months never mixes or overwrites another month's
/// data. The list only contains records the backend returns (existing records
/// on working days); days without a record are not invented.
class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  // The supplied design is light; same local palette as the dashboard.
  static final theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF174B76),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F8F8),
  );

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  /// Distance from the end of the list at which the next page is requested.
  static const _loadMoreThreshold = 240.0;

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(attendanceHistoryMonthProvider);
    final summary = ref.watch(attendanceMonthSummaryProvider(month));
    final history = ref.watch(attendanceHistoryProvider(month));
    final internStartDate = ref.watch(
      authProvider.select((state) {
        final session = state.asData?.value;
        return session is Authenticated ? session.user.intern?.startDate : null;
      }),
    );
    final range = historyMonthRange(
      latest: ref.watch(attendanceHistoryLatestMonthProvider),
      internStartDate: internStartDate,
    );

    // A first page that does not fill the viewport produces no scroll, so
    // check once the frame is laid out as well.
    if (history is AsyncData && history.requireValue.canLoadMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
    }

    final width = MediaQuery.sizeOf(context).width;
    final horizontal = math.max(_gutter(width), (width - _maxContentWidth) / 2);

    final children = <Widget>[
      _MonthSelector(month: month, onTap: () => _pickMonth(month, range)),
      const SizedBox(height: 14),
      _SummaryCard(
        summary: summary,
        onRetry: () => ref.invalidate(attendanceMonthSummaryProvider(month)),
      ),
      const SizedBox(height: 24),
      _SectionHeader(total: history.value?.pagination?.total),
      const SizedBox(height: 12),
      ...switch (history) {
        AsyncData(:final value) when value.isEmpty => [
          _EmptyView(month: month),
        ],
        AsyncData(:final value) => [
          _HistoryGroup(records: value.items),
          _ListFooter(
            state: value,
            onRetry: () => ref
                .read(attendanceHistoryProvider(month).notifier)
                .retryLoadMore(),
          ),
        ],
        AsyncError(:final error) => [
          _ErrorView(
            message: error is AppException
                ? error.message
                : 'Gagal memuat riwayat presensi.',
            onRetry: () =>
                ref.read(attendanceHistoryProvider(month).notifier).refresh(),
          ),
        ],
        _ => [const _LoadingView()],
      },
    ];

    return Theme(
      data: AttendanceHistoryScreen.theme,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE5EFFB), Color(0xFFF5F8F8)],
            stops: [0, 0.7],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Riwayat Presensi'),
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
          body: RefreshIndicator(
            onRefresh: () => _refresh(month),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.depth != 0) return false;
                // A content-size change can notify during layout, where a
                // provider must not be modified; check after the frame then.
                if (SchedulerBinding.instance.schedulerPhase ==
                    SchedulerPhase.persistentCallbacks) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _maybeLoadMore(),
                  );
                } else {
                  _maybeLoadMore();
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
                itemCount: children.length,
                itemBuilder: (context, index) => children[index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Requests the next page of the selected month when the end is near.
  void _maybeLoadMore() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter > _loadMoreThreshold) return;

    final month = ref.read(attendanceHistoryMonthProvider);
    final history = ref.read(attendanceHistoryProvider(month));
    if (history is AsyncData && history.requireValue.canLoadMore) {
      ref.read(attendanceHistoryProvider(month).notifier).loadMore();
    }
  }

  /// Reloads the month's recap and first history page together.
  Future<void> _refresh(String month) async {
    final summary = ref.refresh(attendanceMonthSummaryProvider(month).future);
    await Future.wait<void>([
      ref.read(attendanceHistoryProvider(month).notifier).refresh(),
      // A failed recap shows its own retry; it must not fail the indicator.
      summary.then<void>((_) {}, onError: (Object _) {}),
    ]);
  }

  Future<void> _pickMonth(
    String selected,
    ({String first, String last}) range,
  ) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => Theme(
        data: AttendanceHistoryScreen.theme,
        child: _MonthPickerSheet(
          selected: selected,
          first: range.first,
          last: range.last,
        ),
      ),
    );
    if (picked == null || !mounted) return;

    ref.read(attendanceHistoryMonthProvider.notifier).select(picked);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.month, required this.onTap});

  final String month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(18));
    return Semantics(
      button: true,
      hint: 'Pilih bulan',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: radius,
          boxShadow: [_surfaceShadow],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: _navy,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatAttendanceMonth(month),
                      style: const TextStyle(
                        color: _heading,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _heading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A white rounded surface shared by the recap and the history rows.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(22)),
        boxShadow: [_surfaceShadow],
      ),
      child: child,
    );
  }
}

typedef _SummaryItem = ({String label, int value, Color color});

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.onRetry});

  final AsyncValue<MonthlySummaryModel> summary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: switch (summary) {
        AsyncData(:final value) => _SummaryColumns(summary: value),
        AsyncError() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              const Text(
                'Ringkasan bulan ini belum dapat dimuat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _bodyMuted, fontSize: 13),
              ),
              TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          ),
        ),
        _ => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                semanticsLabel: 'Memuat ringkasan',
              ),
            ),
          ),
        ),
      },
    );
  }
}

/// The six recap categories, all in one row when the widest label word fits,
/// otherwise in two rows of three (or three rows of two at large text sizes).
/// Values are shown exactly as the backend counted them.
class _SummaryColumns extends StatelessWidget {
  const _SummaryColumns({required this.summary});

  final MonthlySummaryModel summary;

  static const _tilePadding = 2.0;
  static const _valueLabelGap = 4.0;
  static const _rowGap = 12.0;

  static const _valueStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0,
    color: _bodyMuted,
  );
  static const _labelStrut = StrutStyle(
    fontSize: 11,
    height: 1.25,
    forceStrutHeight: true,
  );

  @override
  Widget build(BuildContext context) {
    // Value colours reused from the dashboard's recap tiles.
    final List<_SummaryItem> items = [
      (label: 'Hadir', value: summary.hadir, color: const Color(0xFF1E6B3F)),
      (
        label: 'Terlambat',
        value: summary.terlambat,
        color: const Color(0xFFB06A0C),
      ),
      (label: 'Izin', value: summary.izin, color: const Color(0xFF7E3FC4)),
      (label: 'Sakit', value: summary.sakit, color: const Color(0xFFB2262F)),
      (
        label: 'Dinas Luar',
        value: summary.dinas,
        color: const Color(0xFF1D4F8C),
      ),
      (
        label: 'Tidak Absen',
        value: summary.tidakAbsen,
        color: const Color(0xFF3E4855),
      ),
    ];

    var widestWord = 0.0;
    var widestLabel = 0.0;
    for (final item in items) {
      widestLabel = math.max(
        widestLabel,
        _textWidth(context, item.label, _labelStyle),
      );
      for (final word in item.label.split(' ')) {
        widestWord = math.max(
          widestWord,
          _textWidth(context, word, _labelStyle),
        );
      }
    }
    final lineHeight = MediaQuery.textScalerOf(context).scale(11) * 1.25;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The most columns whose labels never split a word.
        final columns = [6, 3, 2].firstWhere(
          (count) =>
              constraints.maxWidth / count - _tilePadding * 2 >= widestWord,
          orElse: () => 1,
        );
        final contentWidth = constraints.maxWidth / columns - _tilePadding * 2;
        // Reserve a second label line for every tile only when some label
        // wraps, so the dividers line up across the row.
        final labelHeight =
            (widestLabel <= contentWidth ? 1 : 2) * lineHeight.ceilToDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var start = 0; start < items.length; start += columns) ...[
              if (start > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: _rowGap / 2),
                  child: Divider(height: 1, thickness: 1, color: _divider),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = start; i < start + columns; i++)
                    Expanded(
                      child: i < items.length
                          ? _SummaryTile(
                              item: items[i],
                              labelHeight: labelHeight,
                              showDivider: i > start,
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.item,
    required this.labelHeight,
    required this.showDivider,
  });

  final _SummaryItem item;
  final double labelHeight;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${item.label}: ${item.value}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(left: BorderSide(color: _divider))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _SummaryColumns._tilePadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.value}',
                textAlign: TextAlign.center,
                style: _SummaryColumns._valueStyle.copyWith(color: item.color),
              ),
              const SizedBox(height: _SummaryColumns._valueLabelGap),
              SizedBox(
                height: labelHeight,
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  strutStyle: _SummaryColumns._labelStrut,
                  style: _SummaryColumns._labelStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.total});

  /// Records in the selected month, or null while unknown.
  final int? total;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            'Daftar Kehadiran',
            style: TextStyle(
              color: _heading,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (total != null) ...[
          const SizedBox(width: 8),
          Text(
            '$total data',
            style: const TextStyle(color: _bodyMuted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

/// The loaded records in one shared white surface, separated by thin dividers.
/// A month holds at most ~23 working days, so building them in one column is
/// cheap; further pages still load on scroll.
class _HistoryGroup extends StatelessWidget {
  const _HistoryGroup({required this.records});

  final List<AttendanceModel> records;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: _divider,
              ),
            _HistoryRow(record: records[i]),
          ],
        ],
      ),
    );
  }
}

/// One record: date number beside the weekday, then check-in and check-out on
/// the same line. At large text sizes the times wrap below rather than
/// overflow.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});

  final AttendanceModel record;

  static const _dayStyle = TextStyle(
    color: _heading,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const _weekdayStyle = TextStyle(
    color: _bodyMuted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const _statusStyle = TextStyle(
    color: _bodyMuted,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final text = attendanceHistoryRowText(record);
    final isLate = record.status == 'late';

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  // Two-digit width, so weekdays line up across rows.
                  constraints: BoxConstraints(
                    minWidth: _textWidth(context, '00', _dayStyle),
                  ),
                  child: Text(text.day, style: _dayStyle),
                ),
                const SizedBox(width: 10),
                Flexible(child: Text(text.weekday, style: _weekdayStyle)),
              ],
            ),
            if (text.statusLabel case final label?)
              Text(label, style: _statusStyle)
            else
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  _TimeCell(
                    label: 'In',
                    semanticsLabel: 'Check In',
                    time: text.checkIn!,
                    color: isLate && record.checkInTime != null
                        ? _lateTime
                        : _heading,
                    semanticsSuffix: isLate ? ', terlambat' : '',
                  ),
                  _TimeCell(
                    label: 'Out',
                    semanticsLabel: 'Check Out',
                    time: text.checkOut!,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.label,
    required this.semanticsLabel,
    required this.time,
    this.color = _heading,
    this.semanticsSuffix = '',
  });

  /// Short visible label ("In" / "Out", as in the dashboard's Check In / Out).
  final String label;

  /// Spoken label for [label].
  final String semanticsLabel;
  final String time;
  final Color color;
  final String semanticsSuffix;

  static const _labelStyle = TextStyle(
    color: _bodyMuted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const _timeStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, semanticsLabel: semanticsLabel, style: _labelStyle),
        const SizedBox(width: 6),
        ConstrainedBox(
          // Same width for every time (and the placeholder), so the columns
          // stay aligned from row to row.
          constraints: BoxConstraints(
            minWidth: _textWidth(context, '00:00', _timeStyle),
          ),
          child: Text(
            time,
            semanticsLabel: time == attendanceMissingTime
                ? 'belum tercatat'
                : '$time$semanticsSuffix',
            style: _timeStyle.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state, required this.onRetry});

  final AttendanceHistoryState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.loadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const Text(
              'Gagal memuat data berikutnya.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _bodyMuted, fontSize: 13),
            ),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Tidak ada data lagi',
            style: TextStyle(color: _bodyMuted, fontSize: 12),
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.month});

  final String month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.event_note_outlined, size: 48, color: _bodyMuted),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat presensi pada ${formatAttendanceMonth(month)}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _bodyMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for choosing a month within [first]..[last] (`yyyy-MM`).
/// Pops with the chosen month key, or null when dismissed.
class _MonthPickerSheet extends StatefulWidget {
  const _MonthPickerSheet({
    required this.selected,
    required this.first,
    required this.last,
  });

  final String selected;
  final String first;
  final String last;

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  static const _gap = 8.0;
  static const _labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  late int _year = parseAttendanceMonth(widget.selected)!.year;

  @override
  Widget build(BuildContext context) {
    final firstYear = parseAttendanceMonth(widget.first)!.year;
    final lastYear = parseAttendanceMonth(widget.last)!.year;

    // Short labels ("Jan" .. "Des"); the full name is the semantics label.
    final widestLabel = [
      for (var m = 1; m <= 12; m++)
        _textWidth(context, indoMonthName(m).substring(0, 3), _labelStyle),
    ].reduce(math.max);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih Bulan',
              style: TextStyle(
                color: _heading,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Tahun sebelumnya',
                  onPressed: _year > firstYear
                      ? () => setState(() => _year--)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    '$_year',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _heading,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tahun berikutnya',
                  onPressed: _year < lastYear
                      ? () => setState(() => _year++)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                // Button content needs the label plus its horizontal padding.
                final columns = [4, 3, 2].firstWhere(
                  (count) =>
                      (constraints.maxWidth - _gap * (count - 1)) / count >=
                      widestLabel + 24,
                  orElse: () => 1,
                );
                final cellWidth =
                    (constraints.maxWidth - _gap * (columns - 1)) / columns;

                return Wrap(
                  spacing: _gap,
                  runSpacing: _gap,
                  children: [
                    for (var m = 1; m <= 12; m++)
                      SizedBox(width: cellWidth, child: _monthButton(m)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthButton(int month) {
    final key = attendanceMonthKeyOf(_year, month);
    // `yyyy-MM` keys order chronologically as plain strings.
    final enabled =
        key.compareTo(widget.first) >= 0 && key.compareTo(widget.last) <= 0;
    final onPressed = enabled ? () => Navigator.of(context).pop(key) : null;
    final label = Text(
      indoMonthName(month).substring(0, 3),
      semanticsLabel: '${indoMonthName(month)} $_year',
      style: _labelStyle,
    );
    const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    if (key == widget.selected) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(padding: padding),
        child: label,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(padding: padding),
      child: label,
    );
  }
}
