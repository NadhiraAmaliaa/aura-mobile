import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import 'router/routes.dart';

/// Authenticated landing screen: the main menu shell.
///
/// Slice 0 turns the former auth placeholder into the app's home. It shows a
/// greeting header and the four v1 menu destinations (Profile, Attendance,
/// Leave, SPD). Only Attendance has a real screen so far; the others route to
/// "coming soon" placeholders until their slices land.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(authProvider);
    final user = switch (state) {
      AsyncData(value: Authenticated(:final user)) => user,
      _ => null,
    };

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AURA'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat datang,', style: theme.textTheme.titleMedium),
              Text(user.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: const [
                    _MenuCard(
                      label: 'Profil',
                      icon: Icons.person_outline,
                      path: RoutePaths.profile,
                    ),
                    _MenuCard(
                      label: 'Absensi',
                      icon: Icons.how_to_reg_outlined,
                      path: RoutePaths.attendance,
                    ),
                    _MenuCard(
                      label: 'Izin',
                      icon: Icons.event_busy_outlined,
                      path: RoutePaths.leave,
                    ),
                    _MenuCard(
                      label: 'SPD',
                      icon: Icons.card_travel_outlined,
                      path: RoutePaths.spd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single tappable menu tile in the home grid.
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(path),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
