import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'home_layout.dart';

typedef _MenuItem = ({
  String title,
  String description,
  String asset,
  Color tint,
  Color color,
  VoidCallback onTap,
});

// Zero letter spacing overrides the inherited M3 body tracking (0.25), which
// otherwise pushes short phrases onto an extra line in the narrow cards.
const _descriptionStyle = TextStyle(
  color: Color(0xFF58636A),
  fontSize: 12,
  height: 1.35,
  letterSpacing: 0,
);

/// White card rim. `Ink` insets its child by the border, so content width
/// calculations must subtract it too.
const _borderWidth = 3.0;

/// Forces every description line to the same height, so a reserved line count
/// translates into an exact, predictable block height.
const _descriptionStrut = StrutStyle(
  fontSize: 12,
  height: 1.35,
  forceStrutHeight: true,
);

class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({
    required this.onProfile,
    required this.onAttendance,
    required this.onLeave,
    super.key,
  });

  final VoidCallback onProfile;
  final VoidCallback onAttendance;
  final VoidCallback onLeave;

  static const _gap = 8.0;

  /// Narrowest card (at 1.0 text scale) that still reads well three-across;
  /// below it the menu becomes a single column of horizontal tiles.
  static const _minCardWidth = 94.0;

  static const _maxDescriptionLines = 4;

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> items = [
      (
        title: 'Profil',
        description: 'Lihat dan kelola informasi profil Anda',
        asset: 'assets/images/home/menu_profile.png',
        tint: const Color(0xFFE1EEDC),
        color: const Color(0xFF2B713D),
        onTap: onProfile,
      ),
      (
        title: 'Absensi',
        description: 'Lakukan absensi kehadiran harian',
        asset: 'assets/images/home/menu_attendance.png',
        tint: const Color(0xFFD8E7FC),
        color: const Color(0xFF145F9B),
        onTap: onAttendance,
      ),
      (
        title: 'Izin',
        description: 'Ajukan izin, sakit, atau pulang cepat',
        asset: 'assets/images/home/menu_leave.png',
        tint: const Color(0xFFFFEFD3),
        color: const Color(0xFF97610B),
        onTap: onLeave,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.eco_rounded, size: 21, color: Color(0xFF5791A8)),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'Menu Utama',
                style: TextStyle(
                  color: Color(0xFF123F69),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - _gap * 2) / 3;
            if (cardWidth < _minCardWidth * HomeLayout.textFactor(context)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, item) in items.indexed) ...[
                    if (index > 0) const SizedBox(height: _gap),
                    _MenuTile(item: item),
                  ],
                ],
              );
            }
            final lines = _descriptionLines(
              context,
              items,
              cardWidth - (_borderWidth + _MenuCard.padding) * 2,
            );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (index, item) in items.indexed) ...[
                  if (index > 0) const SizedBox(width: _gap),
                  Expanded(
                    child: _MenuCard(
                      item: item,
                      width: cardWidth,
                      descriptionLines: lines,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  /// Lines needed by the longest description at [width]. Every card reserves
  /// this many lines, so the row lines up without an intrinsic-height pass.
  static int _descriptionLines(
    BuildContext context,
    List<_MenuItem> items,
    double width,
  ) {
    final style = DefaultTextStyle.of(context).style.merge(_descriptionStyle);
    var lines = 1;
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(text: item.description, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        strutStyle: _descriptionStrut,
      )..layout(maxWidth: width);
      lines = math.max(lines, painter.computeLineMetrics().length);
      painter.dispose();
    }
    return math.min(lines, _maxDescriptionLines);
  }
}

/// Three-across card: illustration on top, text below.
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.item,
    required this.width,
    required this.descriptionLines,
  });

  final _MenuItem item;
  final double width;
  final int descriptionLines;

  static const padding = 8.0;

  @override
  Widget build(BuildContext context) {
    final lineHeight = MediaQuery.textScalerOf(context).scale(12) * 1.35;
    return _MenuSurface(
      item: item,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The illustrations carry wide transparent margins; a 3:2 cover box
          // trims only that empty space so the artwork itself reads larger.
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: _MenuImage(
                asset: item.asset,
                width: width - (_borderWidth + 4) * 2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(padding, 4, padding, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: lineHeight * descriptionLines,
                  ),
                  child: Text(
                    item.description,
                    maxLines: descriptionLines,
                    overflow: TextOverflow.ellipsis,
                    style: _descriptionStyle,
                    strutStyle: _descriptionStrut,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-column tile for narrow screens or large text.
class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItem item;

  static const _imageWidth = 76.0;

  @override
  Widget build(BuildContext context) {
    return _MenuSurface(
      item: item,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: _imageWidth,
              child: AspectRatio(
                aspectRatio: 1.2,
                child: _MenuImage(asset: item.asset, width: _imageWidth),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: item.color,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.description, style: _descriptionStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tinted, tappable card surface shared by the card and tile layouts.
class _MenuSurface extends StatelessWidget {
  const _MenuSurface({required this.item, required this.child});

  final _MenuItem item;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Semantics(
      button: true,
      onTap: item.onTap,
      label: '${item.title}. ${item.description}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x100E3555),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: _borderWidth),
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [item.tint, Color.lerp(item.tint, Colors.white, 0.75)!],
              ),
            ),
            // The whole surface is the tap target; press feedback is tinted
            // with the card's accent so it reads on the coloured gradient.
            child: InkWell(
              onTap: item.onTap,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22 - _borderWidth),
              ),
              splashColor: item.color.withValues(alpha: 0.12),
              highlightColor: item.color.withValues(alpha: 0.08),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  const _MenuImage({required this.asset, required this.width});

  final String asset;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).ceil().clamp(
        1,
        600,
      ),
      filterQuality: FilterQuality.medium,
    );
  }
}
