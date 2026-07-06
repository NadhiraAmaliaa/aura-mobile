import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/auth/presentation/providers/auth_state.dart';

/// Authenticated landing placeholder for the auth vertical slice.
///
/// This is deliberately minimal — it proves the session round-trips (login →
/// token persisted → user available) and exposes logout. Attendance, history,
/// leave, and profile land in later slices.
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

    final intern = user.intern;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AURA Mobile'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome,', style: theme.textTheme.titleMedium),
            Text(user.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            if (intern != null) ...[
              _InfoRow(label: 'NIM', value: intern.nim),
              _InfoRow(label: 'Status', value: intern.status),
              if (intern.startDate != null)
                _InfoRow(label: 'Start date', value: intern.startDate!),
              if (intern.endDate != null)
                _InfoRow(label: 'End date', value: intern.endDate!),
            ] else
              Text(
                'No intern profile attached to this account.',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
