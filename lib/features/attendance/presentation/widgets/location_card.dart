import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/location_result.dart';
import '../providers/current_location_notifier.dart';
import '../providers/current_location_state.dart';

/// Reusable "my location" card.
///
/// Slice 3: a self-contained preview of the device-GPS flow that Slice 4's
/// check-in will reuse. Reads the real device position via [CurrentLocation]
/// and renders each state (idle / loading / success / failure) with the right
/// recovery action.
class LocationCard extends ConsumerWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(currentLocationProvider);
    final notifier = ref.read(currentLocationProvider.notifier);

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
                Icon(Icons.my_location, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Lokasi Saya',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            switch (state) {
              LocationIdle() => _IdleView(onFetch: notifier.fetch),
              LocationLoading() => const _LoadingView(),
              LocationReady(:final position) => _SuccessView(
                position: position,
                onRefresh: notifier.fetch,
              ),
              LocationError(:final kind, :final message) => _FailureView(
                kind: kind,
                message: message,
                onRetry: notifier.fetch,
                onOpenAppSettings: notifier.openAppSettings,
                onOpenLocationSettings: notifier.openLocationSettings,
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onFetch});

  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ambil koordinat GPS perangkat untuk absensi.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onFetch,
          icon: const Icon(Icons.gps_fixed),
          label: const Text('Ambil Lokasi Saya'),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

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
        Text('Mengambil lokasi...'),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.position, required this.onRefresh});

  final GeoPosition position;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CoordRow(
          label: 'Lintang',
          value: position.latitude.toStringAsFixed(7),
        ),
        const SizedBox(height: 4),
        _CoordRow(label: 'Bujur', value: position.longitude.toStringAsFixed(7)),
        if (position.accuracy != null) ...[
          const SizedBox(height: 4),
          Text(
            'Akurasi ± ${position.accuracy!.toStringAsFixed(0)} m',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Perbarui'),
        ),
      ],
    );
  }
}

class _CoordRow extends StatelessWidget {
  const _CoordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.kind,
    required this.message,
    required this.onRetry,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final LocationFailureKind kind;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 20, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
            if (kind == LocationFailureKind.serviceDisabled)
              FilledButton.tonalIcon(
                onPressed: onOpenLocationSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Aktifkan GPS'),
              ),
            if (kind == LocationFailureKind.permissionDeniedForever)
              FilledButton.tonalIcon(
                onPressed: onOpenAppSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Buka Pengaturan'),
              ),
          ],
        ),
      ],
    );
  }
}
