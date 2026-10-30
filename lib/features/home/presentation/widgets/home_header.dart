import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.name, required this.onLogout, super.key});

  final String name;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final largeText = MediaQuery.textScalerOf(context).scale(16) > 22;
        final buildingWidth = width * (largeText ? 1 : 0.9);
        final ratio = MediaQuery.devicePixelRatioOf(context);
        final building = Image.asset(
          'assets/images/home/ptpn_building.png',
          width: buildingWidth,
          fit: BoxFit.contain,
          cacheWidth: (buildingWidth * ratio).ceil().clamp(1, 1440),
          excludeFromSemantics: true,
          filterQuality: FilterQuality.medium,
        );
        final greeting = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang,',
              style: TextStyle(
                color: Color(0xFF505E6A),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(
                color: Color(0xFF123F69),
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/branding/aura_logo.png',
                  width: 132,
                  height: 70,
                  fit: BoxFit.contain,
                  cacheWidth: (132 * ratio).ceil().clamp(1, 480),
                  semanticLabel: 'AURA',
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FCFF),
                    borderRadius: BorderRadius.circular(17),
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
                    iconSize: 27,
                    padding: const EdgeInsets.all(13),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (largeText) ...[
              greeting,
              const SizedBox(height: 12),
              building,
            ] else
              Stack(
                children: [
                  Positioned(right: 0, bottom: 0, child: building),
                  Padding(
                    padding: EdgeInsets.only(
                      right: width * 0.4,
                      bottom: buildingWidth * 0.24,
                    ),
                    child: greeting,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
