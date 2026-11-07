import 'package:flutter/material.dart';

// Action colours from the approved Presensi reference design. Kept local
// until a shared AURA palette exists.
const _checkInColor = Color(0xFFF9A431);
const _checkOutColor = Color(0xFFE84A4D);

/// Disabled actions blend their fill this far toward [_disabledBlend]: muted
/// and desaturated, yet deep enough for the white label and spinner.
const _disabledBlend = Color(0xFF7D8794);
const _disabledBlendAmount = 0.45;

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key, required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _AttendanceActionButton(
      label: 'Check In',
      icon: Icons.login_rounded,
      color: _checkInColor,
      busy: busy,
      onPressed: onPressed,
    );
  }
}

class CheckOutButton extends StatelessWidget {
  const CheckOutButton({
    super.key,
    required this.busy,
    required this.onPressed,
  });

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _AttendanceActionButton(
      label: 'Check Out',
      icon: Icons.logout_rounded,
      color: _checkOutColor,
      busy: busy,
      onPressed: onPressed,
    );
  }
}

/// Flat, pill-shaped attendance action in its reference colour, without any
/// shadow.
///
/// A `null` [onPressed] disables it and swaps in a muted fill; [busy] replaces
/// the label with a white spinner.
class _AttendanceActionButton extends StatelessWidget {
  const _AttendanceActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Color.lerp(
          color,
          _disabledBlend,
          _disabledBlendAmount,
        ),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
        // Flat in every state: no hover/press elevation.
        elevation: 0,
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                // Shrinks rather than wraps under large text, so the two
                // pills keep one height side by side.
                Flexible(
                  child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
                ),
              ],
            ),
    );
  }
}
