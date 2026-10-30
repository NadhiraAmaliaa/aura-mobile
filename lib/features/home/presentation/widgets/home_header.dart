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
  static const _buildingAspect = 1440 / 488;

  /// How far the backdrop extends below the header, under the overview card.
  static const _backdropOverlap = 28.0;

  /// Height of the logo row: the logout button's minimum tap target.
  static const _logoRowHeight = kMinInteractiveDimension;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final ratio = MediaQuery.devicePixelRatioOf(context);
        final logoHeight = (width * 0.12).clamp(38.0, 48.0);
        final buildingWidth = ((width + gutter) * 0.82).clamp(180.0, 420.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative backdrop: anchored bottom-right so its base tucks
            // under the card, and bounded above by the logo row so it never
            // reaches the logout button — it scales down instead of clipping.
            Positioned(
              top: _logoRowHeight + 6,
              right: -gutter,
              bottom: -_backdropOverlap,
              width: buildingWidth,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: buildingWidth,
                      height: buildingWidth / _buildingAspect,
                      child: _fade(
                        // Clear on the greeting side, solid towards the edge.
                        const LinearGradient(
                          colors: [Color(0x00000000), Color(0xBF000000)],
                          stops: [0.1, 0.72],
                        ),
                        _fade(
                          // Roofline melts into the sky.
                          const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0xFF000000)],
                            stops: [0, 0.4],
                          ),
                          Image.asset(
                            'assets/images/home/ptpn_building.png',
                            fit: BoxFit.contain,
                            cacheWidth: (buildingWidth * ratio).ceil().clamp(
                              1,
                              1440,
                            ),
                            excludeFromSemantics: true,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
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
                SizedBox(height: (width * 0.065).clamp(20.0, 28.0)),
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
          ],
        );
      },
    );
  }

  /// Multiplies [child]'s alpha by [gradient], fading it into the background.
  static Widget _fade(Gradient gradient, Widget child) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: gradient.createShader,
    child: child,
  );
}
