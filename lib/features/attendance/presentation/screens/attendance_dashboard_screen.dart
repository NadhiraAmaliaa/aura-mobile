import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../data/models/attendance_models.dart';
import '../attendance_day.dart';
import '../providers/attendance_dashboard_notifier.dart';
import '../providers/trusted_attendance_date_provider.dart';
import '../widgets/attendance_config_refresher.dart';

// Home palette, reused verbatim from home_screen.dart, home_overview_card.dart
// and home_menu_grid.dart. Kept local until a shared AURA palette exists.
const _heading = Color(0xFF123F69);
const _bodyMuted = Color(0xFF58636A);
const _navy = Color(0xFF194875);
const _onCardMuted = Color(0xFFDCEAF6);
const _onCardDivider = Color(0x337FAACB);
const _onCardNotice = Color(0xFFFFDEA0);
const _checkInTint = Color(0xFFEAF5E7);
const _checkInGreen = Color(0xFF367D49);
const _cardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF2C6898), Color(0xFF194875)],
);
const _cardShadow = BoxShadow(
  color: Color(0x25224F78),
  blurRadius: 18,
  offset: Offset(0, 9),
);
const _surfaceShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);

/// Page gutter and content width, matching Home.
double _gutter(double screenWidth) => screenWidth < 360 ? 16 : 18;
const _maxContentWidth = 680.0;

/// Effective body text scale, measured at 14sp like `HomeLayout.textFactor`.
double _textFactor(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14;

/// Same breakpoint as `HomeLayout.largeText`: side-by-side compositions stack.
bool _largeText(BuildContext context) => _textFactor(context) > 1.35;

/// Attendance landing / dashboard.
///
/// Read-only: shows today's working hours and check-in/out status plus the
/// monthly recap, and links to the check-in flow and the history.
class AttendanceDashboardScreen extends ConsumerWidget {
  const AttendanceDashboardScreen({super.key});

  // The supplied design is light; same local palette as Home.
  static final _theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF174B76),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F8F8),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(attendanceDashboardProvider);

    return AttendanceConfigRefresher(
      child: Theme(
        data: _theme,
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
              title: const Text('Absensi'),
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
          ),
        ),
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
    final width = MediaQuery.sizeOf(context).width;
    // Centres the content at Home's max width on tablets.
    final horizontal = math.max(_gutter(width), (width - _maxContentWidth) / 2);

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
      children: [
        _TodayCard(today: data.today),
        const SizedBox(height: 24),
        const Text(
          'Ringkasan Bulan Ini',
          style: TextStyle(
            color: _heading,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        _SummaryGrid(summary: data.summary),
        const SizedBox(height: 16),
        _HistoryCard(
          onTap: () => context.pushNamed(RouteNames.attendanceHistory),
        ),
      ],
    );
  }
}

