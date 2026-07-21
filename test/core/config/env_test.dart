import 'package:aura_mobile/core/config/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppEnv envWith(String baseUrl) =>
      AppEnv(flavor: Flavor.dev, baseUrl: baseUrl, sentryDsn: '');

  group('AppEnv.apiOrigin', () {
    test('strips the path (including /api/v1) from the base URL', () {
      expect(
        envWith('http://192.168.1.5:8000/api/v1').apiOrigin,
        'http://192.168.1.5:8000',
      );
    });

    test('omits the default port for a hostname base URL', () {
      expect(
        envWith('https://api.example.com/api/v1').apiOrigin,
        'https://api.example.com',
      );
    });
  });

  group('AppEnv.resolveAssetUrl', () {
    final env = envWith('http://192.168.1.5:8000/api/v1');

    test('returns null for null or empty input', () {
      expect(env.resolveAssetUrl(null), isNull);
      expect(env.resolveAssetUrl(''), isNull);
    });

    test('joins a host-relative path onto the API origin', () {
      expect(
        env.resolveAssetUrl('/storage/avatars/x.jpg'),
        'http://192.168.1.5:8000/storage/avatars/x.jpg',
      );
    });

    test('adds a leading slash when the path lacks one', () {
      expect(
        env.resolveAssetUrl('storage/avatars/x.jpg'),
        'http://192.168.1.5:8000/storage/avatars/x.jpg',
      );
    });

    test('passes an already-absolute URL through unchanged (e.g. a CDN)', () {
      expect(
        env.resolveAssetUrl('https://cdn.example.com/avatars/x.jpg'),
        'https://cdn.example.com/avatars/x.jpg',
      );
    });
  });
}
