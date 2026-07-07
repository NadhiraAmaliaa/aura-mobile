import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/check_out_notifier.dart';
import '../providers/check_out_state.dart';
import '../providers/current_location_notifier.dart';
import '../providers/current_location_state.dart';
import '../widgets/location_card.dart';

/// Check-out flow: capture the device location, then submit.
///
/// Follows the AGHRIS order — dashboard → this page → get location → submit.
/// Unlike check-in there is no work mode; the mode was fixed at check-in.
class CheckOutScreen extends ConsumerWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locationState = ref.watch(currentLocationProvider);
    final checkOutState = ref.watch(checkOutControllerProvider);

    final position = switch (locationState) {
      LocationReady(:final position) => position,
      _ => null,
    };
    final isSubmitting = checkOutState is CheckOutSubmitting;
    final canSubmit = position != null && !isSubmitting;

    // React to submission outcomes: toast + return to the dashboard on success.
    ref.listen<CheckOutState>(checkOutControllerProvider, (previous, next) {
      switch (next) {
        case CheckOutSuccess():
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Check Out berhasil.')),
            );
          context.pop();
        case CheckOutFailure(:final message):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Check Out')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Konfirmasi lokasi Anda sebelum mengakhiri kehadiran hari ini.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const LocationCard(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: canSubmit
                ? () => ref
                      .read(checkOutControllerProvider.notifier)
                      .submit(
                        latitude: position.latitude,
                        longitude: position.longitude,
                      )
                : null,
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(isSubmitting ? 'Memproses...' : 'Check Out Sekarang'),
          ),
          if (position == null) ...[
            const SizedBox(height: 8),
            Text(
              'Ambil lokasi Anda terlebih dahulu untuk melakukan Check Out.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
