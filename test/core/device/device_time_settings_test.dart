import 'package:aura_mobile/core/device/device_time_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('id.aura.app/device_time');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mockHandler(Future<Object?>? Function(MethodCall call)? handler) {
    messenger.setMockMethodCallHandler(channel, handler);
  }

  tearDown(() => mockHandler(null));

  group('MethodChannelDeviceTimeSettings.isAutomaticEnabled', () {
    test(
      'returns true when the native side reports the clock is automatic',
      () async {
        mockHandler((call) async {
          expect(call.method, 'isAutomaticTimeEnabled');
          return true;
        });

        final settings = MethodChannelDeviceTimeSettings(channel);

        expect(await settings.isAutomaticEnabled(), isTrue);
      },
    );

    test('returns false when the native side reports a manual clock', () async {
      mockHandler((call) async => false);

      final settings = MethodChannelDeviceTimeSettings(channel);

      expect(await settings.isAutomaticEnabled(), isFalse);
    });

    test(
      'returns null when the native side cannot verify the setting',
      () async {
        mockHandler((call) async => null);

        final settings = MethodChannelDeviceTimeSettings(channel);

        expect(await settings.isAutomaticEnabled(), isNull);
      },
    );

    test('returns null when the channel is unimplemented (e.g. iOS)', () async {
      // No handler registered -> MissingPluginException.
      final settings = MethodChannelDeviceTimeSettings(channel);

      expect(await settings.isAutomaticEnabled(), isNull);
    });

    test(
      'returns null when the native side throws a PlatformException',
      () async {
        mockHandler((call) async {
          throw PlatformException(code: 'boom');
        });

        final settings = MethodChannelDeviceTimeSettings(channel);

        expect(await settings.isAutomaticEnabled(), isNull);
      },
    );
  });

  group('MethodChannelDeviceTimeSettings.openDateTimeSettings', () {
    test('returns true when the settings screen opens', () async {
      mockHandler((call) async {
        expect(call.method, 'openDateTimeSettings');
        return true;
      });

      final settings = MethodChannelDeviceTimeSettings(channel);

      expect(await settings.openDateTimeSettings(), isTrue);
    });

    test(
      'returns false when the native side reports it did not open',
      () async {
        mockHandler((call) async => false);

        final settings = MethodChannelDeviceTimeSettings(channel);

        expect(await settings.openDateTimeSettings(), isFalse);
      },
    );

    test('returns false when the channel is unimplemented', () async {
      final settings = MethodChannelDeviceTimeSettings(channel);

      expect(await settings.openDateTimeSettings(), isFalse);
    });

    test('returns false when the native side throws', () async {
      mockHandler((call) async {
        throw PlatformException(code: 'boom');
      });

      final settings = MethodChannelDeviceTimeSettings(channel);

      expect(await settings.openDateTimeSettings(), isFalse);
    });
  });

  test(
    'AutomaticTimeDisabledException carries a default Indonesian message',
    () {
      const exception = AutomaticTimeDisabledException();

      expect(exception.message, contains('Tanggal & Waktu otomatis'));
      expect(exception.toString(), contains('AutomaticTimeDisabledException'));
    },
  );
}
