/// Application environment / flavor configuration.
///
/// Values are injected at build/run time via `--dart-define` so that dev and
/// prod builds can coexist without code changes. See the architecture doc §13.
///
/// Example:
/// ```
/// flutter run \
///   --dart-define=ENV=dev \
///   --dart-define=BASE_URL=https://ptpn-intern-attendance.test/api \
///   --dart-define=SENTRY_DSN=
/// ```
library;

/// Supported build flavors.
enum Flavor { dev, prod }

/// Immutable, resolved environment for the current run.
class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.baseUrl,
    required this.sentryDsn,
  });

  /// Reads the environment from compile-time `--dart-define` values.
  factory AppEnv.fromDartDefines() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    const baseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://ptpn-intern-attendance.test/api',
    );
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');

    return AppEnv(
      flavor: env == 'prod' ? Flavor.prod : Flavor.dev,
      baseUrl: baseUrl,
      sentryDsn: sentryDsn,
    );
  }

  /// Active build flavor.
  final Flavor flavor;

  /// Base URL of the Laravel REST API (includes the `/api` prefix).
  final String baseUrl;

  /// Sentry DSN. Empty string disables crash reporting.
  final String sentryDsn;

  bool get isProd => flavor == Flavor.prod;
  bool get isDev => flavor == Flavor.dev;
}
