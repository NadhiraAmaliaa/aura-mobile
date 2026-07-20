import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/indo_date.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

/// Read-only detail of the intern's internship record ("Informasi Magang").
///
/// Every field mirrors the official data owned by the admin web app, so the
/// screen is intentionally non-editable and shows a hint to that effect.
class InternshipInfoScreen extends ConsumerWidget {
  const InternshipInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    final user = switch (state) {
      AsyncData(value: Authenticated(:final user)) => user,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Magang'), centerTitle: true),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _InternshipDetail(user: user),
    );
  }
}

class _InternshipDetail extends StatelessWidget {
  const _InternshipDetail({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final intern = user.intern;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _InfoRow(label: 'Nama', value: user.name),
              _InfoRow(label: 'NIM', value: intern?.nim ?? '-'),
              _InfoRow(label: 'Universitas', value: intern?.university ?? '-'),
              _InfoRow(label: 'Jurusan', value: intern?.major ?? '-'),
              _InfoRow(label: 'Program Magang', value: intern?.program ?? '-'),
              _InfoRow(label: 'Divisi', value: intern?.division ?? '-'),
              _InfoRow(
                label: 'Periode Magang',
                value: _formatPeriod(intern?.startDate, intern?.endDate),
              ),
              _InfoRow(
                label: 'Status',
                isLast: true,
                trailing: _StatusChip(status: intern?.status),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReadOnlyHint(),
      ],
    );
  }

  String _formatPeriod(String? start, String? end) {
    if (start == null && end == null) return '-';
    final startText = start == null ? '-' : formatIndoDate(start);
    final endText = end == null ? '-' : formatIndoDate(end);
    return '$startText – $endText';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.trailing,
    this.isLast = false,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  trailing ??
                  Text(
                    value ?? '-',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small pill reflecting the intern's effective status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (label, background, foreground) = switch (status) {
      'active' => (
        'Aktif',
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      'upcoming' => (
        'Akan Datang',
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      'completed' => (
        'Selesai',
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      ),
      'inactive' => (
        'Non Aktif',
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      _ => ('-', scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReadOnlyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Data pada halaman ini bersifat read-only '
              '(sesuai data resmi dari admin).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
