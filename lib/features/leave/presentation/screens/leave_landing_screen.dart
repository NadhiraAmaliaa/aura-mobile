import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';

/// Entry point for the leave feature. Presents the intern's available leave
/// actions as tappable tiles.
///
/// Alongside the submission entry ("Ajukan Izin / Sakit") and the two read
/// destinations (pending list and history), it surfaces the isolated "Surat
/// Pulang Cepat" letter utility.
class LeaveLandingScreen extends StatelessWidget {
  const LeaveLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izin & Sakit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LeaveMenuTile(
            icon: Icons.edit_note,
            title: 'Ajukan Izin / Sakit',
            subtitle: 'Buat pengajuan izin atau sakit baru',
            onTap: () => context.pushNamed(RouteNames.leaveSubmit),
          ),
          const SizedBox(height: 12),
          _LeaveMenuTile(
            icon: Icons.hourglass_top_outlined,
            title: 'Menunggu Persetujuan',
            subtitle: 'Pengajuan yang masih diproses',
            onTap: () => context.pushNamed(RouteNames.leavePending),
          ),
          const SizedBox(height: 12),
          _LeaveMenuTile(
            icon: Icons.history,
            title: 'Riwayat Pengajuan',
            subtitle: 'Pengajuan yang disetujui atau ditolak',
            onTap: () => context.pushNamed(RouteNames.leaveHistory),
          ),
          const SizedBox(height: 12),
          _LeaveMenuTile(
            icon: Icons.description_outlined,
            title: 'Surat Pulang Cepat',
            subtitle: 'Buat surat izin pulang sebelum waktunya',
            onTap: () => context.pushNamed(RouteNames.leaveSurat),
          ),
        ],
      ),
    );
  }
}

class _LeaveMenuTile extends StatelessWidget {
  const _LeaveMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
