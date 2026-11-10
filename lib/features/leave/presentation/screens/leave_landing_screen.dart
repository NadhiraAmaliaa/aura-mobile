import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';

// Heading, body and page tokens reused verbatim from
// attendance_dashboard_screen.dart (itself taken from Home); the pastel card
// colours follow the approved Izin & Sakit reference design. Kept local until
// a shared AURA palette exists.
const _heading = Color(0xFF123F69);
const _bodyMuted = Color(0xFF58636A);
const _navy = Color(0xFF194875);
const _surfaceShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);

// Zero letter spacing overrides the inherited M3 body tracking (0.25), as on
// Home, so short phrases do not spill onto an extra line in narrow cards.
const _cardTitleStyle = TextStyle(
  color: _heading,
  fontSize: 15,
  fontWeight: FontWeight.w700,
  height: 1.25,
);
const _cardDescriptionStyle = TextStyle(
  color: _bodyMuted,
  fontSize: 12,
  height: 1.35,
  letterSpacing: 0,
);

/// Page gutter and content width, matching Home and the dashboard.
double _gutter(double screenWidth) => screenWidth < 360 ? 16 : 18;
const _maxContentWidth = 680.0;

/// Same breakpoint as `HomeLayout.largeText` (body text measured at 14sp):
/// side-by-side compositions stack.
bool _largeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14 > 1.35;

/// Size of [text] rendered in [style] at the current text scale, wrapped at
/// [maxWidth] — what a `Text` with the same style renders here.
Size _textSize(
  BuildContext context,
  String text,
  TextStyle style, {
  double maxWidth = double.infinity,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: DefaultTextStyle.of(context).style.merge(style),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: maxWidth);
  try {
    return painter.size;
  } finally {
    painter.dispose();
  }
}

/// Entry point for the leave feature. Presents the intern's available leave
/// actions as cards.
///
/// The submission card ("Pengajuan Izin / Sakit") leads, followed by the two
/// read destinations (pending list and history), the isolated "Surat Pulang
/// Cepat" letter utility and a static reminder. Every card only pushes its
/// existing route; the page holds no state of its own.
class LeaveLandingScreen extends StatelessWidget {
  const LeaveLandingScreen({super.key});

