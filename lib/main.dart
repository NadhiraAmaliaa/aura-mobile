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
      overrides: [appEnvProvider.overrideWithValue(env)],
      child: const AuraApp(),
    ),
  );
}
