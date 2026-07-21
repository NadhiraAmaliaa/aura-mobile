/// Application environment / flavor configuration.
///
/// Values are injected at build/run time via `--dart-define` so that dev and
/// prod builds can coexist without code changes. See the architecture doc §13.
///
/// Example:
/// ```
/// flutter run \
///   --dart-define=ENV=dev \
///   --dart-define=BASE_URL=http://ptpn-intern-attendance.test/api/v1 \
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
      defaultValue: 'http://ptpn-intern-attendance.test/api/v1',
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

  /// Base URL of the versioned Laravel REST API (includes the `/api/v1`
  /// prefix). Because Dio joins the base URL and request path by string
  /// concatenation, endpoint paths must start with a leading slash
  /// (e.g. `/auth/login`) so the version segment is preserved.
  ///
  /// The dev default targets the local Herd domain over HTTP; production
  /// builds must pass an HTTPS URL via `--dart-define=BASE_URL=...`.
  final String baseUrl;

  /// Sentry DSN. Empty string disables crash reporting.
  final String sentryDsn;

  bool get isProd => flavor == Flavor.prod;
  bool get isDev => flavor == Flavor.dev;

  /// Origin (`scheme://host[:port]`) of the API, derived from [baseUrl].
  ///
  /// Used to resolve server-relative asset references (e.g. avatar paths the
  /// backend returns without a host) so they point at whatever host the app is
  /// configured to talk to — dev machine, LAN IP or production — with no
  /// hardcoding.
  String get apiOrigin => Uri.parse(baseUrl).origin;

  /// Resolves a server asset reference to an absolute URL.
  ///
  /// - `null`/empty → `null`.
  /// - Already-absolute URLs (e.g. a production CDN) are returned unchanged.
  /// - Host-relative paths (e.g. `/storage/avatars/x.jpg`) are joined onto
  ///   [apiOrigin].
  String? resolveAssetUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (Uri.parse(path).hasScheme) return path;
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$apiOrigin$normalized';
  }
}
