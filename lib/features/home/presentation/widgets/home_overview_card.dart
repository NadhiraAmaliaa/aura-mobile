import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/indo_date.dart';
import '../../../attendance/presentation/providers/attendance_dashboard_notifier.dart';
import '../../../attendance/presentation/providers/attendance_queue_controller.dart';

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
        borderRadius: BorderRadius.circular(25),
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
        padding: const EdgeInsets.all(20),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
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
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      for (final detail in details) ...[
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          style: const TextStyle(color: Color(0xFFDCEAF6)),
                        ),
                      ],
                    ],
                  );
                  final avatar = _Avatar(url: avatarUrl);
                  if (constraints.maxWidth < 280 ||
                      MediaQuery.textScalerOf(context).scale(14) > 20) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [avatar, const SizedBox(height: 12), identity],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      avatar,
                      const SizedBox(width: 16),
                      Expanded(child: identity),
                    ],
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
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

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.person, size: 50, color: Color(0xFF3F7296));
    return ExcludeSemantics(
      child: Container(
        width: 76,
        height: 76,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE4EFF8),
        ),
        child: url == null
            ? fallback
            : Image.network(
                url!,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                cacheWidth: (76 * MediaQuery.devicePixelRatioOf(context))
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
        final attendance = today.attendance;
        final labels = [
          if (attendance != null) attendance.statusLabel,
          if (attendance?.workModeLabel case final String mode) mode,
          if (attendance == null && today.leave != null)
            'Sedang ${today.leave!.typeLabel}',
          if (!today.isWorkingDay) 'Hari libur',
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0x334FA0D2),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: Color(0xFFE8F4FF),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Absensi, ${formatIndoDate(today.date)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            LayoutBuilder(
              builder: (context, constraints) {
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
                );
                if (constraints.maxWidth < 260 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20) {
                  return Column(
                    children: [checkIn, const SizedBox(height: 14), checkOut],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: checkIn),
                    Container(
                      width: 1,
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: const Color(0x337FAACB),
                    ),
                    Expanded(child: checkOut),
                  ],
                );
              },
            ),
            if (labels.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final label in labels)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF346C8C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(label, style: const TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
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
  });

  final String label;
  final String? time;
  final IconData icon;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: incoming
              ? const Color(0xFFEAF5E7)
              : const Color(0xFFE4F0FC),
          child: Icon(
            icon,
            size: 24,
            color: incoming ? const Color(0xFF367D49) : const Color(0xFF28618D),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time == null || time!.isEmpty ? '--:--' : time!,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFFDCEAF6)),
              ),
            ],
          ),
        ),
      ],
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
