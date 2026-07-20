import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/app_exception.dart';
import 'api_result.dart';
import 'connectivity_providers.dart';

/// User-facing message shown when an online-only submission is attempted while
/// the device has no connectivity.
///
/// Submissions across the app have no offline queue, so the action must fail
/// fast with this single, shared wording. Every submission surface reuses this
/// exact string so the offline experience is identical everywhere.
const offlineSubmissionMessage =
    'Pengajuan tidak dapat dikirim karena Anda sedang offline. '
    'Sambungkan ke internet lalu coba lagi.';

/// Guards an online-only submission against a lack of connectivity.
///
/// Performs the shared connectivity check and, when the device is offline,
/// returns a [Failure] carrying a [NetworkException] with
/// [offlineSubmissionMessage]. Returns `null` when the request may proceed.
///
/// Callers should return the failure and mirror it in their error state so the
/// UI surfaces the standard offline message.
Future<Failure<T>?> offlineSubmissionGuard<T>(Ref ref) async {
  final online = hasConnectivity(
    await ref.read(connectivityProvider).checkConnectivity(),
  );
  if (online) return null;
  return Failure<T>(const NetworkException(message: offlineSubmissionMessage));
}
