import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final items = [
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
            final scaler = MediaQuery.textScalerOf(context);
            final minWidth = 104 * (scaler.scale(14) / 14);
            final columns = ((constraints.maxWidth + 10) / (minWidth + 10))
                .floor()
                .clamp(1, 3);
            final tileWidth =
                (constraints.maxWidth - 10 * (columns - 1)) / columns;
            final cards = [
              for (final item in items)
                SizedBox(
                  width: tileWidth,
                  child: _MenuCard(
                    title: item.title,
                    description: item.description,
                    asset: item.asset,
                    tint: item.tint,
                    color: item.color,
                    onTap: item.onTap,
                  ),
                ),
            ];
            if (columns == 3) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cards[0],
                  const SizedBox(width: 10),
                  cards[1],
                  const SizedBox(width: 10),
                  cards[2],
                ],
              );
            }
            return Wrap(spacing: 10, runSpacing: 12, children: cards);
          },
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.description,
    required this.asset,
    required this.tint,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final String asset;
  final Color tint;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: onTap,
      label: '$title. $description',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
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
          borderRadius: BorderRadius.circular(25),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tint, Color.lerp(tint, Colors.white, 0.75)!],
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final imageWidth = constraints.maxWidth.clamp(
                          1.0,
                          190.0,
                        );
                        return Center(
                          child: Image.asset(
                            asset,
                            width: imageWidth,
                            height: imageWidth * 0.92,
                            fit: BoxFit.contain,
                            cacheWidth:
                                (imageWidth *
                                        MediaQuery.devicePixelRatioOf(context))
                                    .ceil()
                                    .clamp(1, 600),
                            filterQuality: FilterQuality.medium,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.textScalerOf(context).scale(12) *
                            1.4 *
                            4,
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF58636A),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 23,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
