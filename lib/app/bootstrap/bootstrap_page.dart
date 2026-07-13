import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_bootstrap_provider.dart';

/// Shown after a successful login while the minimum offline dataset is being
/// fetched and persisted for the authenticated user (see [OfflineBootstrap]).
///
/// While the bootstrap is in flight it shows a "preparing" spinner. If it fails
/// — typically because the device is offline on a fresh login — it surfaces a
/// clear setup/retry message here, during the online login/bootstrap stage,
/// rather than letting the user discover it later inside the Attendance flow.
class BootstrapPage extends ConsumerWidget {
  const BootstrapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bootstrap = ref.watch(offlineBootstrapProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: bootstrap.hasError
                ? _Failure(theme: theme)
                : _Preparing(theme: theme),
          ),
        ),
      ),
    );
  }
}

class _Preparing extends StatelessWidget {
  const _Preparing({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.eco_rounded, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Menyiapkan data offline…',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Failure extends ConsumerWidget {
  const _Failure({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 64,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          'Gagal menyiapkan data offline',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Periksa koneksi internet Anda lalu coba lagi. Data ini diperlukan '
          'agar aplikasi dapat digunakan tanpa koneksi.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () =>
              ref.read(offlineBootstrapProvider.notifier).retry(),
          child: const Text('Coba Lagi'),
        ),
      ],
    );
  }
}
