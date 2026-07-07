import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/check_in_notifier.dart';
import '../providers/check_in_state.dart';
import '../providers/current_location_notifier.dart';
import '../providers/current_location_state.dart';
import '../widgets/location_card.dart';

/// Available work modes, mirroring the backend `Attendance::workModeLabels()`.
const _workModes = <({String value, String label, String hint})>[
  (value: 'wfo', label: 'WFO', hint: 'Bekerja dari kantor'),
  (value: 'wfh', label: 'WFH', hint: 'Bekerja dari rumah'),
  (value: 'dinas', label: 'Dinas', hint: 'Dinas luar / tugas lapangan'),
];

/// Check-in flow: choose a work mode, capture the device location, then submit.
///
/// Follows the AGHRIS order — dashboard → this page → get location → submit.
/// The [LocationCard] lives here now (moved off the dashboard).
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  String _workMode = 'wfo';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationState = ref.watch(currentLocationProvider);
    final checkInState = ref.watch(checkInControllerProvider);

    final position = switch (locationState) {
      LocationReady(:final position) => position,
      _ => null,
    };
    final isSubmitting = checkInState is CheckInSubmitting;
    final canSubmit = position != null && !isSubmitting;

    // React to submission outcomes: toast + return to the dashboard on success.
    ref.listen<CheckInState>(checkInControllerProvider, (previous, next) {
      switch (next) {
        case CheckInSuccess():
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Check In berhasil.')));
          context.pop();
        case CheckInFailure(:final message):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Check In')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Mode Kehadiran',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _WorkModeSelector(
            selected: _workMode,
            onChanged: isSubmitting
                ? null
                : (value) => setState(() => _workMode = value),
          ),
          const SizedBox(height: 24),
          const LocationCard(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: canSubmit
                ? () => ref
                      .read(checkInControllerProvider.notifier)
                      .submit(
                        workMode: _workMode,
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
                : const Icon(Icons.login),
            label: Text(isSubmitting ? 'Memproses...' : 'Check In Sekarang'),
          ),
          if (position == null) ...[
            const SizedBox(height: 8),
            Text(
              'Ambil lokasi Anda terlebih dahulu untuk melakukan Check In.',
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

class _WorkModeSelector extends StatelessWidget {
  const _WorkModeSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final callback = onChanged;
    return AbsorbPointer(
      absorbing: callback == null,
      child: RadioGroup<String>(
        groupValue: selected,
        onChanged: (value) {
          if (value != null) callback?.call(value);
        },
        child: Column(
          children: [
            for (final mode in _workModes)
              RadioListTile<String>(
                value: mode.value,
                title: Text(mode.label),
                subtitle: Text(mode.hint),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
