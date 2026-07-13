import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/observability/sentry_init.dart';
import 'core/providers/core_providers.dart';

void main() {
  final env = AppEnv.fromDartDefines();

  bootstrap(
    env: env,
    builder: () => ProviderScope(
      // Bound Riverpod's default error-retry: a provider whose load keeps
      // failing (e.g. the backend is unreachable and it has no cache to fall
      // back to) must settle to a stable AsyncError instead of looping through
      // AsyncLoading forever, so no screen is left spinning indefinitely.
      retry: (retryCount, error) =>
          retryCount >= 2 ? null : Duration(milliseconds: 300 * (retryCount + 1)),
      overrides: [appEnvProvider.overrideWithValue(env)],
      child: const AuraApp(),
    ),
  );
}
