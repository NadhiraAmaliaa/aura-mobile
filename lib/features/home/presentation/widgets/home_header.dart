import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.name,
    required this.onLogout,
    required this.gutter,
    super.key,
  });

  final String name;
  final VoidCallback onLogout;

  /// Page gutter, so the backdrop can bleed to the screen edge.
  final double gutter;

  static const _logoAspect = 480 / 251;

  /// Source artwork is 1952×730; keep its proportions exactly.
  static const _buildingSourceWidth = 1952;
  static const _buildingAspect = _buildingSourceWidth / 730;

  /// Share of the building's height tucked under the overview card: only the
  /// lawn edge, so the trees and entrance stay visible above it.
  static const _tuckedShare = 0.14;

  /// Height of the logo row: the logout button's minimum tap target.
  static const _logoRowHeight = kMinInteractiveDimension;

  /// Share of the artwork's height above the roofline that is empty canvas
  /// (first visible row is 116 of 730). It may slide under the logo row.
  static const _emptyTopShare = 116 / 730;

  /// Clearance between the logo row and the roofline.
  static const _buildingClearance = 6.0;

  static const _cloudAsset = 'assets/images/home/cloud.png';

  /// Cloud artwork is 1774×887; keep its proportions exactly.
  static const _cloudSourceWidth = 1774;
  static const _cloudAspect = _cloudSourceWidth / 887;

  /// Centre of the visible cloud (rows 219–768 of 887) as a share of the
  /// canvas height; clouds are placed by it, not by the transparent canvas.
  static const _cloudCenterShare = (219 + 768) / 2 / 887;

  /// Light sky blue shared by the haze and the building's atmospheric tint.
  static const _sky = Color(0xFFD6E6F7);

  /// Aerial-perspective tint: mixes the artwork towards the sky and softens
  /// its saturation, so the scene recedes into the light-blue atmosphere.
  static final _atmosphere = _tint(_sky, amount: 0.3, desaturate: 0.15);

  /// Soft band over the sign panel (source pixels 1268–1648 × 188–404 of
  /// 1952×730). Its feathered edges fall on the panel's white interior, where
  /// tinted and original pixels barely differ, so no seam shows.
  static const _signColumns = LinearGradient(
    colors: [_clear, _solid, _solid, _clear],
    stops: [1268 / 1952, 1300 / 1952, 1630 / 1952, 1648 / 1952],
  );
  static const _signRows = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_clear, _solid, _solid, _clear],
    stops: [188 / 730, 204 / 730, 390 / 730, 404 / 730],
  );
  static const _clear = Color(0x00000000);
  static const _solid = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    // 0 on short screens, 1 on tall ones: taller screens get a little more
    // breathing room, shorter ones stay compact and scroll.
    final screen = MediaQuery.sizeOf(context);
    final usableHeight = screen.height - MediaQuery.paddingOf(context).vertical;
    final roominess = ((usableHeight - 600) / 260).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final ratio = MediaQuery.devicePixelRatioOf(context);
        final logoHeight = (width * 0.12).clamp(38.0, 48.0);
        // Distance to the screen edge: the gutter on phones, more on tablets
        // where the content column is centred.
        final bleed = math.max(gutter, (screen.width - width) / 2);
        final buildingWidth = ((width + gutter) * 0.9).clamp(240.0, 460.0);
        final buildingHeight = buildingWidth / _buildingAspect;
        final tucked = buildingHeight * _tuckedShare;

        // The building, not the greeting, sets the header's minimum height,
        // so the card sits below the visible part of the scene. Long names or
        // large text grow the header past it; nothing is ever squeezed.
        final minHeight =
            _logoRowHeight +
            _buildingClearance +
            buildingHeight * (1 - _emptyTopShare) -
            tucked +
            24 * roominess;

        final building = Image.asset(
          'assets/images/home/ptpn_building.png',
          fit: BoxFit.contain,
          cacheWidth: (buildingWidth * ratio).ceil().clamp(
            1,
            _buildingSourceWidth,
          ),
          excludeFromSemantics: true,
          filterQuality: FilterQuality.medium,
        );

        // Clouds shrink a little on short screens. Cloud 1 floats in the logo
        // row; cloud 2 rides on the building's roofline, beside its left wing.
        final cloudScale = 0.85 + 0.15 * roominess;
        final logoWidth = logoHeight * _logoAspect;
        // Never wider than the gap between the logo and the logout button.
        final upperCloudWidth = math.max(
          0.0,
          math.min(
            width * 0.26 * cloudScale,
            width - logoWidth - _logoRowHeight - 16,
          ),
        );
        final upperCloudLeft = (width * 0.67 - upperCloudWidth / 2).clamp(
          logoWidth + 8,
          width - _logoRowHeight - 8 - upperCloudWidth,
        );
        final lowerCloudWidth = width * 0.2 * cloudScale;
        final buildingLeft = width + bleed - buildingWidth;
        // Header bottom to the roofline, plus a little to sit level with
        // the left wing's roof.
        final roofline = buildingHeight * (1 - _emptyTopShare - 0.03) - tucked;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Every layer up to the building is decoration: it never sizes
            // the header (only the content column does) and ignores taps.
            //
            // Light-blue haze around the building, independent of the
            // clouds; transparent at both ends so it has no visible edge.
            Positioned(
              left: -bleed,
              right: -bleed,
              top: _logoRowHeight / 2,
              bottom: -tucked,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00D6E6F7),
                        Color(0x8CD6E6F7),
                        Color(0x8CD6E6F7),
                        Color(0x00D6E6F7),
                      ],
                      stops: [0, 0.6, 0.85, 1],
                    ),
                  ),
                ),
              ),
            ),
            // Near the bottom of the logout button, clear of the greeting.
            _cloud(
              left: upperCloudLeft,
              top:
                  _logoRowHeight / 2 +
                  10 +
                  12 * roominess -
                  upperCloudWidth / _cloudAspect * _cloudCenterShare,
              width: upperCloudWidth,
              ratio: ratio,
            ),
            _cloud(
              left: buildingLeft + buildingWidth * 0.34 - lowerCloudWidth / 2,
              bottom:
                  roofline -
                  lowerCloudWidth / _cloudAspect * (1 - _cloudCenterShare),
              width: lowerCloudWidth,
              ratio: ratio,
            ),
            // Building, anchored bottom-right so its lawn edge tucks under
            // the card.
            Positioned(
              right: -bleed,
              bottom: -tucked,
              width: buildingWidth,
              height: buildingHeight,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: _fade(
                    // Lawn fades out on the greeting side.
                    const LinearGradient(
                      colors: [Color(0x00000000), Color(0xE6000000)],
                      stops: [0.12, 0.62],
                    ),
                    _fade(
                      // Roofline melts into the sky; the artwork's top ~14%
                      // is already transparent.
                      const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xFF000000)],
                        stops: [0.14, 0.34],
                      ),
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          ColorFiltered(
                            colorFilter: _atmosphere,
                            child: building,
                          ),
                          // The sign keeps its original colours: the same
                          // image, untinted, shown through a feathered band.
                          _fade(_signColumns, _fade(_signRows, building)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/branding/aura_logo.png',
                        width: logoHeight * _logoAspect,
                        height: logoHeight,
                        fit: BoxFit.contain,
                        cacheWidth: (logoHeight * _logoAspect * ratio)
                            .ceil()
                            .clamp(1, 480),
                        semanticLabel: 'AURA',
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FCFF),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x151B4568),
                              offset: Offset(0, 3),
                              blurRadius: 7,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: onLogout,
                          tooltip: 'Keluar',
                          color: const Color(0xFF174B76),
                          iconSize: 22,
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20 + 16 * roominess),
                  // Keep the greeting over the faded side of the backdrop.
                  Padding(
                    padding: EdgeInsets.only(right: width * 0.28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat datang,',
                          style: TextStyle(
                            color: Color(0xFF505E6A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF123F69),
                            fontSize: (width * 0.072).clamp(22.0, 28.0),
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _cloud({
    required double left,
    required double width,
    required double ratio,
    double? top,
    double? bottom,
  }) => Positioned(
    left: left,
    top: top,
    bottom: bottom,
    width: width,
    height: width / _cloudAspect,
    child: IgnorePointer(
      child: Image.asset(
        _cloudAsset,
        fit: BoxFit.contain,
        cacheWidth: (width * ratio).ceil().clamp(1, _cloudSourceWidth),
        opacity: const AlwaysStoppedAnimation(0.9),
        excludeFromSemantics: true,
        filterQuality: FilterQuality.medium,
      ),
    ),
  );

  /// Mixes each colour [amount] of the way towards [target] after removing
  /// [desaturate] of its saturation. Alpha is left untouched.
  static ColorFilter _tint(
    Color target, {
    required double amount,
    required double desaturate,
  }) {
    const luma = [0.2126, 0.7152, 0.0722];
    List<double> row(int channel, double value) => [
      for (var i = 0; i < 3; i++)
        (1 - amount) *
            ((i == channel ? 1 - desaturate : 0) + desaturate * luma[i]),
      0,
      amount * value * 255,
    ];
    return ColorFilter.matrix([
      ...row(0, target.r),
      ...row(1, target.g),
      ...row(2, target.b),
      ...[0, 0, 0, 1, 0],
    ]);
  }

  /// Multiplies [child]'s alpha by [gradient], fading it into the background.
  static Widget _fade(Gradient gradient, Widget child) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: gradient.createShader,
    child: child,
  );
}