class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.today});

  final AttendanceTodayModel today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A snapshot cached on an earlier day is not today's record: show the
    // trusted current date with empty hours and no attendance or leave rather
    // than the old day's values.
    final currentDate = ref.watch(trustedAttendanceDateProvider).value;
    final otherDay = isOtherAttendanceDay(today.date, currentDate);
    final date = otherDay ? currentDate! : today.date;
    final attendance = otherDay ? null : today.attendance;
    final leave = otherDay ? null : today.leave;
    final workHours = today.workHours;

    // Working hours are per weekday: another day's hours (or its "Hari libur")
    // are not today's.
    final hoursLabel = otherDay
        ? '--:-- - --:--'
        : (workHours.start != null && workHours.end != null)
        ? '${workHours.start} - ${workHours.end}'
        : 'Hari libur';

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: _cardGradient,
        boxShadow: [_cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.white,
            fontSize: 13,
            height: 1.3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WorkHoursHeader(
                hoursLabel: hoursLabel,
                date: formatIndoDate(date),
                // Leave stays visible as plain text when there is no
                // attendance record, as the former chip did.
                leaveLabel: attendance == null && leave != null
                    ? 'Sedang ${leave.typeLabel}'
                    : null,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: _onCardDivider),
              ),
              _TimeRow(
                checkIn: attendance?.checkInTime ?? '--:--',
                checkOut: attendance?.checkOutTime ?? '--:--',
              ),
              const SizedBox(height: 16),
              _PresenceButton(
                onPressed: () =>
                    context.pushNamed(RouteNames.attendancePresence),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkHoursHeader extends StatelessWidget {
  const _WorkHoursHeader({
    required this.hoursLabel,
    required this.date,
    required this.leaveLabel,
  });

  final String hoursLabel;
  final String date;
  final String? leaveLabel;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jam Kerja Hari Ini', style: TextStyle(color: _onCardMuted)),
        const SizedBox(height: 2),
        Text(
          hoursLabel,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(date, style: const TextStyle(color: _onCardMuted)),
        if (leaveLabel != null) ...[
          const SizedBox(height: 6),
          Text(
            leaveLabel!,
            style: const TextStyle(
              color: _onCardNotice,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
    const badge = _CalendarBadge();
    if (_largeText(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [badge, const SizedBox(height: 12), details],
      );
    }
    return Row(
      children: [
        badge,
        const SizedBox(width: 14),
        Expanded(child: details),
      ],
    );
  }
}

class _CalendarBadge extends StatelessWidget {
  const _CalendarBadge();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SizedBox.square(
        dimension: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(Icons.calendar_month_outlined, size: 26, color: _navy),
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.checkIn, required this.checkOut});

  final String checkIn;
  final String checkOut;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final checkInColumn = _TimeColumn(label: 'Check In', time: checkIn);
        final checkOutColumn = _TimeColumn(label: 'Check Out', time: checkOut);
        if (constraints.maxWidth < 260 || _largeText(context)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              checkInColumn,
              const SizedBox(height: 12),
              checkOutColumn,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: checkInColumn),
            Container(
              width: 1,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: _onCardDivider,
            ),
            Expanded(child: checkOutColumn),
          ],
        );
      },
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: _onCardMuted)),
      ],
    );
  }
}

/// White pill linking to the check-in flow. Navigation happens on tap, never
/// after an animation; the fingerprint only reflects the press while held.
class _PresenceButton extends StatefulWidget {
  const _PresenceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_PresenceButton> createState() => _PresenceButtonState();
}

