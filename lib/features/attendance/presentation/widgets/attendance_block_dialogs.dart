import 'package:flutter/material.dart';

/// The action the user chose in the automatic date & time hard-block dialog.
enum AutoTimeBlockedChoice {
  /// OK — acknowledge and leave the attendance page (the clock is still manual).
  dismissed,

  /// Buka Pengaturan — open the system Date & Time settings.
  openSettings,
}

/// Shows the AGHRIS-style hard block for a manual device clock.
///
/// The dialog is non-dismissible (no barrier tap, no back button) so the user
/// must pick an action: [AutoTimeBlockedChoice.openSettings] to open the system
/// Date & Time screen, or [AutoTimeBlockedChoice.dismissed] (OK) which the
/// caller uses to navigate the user off the capture page. Attendance stays
/// blocked either way until the automatic clock (and time zone) is enabled.
Future<AutoTimeBlockedChoice> showAutoTimeBlockedDialog(BuildContext context) {
  return showDialog<AutoTimeBlockedChoice>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Tanggal & waktu tidak otomatis'),
        content: const Text(
          'Aktifkan Tanggal & Waktu Otomatis serta Zona Waktu Otomatis '
          'untuk melakukan presensi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(AutoTimeBlockedChoice.dismissed),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(AutoTimeBlockedChoice.openSettings),
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    ),
  ).then((choice) => choice ?? AutoTimeBlockedChoice.dismissed);
}

/// Shows the hard block while no valid trusted-time anchor exists (fresh
/// install, or a post-reboot device that is still offline).
///
/// Reuses the auto-time navigation pattern: the dialog is non-dismissible (no
/// barrier tap, no back button) with a single OK action, after which the caller
/// navigates the user off the capture page. Reconnecting re-establishes the
/// anchor via the HTTP interceptor and clears the block.
Future<void> showTrustedTimeBlockedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Waktu perangkat belum terverifikasi'),
        content: const Text(
          'Hubungkan ke internet terlebih dahulu untuk memverifikasi waktu '
          'sebelum melakukan absensi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

/// Shows a blocking dialog when a mock/fake/simulated location is detected.
///
/// Reuses the trusted-time navigation pattern: the dialog is non-dismissible
/// (no barrier tap, no back button) with a single Mengerti action, after which
/// the caller navigates the user off the capture page. Attendance stays
/// blocked until a non-mocked fix succeeds.
Future<void> showMockLocationBlockedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Lokasi tidak dapat diverifikasi'),
        content: const Text(
          'Lokasi palsu terdeteksi. Presensi tidak dapat dilakukan '
          'karena lokasi Anda tidak dapat diverifikasi.\n\n'
          'Jika Anda menggunakan aplikasi Fake GPS atau Mock Location, '
          'nonaktifkan terlebih dahulu, lalu coba lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    ),
  );
}
