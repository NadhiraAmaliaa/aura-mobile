import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/device/trusted_time_providers.dart';
import '../../../../core/network/connectivity_providers.dart';

part 'trusted_time_status_notifier.g.dart';

/// UI-facing trusted-time availability for the presence screen.
///
/// Resolves to one of three states, all expressed as `AsyncValue<bool>`:
///  * loading (`null`) — no anchor yet but a verification attempt is still in
///    flight (online); attendance stays disabled without a block dialog.
///  * `true` — a valid anchor exists for this boot session; attendance proceeds.
///  * `false` — verified unavailable: offline with no anchor, or an attempt
///    completed without establishing one (post-reboot / server unreachable).
///
/// The lifecycle is owned entirely by the core Trusted Time layer: the service
/// exposes [TrustedTimeService.anchorChanges], [TrustedTimeService.firstAttempt]
/// and [TrustedTimeService.hasCompletedAttempt], driven by the HTTP
/// interceptor. This provider only reads core signals ([connectivityProvider]
/// for the definitive offline case) and never depends on any attendance
/// feature provider.
@riverpod
class TrustedTimeStatus extends _$TrustedTimeStatus {
  @override
  Future<bool> build() async {
    final service = await ref.watch(trustedTimeServiceProvider.future);

    // Re-evaluate whenever the anchor is established/invalidated or an attempt
    // completes (reconnect establishes; reboot invalidates).
    void onChange() => ref.invalidateSelf();
    service.anchorChanges.addListener(onChange);
    ref.onDispose(() => service.anchorChanges.removeListener(onChange));

    if (await service.isAvailable) return true;

    // No anchor. Offline is definitive: no network attempt can establish one
    // right now, so surface the block instead of waiting forever.
    final online = hasConnectivity(
      await ref.read(connectivityProvider).checkConnectivity(),
    );
    if (!online) return false;

    // Online but no anchor yet: stay loading until the first verification
    // attempt completes, then commit to its outcome. A failed/timed-out
    // attempt (via the interceptor) resolves this to `false`.
    if (!service.hasCompletedAttempt) {
      await service.firstAttempt;
    }
    return service.isAvailable;
  }

  /// Re-check availability, e.g. on resume or after a capture-time block.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