class _PresenceButtonState extends State<_PresenceButton> {
  // A notifier (not setState) so a press rebuilds only the fingerprint.
  final _pressed = ValueNotifier(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onPressed,
        onHighlightChanged: (value) => _pressed.value = value,
        customBorder: const StadiumBorder(),
        // Green-tinted feedback (as Home's menu cards tint theirs) instead of
        // the theme's grey highlight, which greys out the white pill.
        splashColor: _checkInGreen.withValues(alpha: 0.12),
        highlightColor: _checkInGreen.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 46,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _checkInTint,
                  ),
                  child: _FingerprintIcon(pressed: _pressed),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Presensi Magang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _heading,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const ExcludeSemantics(
                child: SizedBox.square(
                  dimension: 36,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _navy,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative fingerprint: pulses twice when first shown, with a short rest in
/// between, then stops. Each pulse zooms the glyph (1.0 → 1.25 → 1.0) while a
/// concentrated green glow brightens, expands slightly and fades with it; one
/// controller drives both, so they stay in sync.
///
/// The "already played" flag lives in the route's [PageStorage], so pull to
/// refresh (which swaps the content for the loader and back) or any rebuild
/// does not replay it. The ticker follows [TickerMode], so the pulse is muted
/// while another route covers the dashboard; it is skipped entirely when the
/// platform asks to reduce motion.
class _FingerprintIcon extends StatefulWidget {
  const _FingerprintIcon({required this.pressed});

  final ValueNotifier<bool> pressed;

  @override
  State<_FingerprintIcon> createState() => _FingerprintIconState();
}

class _FingerprintIconState extends State<_FingerprintIcon>
    with SingleTickerProviderStateMixin {
  static const _pulsePlayedId = 'attendance-dashboard-fingerprint-pulse';

  /// Glow diameter at rest. At its peak expansion (×1.2) it stays inside the
  /// 46dp circle, just around the zoomed glyph (26 × 1.25 ≈ 33dp).
  static const _glowSize = 36.0;

  // Timeline in ms: pulse (375 in + 375 out), 250 rest, pulse again.
  static const _halfPulseMs = 375.0;
  static const _restMs = 250.0;

  static final _rise = Tween(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.easeInOutSine));
  static final _fall = Tween(
    begin: 1.0,
    end: 0.0,
  ).chain(CurveTween(curve: Curves.easeInOutSine));

  /// Pulse intensity: 0 at rest, 1 at the peak of each of the two pulses.
  /// Weights are the segment durations, so the rest is exactly [_restMs].
  static final _pulseShape = TweenSequence<double>([
    TweenSequenceItem(tween: _rise, weight: _halfPulseMs),
    TweenSequenceItem(tween: _fall, weight: _halfPulseMs),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: _restMs),
    TweenSequenceItem(tween: _rise, weight: _halfPulseMs),
    TweenSequenceItem(tween: _fall, weight: _halfPulseMs),
  ]);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_halfPulseMs * 4 + _restMs).round()),
  );
  late final Animation<double> _intensity = _pulseShape.animate(_pulse);
  late final Animation<double> _glyphScale = Tween(
    begin: 1.0,
    end: 1.25,
  ).animate(_intensity);
  late final Animation<double> _glowScale = Tween(
    begin: 0.85,
    end: 1.2,
  ).animate(_intensity);

  bool _pulseHandled = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      // Settle at rest, even if the setting changes mid-pulse.
      _pulse.value = 0;
      _pulseHandled = true;
      return;
    }
    if (_pulseHandled) return;
    _pulseHandled = true;

    final storage = PageStorage.maybeOf(context);
    if (storage?.readState(context, identifier: _pulsePlayedId) == true) {
      return;
    }
    storage?.writeState(context, true, identifier: _pulsePlayedId);
    _pulse.forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only the glow and the glyph animate; the boundary keeps each frame's
    // repaint to them. The glow is a small radial gradient (no blur): bright
    // behind the glyph's lines, fading out just past its edge. FadeTransition
    // skips painting it at rest, and during the pause neither the transform
    // nor the opacity changes, so those frames repaint nothing.
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: _intensity,
            child: ScaleTransition(
              scale: _glowScale,
              child: const SizedBox.square(
                dimension: _glowSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xE68EDB9C),
                        Color(0x8C8EDB9C),
                        Color(0x008EDB9C),
                      ],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: _glyphScale,
            child: ValueListenableBuilder<bool>(
              valueListenable: widget.pressed,
              builder: (context, pressed, child) => AnimatedScale(
                scale: pressed ? 0.9 : 1,
                duration: _reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: child,
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 26,
                color: _checkInGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _SummaryItem = ({
  String label,
  int value,
  Color background,
  Color valueColor,
  Color labelColor,
});

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final MonthlySummaryModel summary;

  static const _gap = 10.0;

  /// Horizontal tile padding, roomiest first: the grid tightens the padding
  /// before it drops a column.
  static const _paddings = [14.0, 10.0];
  static const _verticalPadding = 14.0;
  static const _valueLabelGap = 4.0;
  static const _radius = BorderRadius.all(Radius.circular(16));

  static const _valueStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static const _labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0,
  );

  // Forced struts (as in Home's menu grid) make every line exactly
  // fontSize × height tall, so the reserved min height matches the content.
  static const _valueStrut = StrutStyle(
    fontSize: 26,
    height: 1.15,
    forceStrutHeight: true,
  );
  static const _labelStrut = StrutStyle(
    fontSize: 14,
    height: 1.25,
    forceStrutHeight: true,
  );

  @override
  Widget build(BuildContext context) {
    final List<_SummaryItem> items = [
      (
        label: 'Hadir',
        value: summary.hadir,
        background: const Color(0xFFE6F4EA),
        valueColor: const Color(0xFF1E6B3F),
        labelColor: const Color(0xFF2F7A4C),
      ),
      (
        label: 'Terlambat',
        value: summary.terlambat,
        background: const Color(0xFFFFF1E2),
        valueColor: const Color(0xFFB06A0C),
        labelColor: const Color(0xFF5C4325),
      ),
      (
        label: 'Izin',
        value: summary.izin,
        background: const Color(0xFFF1EBFB),
        valueColor: const Color(0xFF7E3FC4),
        labelColor: const Color(0xFF7A4BB8),
      ),
      (
        label: 'Sakit',
        value: summary.sakit,
        background: const Color(0xFFFCE8E9),
        valueColor: const Color(0xFFB2262F),
        labelColor: const Color(0xFFB2262F),
      ),
      (
        label: 'Dinas Luar',
        value: summary.dinas,
        background: const Color(0xFFE7F0FC),
        valueColor: const Color(0xFF1D4F8C),
        labelColor: const Color(0xFF235C9E),
      ),
      (
        label: 'Tidak Absen',
        value: summary.tidakAbsen,
        background: const Color(0xFFEEF0F3),
        valueColor: const Color(0xFF3E4855),
        labelColor: const Color(0xFF3E4855),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _measure(context, items);
        final (:columns, :padding) = _fit(
          constraints.maxWidth,
          metrics.widestWord,
        );
        final tileWidth =
            (constraints.maxWidth - _gap * (columns - 1)) / columns;
        // Every word fits, so a label needs two lines at most; reserve the
        // second line for all tiles only when some label actually wraps.
        final labelHeight = metrics.widestLabel <= tileWidth - padding * 2
            ? metrics.oneLineLabel
            : metrics.twoLineLabel;
        final minHeight =
            _verticalPadding * 2 +
            metrics.valueHeight +
            _valueLabelGap +
            labelHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var start = 0; start < items.length; start += columns) ...[
              if (start > 0) const SizedBox(height: _gap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = start; i < start + columns; i++) ...[
                    if (i > start) const SizedBox(width: _gap),
                    Expanded(
                      child: i < items.length
                          ? _SummaryTile(
                              item: items[i],
                              padding: padding,
                              minHeight: minHeight,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  /// Label widths (widest single word, widest whole label) and the rendered
  /// heights of the value and of one- and two-line labels, measured with the
  /// tiles' own styles at the current text scale. The layout follows the real
  /// font, and the reserved height matches what the tiles render, rounding
  /// included.
  static ({
    double widestWord,
    double widestLabel,
    double valueHeight,
    double oneLineLabel,
    double twoLineLabel,
  })
  _measure(BuildContext context, List<_SummaryItem> items) {
    final base = DefaultTextStyle.of(context).style;
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );
    Size layout(String text, TextStyle style, StrutStyle strut) {
      painter
        ..text = TextSpan(text: text, style: base.merge(style))
        ..strutStyle = strut
        ..layout();
      return painter.size;
    }

    try {
      var widestWord = 0.0;
      var widestLabel = 0.0;
      for (final item in items) {
        widestLabel = math.max(
          widestLabel,
          layout(item.label, _labelStyle, _labelStrut).width,
        );
        for (final word in item.label.split(' ')) {
          widestWord = math.max(
            widestWord,
            layout(word, _labelStyle, _labelStrut).width,
          );
        }
      }
      return (
        widestWord: widestWord.ceilToDouble(),
        widestLabel: widestLabel.ceilToDouble(),
        valueHeight: layout('0', _valueStyle, _valueStrut).height,
        oneLineLabel: layout('A', _labelStyle, _labelStrut).height,
        twoLineLabel: layout('A\nA', _labelStyle, _labelStrut).height,
      );
    } finally {
      painter.dispose();
    }
  }

  /// The most columns whose tiles fit the widest label word on one line, so
  /// no word is ever split. A single column is a last resort for extreme
  /// accessibility text on narrow screens.
  static ({int columns, double padding}) _fit(double width, double wordWidth) {
    for (final columns in const [3, 2]) {
      final tileWidth = (width - _gap * (columns - 1)) / columns;
      for (final padding in _paddings) {
        if (tileWidth - padding * 2 >= wordWidth) {
          return (columns: columns, padding: padding);
        }
      }
    }
    return (columns: 1, padding: _paddings.first);
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.item,
    required this.padding,
    required this.minHeight,
  });

  final _SummaryItem item;
  final double padding;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${item.label}: ${item.value}',
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: _SummaryGrid._verticalPadding,
        ),
        decoration: BoxDecoration(
          color: item.background,
          borderRadius: _SummaryGrid._radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${item.value}',
              strutStyle: _SummaryGrid._valueStrut,
              style: _SummaryGrid._valueStyle.copyWith(color: item.valueColor),
            ),
            const SizedBox(height: _SummaryGrid._valueLabelGap),
            Text(
              item.label,
              strutStyle: _SummaryGrid._labelStrut,
              style: _SummaryGrid._labelStyle.copyWith(color: item.labelColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(22));
    return DecoratedBox(
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
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD8E7FC),
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        size: 22,
                        color: Color(0xFF145F9B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Presensi',
                        style: TextStyle(
                          color: _heading,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Lihat detail kehadiran dan rekap lengkap',
                        style: TextStyle(
                          color: _bodyMuted,
                          fontSize: 12,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: _bodyMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
