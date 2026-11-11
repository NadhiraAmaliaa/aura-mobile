import 'package:flutter/material.dart';

import '../../../../shared/widgets/aura_form.dart';
import '../../data/models/leave_models.dart';
import 'leave_status_chip.dart';

// The card surface of the leave landing page's cards.
const _cardRadius = 20.0;
const _cardShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);

/// A white, rounded, softly shadowed leave card around [child]. The surface
/// is a [Material], so an [InkWell] child splashes on it.
class LeaveCardSurface extends StatelessWidget {
  const LeaveCardSurface({required this.child, super.key});

  final Widget child;

  static final borderRadius = BorderRadius.circular(_cardRadius);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [_cardShadow],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

/// Colours and icon of a request type: soft pink for sakit, pastel green for
/// izin, the AURA blue for anything else.
class LeaveTypeAccent {
  const LeaveTypeAccent({
    required this.tint,
    required this.foreground,
    this.asset,
  });

  /// Behind the type icon and the day count.
  final Color tint;

  /// The day count's icon and text, dark enough to read on [tint].
  final Color foreground;

  /// The type's icon; types without one get a generic Material icon.
  final String? asset;

  static const sakit = LeaveTypeAccent(
    tint: Color(0xFFFFE5E8),
    foreground: Color(0xFFC62F3B),
    asset: 'assets/images/leave/sakit.png',
  );
  static const izin = LeaveTypeAccent(
    tint: Color(0xFFE3F4DC),
    foreground: Color(0xFF237A12),
    asset: 'assets/images/leave/izin.png',
  );
  static const other = LeaveTypeAccent(
    tint: Color(0xFFE3EEFF),
    foreground: AuraForm.navy,
  );

  static LeaveTypeAccent of(String type) => switch (type) {
    'sakit' => sakit,
    'izin' => izin,
    _ => other,
  };
}

/// The type icon on its tinted rounded square.
class LeaveTypeTile extends StatelessWidget {
  const LeaveTypeTile({
    required this.accent,
    this.size = 48,
    this.iconSize = 30,
    this.radius = 14,
    super.key,
  });

  final LeaveTypeAccent accent;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final asset = accent.asset;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.tint,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        child: Center(
          // Decorative: the type is read from the title next to it.
          child: asset != null
              ? Image.asset(
                  asset,
                  width: iconSize,
                  height: iconSize,
                  excludeFromSemantics: true,
                )
              : Icon(
                  Icons.event_note_outlined,
                  size: iconSize - 4,
                  color: accent.foreground,
                ),
        ),
      ),
    );
  }
}

/// A request's type tile with its type and number beside it and its status
/// badge: compact on the list cards, [LeaveRequestHeading.large] at the top
/// of the detail page.
///
/// The badge follows the type while both fit on one line and comes after the
/// number otherwise. When the number does not fit beside the tile either, it
/// moves under the tile, so it never breaks mid-number.
class LeaveRequestHeading extends StatelessWidget {
  const LeaveRequestHeading({required this.request, super.key})
    : _metrics = _compact;

  const LeaveRequestHeading.large({required this.request, super.key})
    : _metrics = _large;

  final LeaveRequestModel request;
  final _HeadingMetrics _metrics;

  static const _badgeGap = 8.0;

  // Zero letter spacing overrides the inherited M3 body tracking, as on Home.
  static const _compact = _HeadingMetrics(
    tileSize: 48,
    iconSize: 30,
    tileRadius: 14,
    gap: 12,
    titleStyle: TextStyle(
      color: AuraForm.heading,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: 0,
    ),
    numberStyle: TextStyle(
      color: AuraForm.bodyMuted,
      fontSize: 13,
      height: 1.3,
      letterSpacing: 0,
    ),
  );
  static const _large = _HeadingMetrics(
    tileSize: 56,
    iconSize: 34,
    tileRadius: 16,
    gap: 14,
    titleStyle: TextStyle(
      color: AuraForm.heading,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0,
    ),
    numberStyle: TextStyle(
      color: AuraForm.bodyMuted,
      fontSize: 14,
      height: 1.3,
      letterSpacing: 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _layout(context, constraints.maxWidth),
    );
  }

  Widget _layout(BuildContext context, double maxWidth) {
    final metrics = _metrics;
    final besideTile = maxWidth - metrics.tileSize - metrics.gap;
    final badge = LeaveStatusChip(
      label: request.statusLabel,
      status: request.status,
    );
    final title = Text(request.typeLabel, style: metrics.titleStyle);
    final number = Text(request.requestNumber, style: metrics.numberStyle);
    final badgeBesideTitle =
        AuraForm.textSize(
              context,
              request.typeLabel,
              metrics.titleStyle,
            ).width +
            _badgeGap +
            LeaveStatusChip.widthOf(context, request.statusLabel) <=
        besideTile;
    final numberBesideTile =
        AuraForm.textSize(
          context,
          request.requestNumber,
          metrics.numberStyle,
        ).width <=
        besideTile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: numberBesideTile
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            LeaveTypeTile(
              accent: LeaveTypeAccent.of(request.type),
              size: metrics.tileSize,
              iconSize: metrics.iconSize,
              radius: metrics.tileRadius,
            ),
            SizedBox(width: metrics.gap),
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
                    if (!badgeBesideTitle) ...[
                      const SizedBox(height: 8),
                      badge,
                    ],
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
      ],
    );
  }
}

class _HeadingMetrics {
  const _HeadingMetrics({
    required this.tileSize,
    required this.iconSize,
    required this.tileRadius,
    required this.gap,
    required this.titleStyle,
    required this.numberStyle,
  });

  final double tileSize;
  final double iconSize;
  final double tileRadius;
  final double gap;
  final TextStyle titleStyle;
  final TextStyle numberStyle;
}

/// "N hari" on the type's tint, with a small calendar icon.
class LeaveDaysPill extends StatelessWidget {
  const LeaveDaysPill({required this.days, required this.accent, super.key});

  final int days;
  final LeaveTypeAccent accent;

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
