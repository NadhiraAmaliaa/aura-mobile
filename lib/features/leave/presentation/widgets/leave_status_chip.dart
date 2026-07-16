import 'package:flutter/material.dart';

/// A pill-shaped badge for a leave request status (pending / approved /
/// rejected), tinted from the theme's colour scheme. Unknown statuses fall back
/// to a neutral tone.
class LeaveStatusChip extends StatelessWidget {
  const LeaveStatusChip({required this.label, required this.status, super.key});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (Color bg, Color fg) = switch (status) {
      'approved' => (scheme.primaryContainer, scheme.onPrimaryContainer),
      'rejected' => (scheme.errorContainer, scheme.onErrorContainer),
      'pending' => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
