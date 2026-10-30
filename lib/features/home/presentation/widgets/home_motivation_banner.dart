import 'package:flutter/material.dart';

class HomeMotivationBanner extends StatelessWidget {
  const HomeMotivationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FB),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F7FD),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x15234C68),
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFE5B632),
                size: 29,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tetap semangat!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF174B76),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Disiplin hari ini, sukses di masa depan.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF596773),
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.sizeOf(context).width >= 360 &&
                MediaQuery.textScalerOf(context).scale(14) <= 18) ...[
              const SizedBox(width: 8),
              const ExcludeSemantics(
                child: SizedBox(
                  width: 60,
                  height: 50,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(
                          Icons.wb_sunny_rounded,
                          size: 24,
                          color: Color(0xFFECCF85),
                        ),
                      ),
                      Positioned(
                        left: -4,
                        bottom: -10,
                        child: Icon(
                          Icons.landscape_rounded,
                          size: 64,
                          color: Color(0xFFA3C7CF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