  // The supplied design is light; same local palette as the dashboard.
  static final _theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF174B76),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F8F8),
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Centres the content at Home's max width on tablets.
    final horizontal = math.max(_gutter(width), (width - _maxContentWidth) / 2);

    return Theme(
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
            title: const Text('Izin & Sakit'),
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
          body: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
            children: [
              _SubmitCard(
                onTap: () => context.pushNamed(RouteNames.leaveSubmit),
              ),
              const SizedBox(height: 24),
              // Section heading styled as Home's "Menu Utama".
              const Row(
                children: [
                  Icon(Icons.eco_rounded, size: 21, color: Color(0xFF5791A8)),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Pantau Pengajuan',
                      style: TextStyle(
                        color: _heading,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatusCards(
                onPending: () => context.pushNamed(RouteNames.leavePending),
                onHistory: () => context.pushNamed(RouteNames.leaveHistory),
              ),
              const SizedBox(height: 16),
              _LetterCard(
                onTap: () => context.pushNamed(RouteNames.leaveSurat),
              ),
              const SizedBox(height: 16),
              const _NoteCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded, tappable card shared by the page's cards: a pastel fill with an
/// optional [wave] along the bottom edge, a thin white rim and a soft shadow.
///
/// As on Home's menu cards, the whole surface is one button whose semantics
/// read [label]. The fill is painted below a transparent [Material], so press
/// feedback stays visible over the wave.
class _CardSurface extends StatelessWidget {
  const _CardSurface({
    required this.label,
    required this.onTap,
    required this.accent,
    required this.child,
    this.color,
    this.gradient,
    this.wave,
    this.radius = 22,
    this.shadow = _surfaceShadow,
  });

  final String label;
  final VoidCallback onTap;

  /// Tints the press feedback so it reads on the pastel fill.
  final Color accent;
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final _WavePainter? wave;
  final double radius;
  final BoxShadow shadow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Semantics(
      button: true,
      onTap: onTap,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [shadow],
        ),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              // The content sizes the card; the fill follows it.
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color, gradient: gradient),
                    child: wave == null ? null : CustomPaint(painter: wave),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: accent.withValues(alpha: 0.12),
                    highlightColor: accent.withValues(alpha: 0.08),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft pastel swoosh along a card's bottom edge, as in the reference. Kept to
/// a shallow band behind the content so it never competes with the text.
class _WavePainter extends CustomPainter {
  const _WavePainter({required this.color, this.rising = false});

  final Color color;

  /// A short accent rising into the bottom-right corner, instead of a thin
  /// band along the full width.
  final bool rising;

  /// How high the rising accent climbs into the corner.
  static const _depth = 30.0;

  /// Thickness of the band at both ends. A fixed depth keeps it hugging the
  /// bottom edge however tall the card grows.
  static const _bandDepth = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final bottom = size.height;
    final top = bottom - _depth;
    final path = rising
        ? (Path()
            ..moveTo(width * 0.4, bottom)
            ..cubicTo(
              width * 0.7,
              bottom,
              width * 0.82,
              top + _depth * 0.35,
              width,
              top,
            )
            ..lineTo(width, bottom)
            ..close())
        // Long, gentle S: a slight crest (~1.15x the depth) at 15% of the
        // width, a dip to under half the depth at 70%, back up at the corner.
        : (Path()
            ..moveTo(0, bottom - _bandDepth)
            ..cubicTo(
              width * 0.35,
              bottom - _bandDepth * 1.65,
              width * 0.6,
              bottom + _bandDepth * 0.5,
              width,
              bottom - _bandDepth,
            )
            ..lineTo(width, bottom)
            ..lineTo(0, bottom)
            ..close());
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.rising != rising;
}

/// Thin vertical rule separating a card's icon or illustration from its copy.
class _CardDivider extends StatelessWidget {
  const _CardDivider({required this.color, this.height = 40});

  /// Horizontal room taken by the rule and its margins.
  static const space = 29.0;

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: color,
    );
  }
}

/// Rounded-square icon container used by the status and letter cards.
class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.tint,
    required this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color tint;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: size * 0.55, color: color),
      ),
    );
  }
}

/// Highlighted submission entry: illustration, rule and copy side by side on
/// a soft blue card, as in the reference. The illustration moves above the
/// copy when the copy column would be too narrow for the title or the pill
/// (small phones, large text).
class _SubmitCard extends StatelessWidget {
  const _SubmitCard({required this.onTap});

  final VoidCallback onTap;

  static const _title = 'Pengajuan\nIzin / Sakit';
  static const _action = 'Buat Pengajuan';

