import 'package:flutter/material.dart';

import '../../../../shared/widgets/aura_form.dart';

/// Background and text colours of a leave request [status]: light blue while
/// pending, green once approved, soft red when rejected and neutral for
/// anything else.
({Color background, Color foreground}) leaveStatusColors(String status) =>
    switch (status) {
      'pending' => (
        background: const Color(0xFFD9F1F8),
        foreground: const Color(0xFF155A7A),
      ),
      'approved' => (
        background: const Color(0xFFDDF3E1),
        foreground: const Color(0xFF1E6B2E),
      ),
      'rejected' => (
        background: const Color(0xFFFDE3E3),
        foreground: const Color(0xFFB3261E),
      ),
      _ => (
        background: const Color(0xFFECEFF3),
        foreground: AuraForm.bodyMuted,
      ),
    };

/// A pill-shaped badge for a leave request status, in [leaveStatusColors].
class LeaveStatusChip extends StatelessWidget {
  const LeaveStatusChip({required this.label, required this.status, super.key});

  final String label;
  final String status;

  static const _padding = EdgeInsets.symmetric(horizontal: 12, vertical: 5);
  static const _style = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );

  /// The badge's width for [label] at the current text scale.
  static double widthOf(BuildContext context, String label) =>
      AuraForm.textSize(context, label, _style).width + _padding.horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = leaveStatusColors(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: _padding,
        child: Text(label, style: _style.copyWith(color: colors.foreground)),
      ),
    );
  }
}
