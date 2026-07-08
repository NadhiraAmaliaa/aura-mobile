import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/location_result.dart';
import '../geofence_evaluation.dart';
import '../providers/attendance_locations_provider.dart';

/// WFO geofence status for the current [position].
///
/// Renders the active-locations fetch (loading / error / empty) and, once
/// loaded, whether the device is inside the nearest office radius. Purely a
/// pre-check to guide the user — the server enforces the geofence on submit.
class WfoGeofenceCard extends ConsumerWidget {
  const WfoGeofenceCard({required this.position, super.key});

  final GeoPosition position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locationsAsync = ref.watch(attendanceLocationsProvider);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.social_distance, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Validasi Lokasi Kantor',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            locationsAsync.when(
              loading: () => const _LoadingRow(),
              error: (_, _) => _ErrorRow(
                onRetry: () => ref.invalidate(attendanceLocationsProvider),
              ),
              data: (locations) => _EvaluationView(
                evaluation: evaluateGeofence(
                  locations,
                  position.latitude,
                  position.longitude,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Memeriksa lokasi kantor...'),
      ],
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gagal memuat lokasi kantor.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba Lagi'),
        ),
      ],
    );
  }
}

class _EvaluationView extends StatelessWidget {
  const _EvaluationView({required this.evaluation});

  final GeofenceEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (evaluation) {
      GeofenceNoLocations() => _StatusMessage(
        icon: Icons.error_outline,
        color: theme.colorScheme.error,
        title: 'Lokasi kantor belum dikonfigurasi.',
        detail: 'Silakan hubungi administrator untuk mengaktifkan lokasi absen.',
      ),
      GeofenceInside(:final location, :final distanceMeters) => _StatusMessage(
        icon: Icons.check_circle_outline,
        color: Colors.green.shade700,
        title: 'Anda berada di dalam radius ${location.name}.',
        detail:
            'Jarak Anda sekitar ${distanceMeters.round()} m '
            '(radius ${location.radius} m).',
      ),
      GeofenceOutside(:final location, :final distanceMeters) => _StatusMessage(
        icon: Icons.wrong_location_outlined,
        color: theme.colorScheme.error,
        title: 'Anda berada di luar radius lokasi kantor.',
        detail:
            'Jarak Anda sekitar ${distanceMeters.round()} m dari '
            '${location.name} (radius ${location.radius} m).',
      ),
    };
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