  static const _titleStyle = TextStyle(
    color: _heading,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const _actionStyle = TextStyle(
    color: _heading,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Pill padding on each side of the action label.
  static const _actionPadding = 18.0;

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      label: 'Pengajuan Izin / Sakit. $_action',
      onTap: onTap,
      accent: _navy,
      radius: 24,
      // Barely-there diagonal shift between two soft blues.
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8F1FC), Color(0xFFD5E5F9)],
      ),
      shadow: const BoxShadow(
        color: Color(0x142C6898),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
      child: Padding(
        // The illustration carries its own transparent margin on the left.
        padding: const EdgeInsets.fromLTRB(10, 16, 18, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final illustrationWidth = (constraints.maxWidth * 0.34).clamp(
              88.0,
              136.0,
            );
            final copyWidth =
                constraints.maxWidth - illustrationWidth - _CardDivider.space;
            final copyNeeds = math.max(
              _textSize(context, _action, _actionStyle).width +
                  _actionPadding * 2,
              // Widest line of the two-line title.
              _textSize(context, _title, _titleStyle).width,
            );
            const copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title, style: _titleStyle),
                SizedBox(height: 14),
                _ActionPill(),
              ],
            );

            if (_largeText(context) || copyNeeds > copyWidth) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _LeaveIllustration(
                      width: math.min(140, constraints.maxWidth * 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(padding: EdgeInsets.only(left: 8), child: copy),
                ],
              );
            }
            return Row(
              children: [
                _LeaveIllustration(width: illustrationWidth),
                _CardDivider(
                  color: const Color(0x4D7FAACB),
                  height: illustrationWidth * 0.75,
                ),
                const Expanded(child: copy),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// White "Buat Pengajuan" pill. Visual only: the whole card is the button.
class _ActionPill extends StatelessWidget {
  const _ActionPill();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: StadiumBorder(),
        shadows: [
          BoxShadow(
            color: Color(0x14224F78),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _SubmitCard._actionPadding,
          vertical: 9,
        ),
        child: Text(_SubmitCard._action, style: _SubmitCard._actionStyle),
      ),
    );
  }
}

/// The leave illustration shared with Home's "Izin" card.
///
/// The artwork covers only about three quarters of the asset; the rest is
/// transparent margin. A 6:5 cover box trims the top and bottom margin, and
/// [_scale] enlarges the painted image (layout unchanged) so the clipboard
/// fills its column as in the reference while the side margins spill
/// harmlessly into the card padding.
class _LeaveIllustration extends StatelessWidget {
  const _LeaveIllustration({required this.width});

  final double width;

