import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/indo_date.dart';
import '../../../attendance/presentation/providers/attendance_dashboard_notifier.dart';
import '../../../attendance/presentation/providers/attendance_queue_controller.dart';
import 'home_layout.dart';

class HomeOverviewCard extends StatelessWidget {
  const HomeOverviewCard({
    required this.name,
    required this.avatarUrl,
    required this.nim,
    required this.division,
    required this.program,
    super.key,
  });

  final String name;
  final String? avatarUrl;
  final String? nim;
  final String? division;
  final String? program;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (nim != null && nim!.trim().isNotEmpty) 'NIM: $nim',
      if (division != null && division!.trim().isNotEmpty) division!,
      if (program != null && program!.trim().isNotEmpty) program!,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C6898), Color(0xFF194875)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25224F78),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final identity = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      for (final detail in details) ...[
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFFDCEAF6)),
                        ),
                      ],
                    ],
                  );
                  final avatar = _Avatar(url: avatarUrl);
                  if (constraints.maxWidth < 280 ||
                      HomeLayout.largeText(context)) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [avatar, const SizedBox(height: 12), identity],
                    );
                  }
                  return Row(
                    children: [
                      avatar,
                      const SizedBox(width: 14),
                      Expanded(child: identity),
                    ],
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0x337FAACB)),
              ),
              const _AttendanceSummary(),
              const _PendingNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String? url;

  static const _size = 72.0;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.person, size: 46, color: Color(0xFF3F7296));
    return ExcludeSemantics(
      child: Container(
        width: _size,
        height: _size,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE4EFF8),
        ),
        child: url == null
            ? fallback
            : Image.network(
                url!,
                width: _size,
                height: _size,
                fit: BoxFit.cover,
                cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context))
                    .ceil(),
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _AttendanceSummary extends ConsumerWidget {
  const _AttendanceSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(attendanceDashboardProvider);
    return dashboard.when(
      skipLoadingOnRefresh: true,
      data: (data) {
        final today = data.today;
        // Home stays a compact summary (date + times); status, work mode,
        // leave and holiday details live on the attendance screens.
        final attendance = today.attendance;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0x334FA0D2),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Color(0xFFE8F4FF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Absensi, ${formatIndoDate(today.date)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < 260 || HomeLayout.largeText(context);
                final checkIn = _AttendanceTime(
                  label: 'Check In',
                  time: attendance?.checkInTime,
                  icon: Icons.login_rounded,
                  incoming: true,
                );
                final checkOut = _AttendanceTime(
                  label: 'Check Out',
                  time: attendance?.checkOutTime,
                  icon: Icons.logout_rounded,
                  incoming: false,
                  mirrored: !stacked,
                );
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [checkIn, const SizedBox(height: 14), checkOut],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: checkIn),
                    Container(
                      width: 1,
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: const Color(0x337FAACB),
                    ),
                    Expanded(child: checkOut),
                  ],
                );
              },
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            semanticsLabel: 'Memuat absensi',
          ),
        ),
      ),
      error: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data absensi belum tersedia.'),
          TextButton.icon(
            onPressed: () =>
                ref.read(attendanceDashboardProvider.notifier).refresh(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTime extends StatelessWidget {
  const _AttendanceTime({
    required this.label,
    required this.time,
    required this.icon,
    required this.incoming,
    this.mirrored = false,
  });

  final String label;
  final String? time;
  final IconData icon;
  final bool incoming;

  /// Places the icon after the text, pinned to the trailing edge.
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final badge = CircleAvatar(
      radius: 22,
      backgroundColor: incoming
          ? const Color(0xFFEAF5E7)
          : const Color(0xFFE4F0FC),
      child: Icon(
        icon,
        size: 22,
        color: incoming ? const Color(0xFF367D49) : const Color(0xFF28618D),
      ),
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time == null || time!.isEmpty ? '--:--' : time!,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFFDCEAF6)),
        ),
      ],
    );
    return Row(
      mainAxisAlignment: mirrored
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: mirrored
          ? [Flexible(child: text), const SizedBox(width: 10), badge]
          : [badge, const SizedBox(width: 10), Flexible(child: text)],
    );
  }
}

class _PendingNotice extends ConsumerWidget {
  const _PendingNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(pendingAttendanceCountProvider);
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 19,
            color: Color(0xFFFFDEA0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count absensi menunggu sinkronisasi. Data tersimpan di perangkat.',
              style: const TextStyle(fontSize: 12, color: Color(0xFFFFDEA0)),
            ),
          ),
        ],
      ),
    );
  }
}
