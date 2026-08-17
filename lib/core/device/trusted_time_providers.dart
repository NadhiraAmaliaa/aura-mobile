import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_providers.dart';
import 'platform_clock.dart';
import 'trusted_time_service.dart';

part 'trusted_time_providers.g.dart';

/// The platform monotonic clock seam (real native calls in production, faked in
/// tests).
@Riverpod(keepAlive: true)
PlatformClock platformClock(Ref ref) => MethodChannelPlatformClock();

/// The trusted time service, wired to the platform clock and the shared
/// database. Kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
Future<TrustedTimeService> trustedTimeService(Ref ref) async {
  final clock = ref.watch(platformClockProvider);
  final db = await ref.watch(appDatabaseProvider.future);
  return TrustedTimeService(clock, db);
}