  static const _scale = 1.3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Transform.scale(
          scale: _scale,
          child: Image.asset(
            'assets/images/home/menu_leave.png',
            fit: BoxFit.cover,
            cacheWidth:
                (width * _scale * MediaQuery.devicePixelRatioOf(context))
                    .ceil()
                    .clamp(1, 600),
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

typedef _StatusItem = ({
  String title,
  IconData icon,
  Color background,
  Color wave,
  Color iconTint,
  Color iconColor,
  VoidCallback onTap,
});

/// "Menunggu Persetujuan" (soft yellow) and "Riwayat Pengajuan" (soft green)
/// as two equal pastel cards side by side, as in the reference.
///
/// Both cards reserve the taller title, measured at the current width and
/// text scale, so they line up without an intrinsic-height pass. The icon
/// sits beside the title when the longest word still fits next to it and
/// above it otherwise. When a word would not fit even a half-width card, or
/// the text is large, the cards stack at full width.
class _StatusCards extends StatelessWidget {
  const _StatusCards({required this.onPending, required this.onHistory});

  final VoidCallback onPending;
  final VoidCallback onHistory;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final List<_StatusItem> items = [
      (
        title: 'Menunggu Persetujuan',
        icon: Icons.hourglass_bottom_rounded,
        background: const Color(0xFFFFF8EA),
        wave: const Color(0xFFFFE8B8),
        iconTint: const Color(0xFFFFEBC4),
        iconColor: const Color(0xFF97610B),
        onTap: onPending,
      ),
      (
        title: 'Riwayat Pengajuan',
        icon: Icons.history_rounded,
        background: const Color(0xFFF1F8EE),
        wave: const Color(0xFFD7ECCF),
        iconTint: const Color(0xFFDDEFD6),
        iconColor: const Color(0xFF2B713D),
        onTap: onHistory,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = _StatusCard.padding * 2;
        final widestWord = _widestWord(context, items);
        final pairWidth = (constraints.maxWidth - _gap) / 2;
        final paired =
            !_largeText(context) && widestWord <= pairWidth - padding;
        final inner = (paired ? pairWidth : constraints.maxWidth) - padding;
        final besideWidth = inner - _StatusCard.iconSize - _StatusCard.iconGap;
        final iconBeside = widestWord <= besideWidth;
        final titleWidth = iconBeside ? besideWidth : inner;
        final titleHeight = items
            .map(
              (item) => _textSize(
                context,
                item.title,
                _StatusCard.titleStyle,
                maxWidth: titleWidth,
              ).height,
            )
            .reduce(math.max)
            .ceilToDouble();

        final cards = [
          for (final item in items)
            _StatusCard(
              item: item,
              iconBeside: iconBeside,
              titleHeight: titleHeight,
            ),
        ];
        if (!paired) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cards[0],
              const SizedBox(height: _gap),
              cards[1],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: _gap),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }

  /// Widest single word of either title, so a card's layout never forces a
  /// word to split across lines.
  static double _widestWord(BuildContext context, List<_StatusItem> items) {
    var widest = 0.0;
    for (final item in items) {
      for (final word in item.title.split(' ')) {
        widest = math.max(
          widest,
          _textSize(context, word, _StatusCard.titleStyle).width,
        );
      }
    }
    return widest.ceilToDouble();
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.item,
    required this.iconBeside,
    required this.titleHeight,
  });

  final _StatusItem item;
  final bool iconBeside;
  final double titleHeight;

  static const padding = 14.0;
  static const iconSize = 40.0;
  static const iconGap = 8.0;

  /// A step below the other card titles, so two lines sit comfortably beside
  /// the icon in a short card.
  static const titleStyle = TextStyle(
    color: _heading,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );

  /// Bottom inset leaving breathing room above the wave band.
  static const _waveInset = 30.0;

  @override
  Widget build(BuildContext context) {
    final icon = _IconBadge(
      icon: item.icon,
      tint: item.iconTint,
      color: item.iconColor,
      size: iconSize,
    );
    // Both cards reserve the same title height. Beside the icon a shorter
    // title is centred on it; below the icon it starts at the top, level with
    // its sibling's.
    final title = ConstrainedBox(
      constraints: BoxConstraints(minHeight: titleHeight),
      child: Align(
        alignment: iconBeside
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.topStart,
        child: Text(item.title, style: titleStyle),
      ),
    );

    return _CardSurface(
      label: item.title,
      onTap: item.onTap,
      accent: item.iconColor,
      color: item.background,
      wave: _WavePainter(color: item.wave),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          padding,
          padding,
          padding,
          _waveInset,
        ),
        child: iconBeside
            ? Row(
                children: [
                  icon,
                  const SizedBox(width: iconGap),
                  Expanded(child: title),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [icon, const SizedBox(height: 10), title],
              ),
      ),
    );
  }
}

/// "Surat Pulang Cepat" utility: a light horizontal card with a lavender icon
/// and a short lavender accent in its bottom-right corner.
class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.onTap});

  final VoidCallback onTap;

  static const _title = 'Surat Pulang Cepat';

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      label: _title,
      onTap: onTap,
      accent: _navy,
      color: Colors.white,
      wave: const _WavePainter(color: Color(0xFFE8E5FA), rising: true),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          children: [
            _IconBadge(
              icon: Icons.description_outlined,
              tint: Color(0xFFE6E5FB),
              color: _navy,
              size: 48,
            ),
            _CardDivider(color: Color(0xFFE1E6EE)),
            Expanded(child: Text(_title, style: _cardTitleStyle)),
            SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 28, color: _navy),
          ],
        ),
      ),
    );
  }
}

/// Static reminder closing the page. Informational only, not a button.
class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F1FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_rounded, size: 36, color: Color(0xFF5B8ED0)),
            _CardDivider(color: Color(0x335B8ED0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catatan Penting', style: _cardTitleStyle),
                  SizedBox(height: 3),
                  Text(
                    'Pastikan data dan alasan pengajuan sesuai dengan '
                    'ketentuan yang berlaku.',
                    style: _cardDescriptionStyle,
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
