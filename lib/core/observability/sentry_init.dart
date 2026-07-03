import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/env.dart';

/// Boots the app, optionally inside a Sentry zone.
///
/// If [AppEnv.sentryDsn] is empty (e.g. local dev), Sentry is skipped and the
/// app runs normally. See the architecture doc §6/§17.
Future<void> bootstrap({
  required AppEnv env,
  required Widget Function() builder,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (env.sentryDsn.isEmpty) {
    runApp(builder());
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = env.sentryDsn;
    options.environment = env.flavor.name;
    options.tracesSampleRate = env.isProd ? 0.2 : 1.0;
  }, appRunner: () => runApp(builder()));
}
