import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/attendance_models.dart';

// Presensi history palette. Divider and shadow are the AURA tokens used on
// Home, Dashboard and History; the badge and table colours come from the
// approved Presensi reference design. Kept local until a shared AURA palette
// exists.
const _navy = Color(0xFF0B2559);
const _bodyMuted = Color(0xFF58636A);
const _divider = Color(0xFFE6ECF1);
const _surfaceShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);
const _sectionBadge = Color(0xFF6AB3E9);
const _tableHeader = Color(0xFF194875);
const _checkInStatusBackground = Color(0xFFDDEEDC);
const _checkInStatusText = Color(0xFF1E6B3F);
const _checkOutStatusBackground = Color(0xFFCEE4FC);

/// "Histori absensi hari ini" heading: a light-blue clock badge and the title.
class TodayHistoryTitle extends StatelessWidget {
  const TodayHistoryTitle({super.key});

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
class TodayHistoryTable extends StatelessWidget {
  const TodayHistoryTable({
    super.key,
    required this.attendance,
    required this.loading,
  });

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
