import 'package:aura_mobile/core/database/app_database.dart';
import 'package:aura_mobile/core/device/platform_clock.dart';
import 'package:aura_mobile/core/device/trusted_time_anchor.dart';
import 'package:aura_mobile/core/device/trusted_time_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A fake platform clock with controllable monotonic time and boot count.
class FakePlatformClock implements PlatformClock {
  int? nextMonotonicMs;
  int? nextBootCount;

  @override
  Future<int?> monotonicMs() async => nextMonotonicMs;

  @override
  Future<int?> bootCount() async => nextBootCount;
}

void main() {
  late Database db;
  late FakePlatformClock clock;
  late TrustedTimeService service;

  /// A controllable wall clock for the iOS sanity check. Defaults to a time
  /// close to the server time used in most tests so the sanity check passes.
  late DateTime Function() wallClock;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await openAppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    clock = FakePlatformClock();
    // Default wall clock: close to common test server times to avoid false
    // positives in the sanity check.
    wallClock = () => DateTime.utc(2026, 8, 17, 10, 0, 0);
    service = TrustedTimeService(clock, db, wallClock: wallClock);
  });

  tearDown(() async {
    await db.close();
  });

  // -- Scenario 12: Fresh install / no anchor + offline → attendance blocked.
  group('no anchor', () {
    test('now() throws TrustedTimeUnavailableException', () async {
      clock.nextMonotonicMs = 1000;
      clock.nextBootCount = 1;

      await expectLater(
        service.now(),
        throwsA(isA<TrustedTimeUnavailableException>()),
      );
    });

    test('isAvailable returns false', () async {
      clock.nextMonotonicMs = 1000;
      clock.nextBootCount = 1;

      expect(await service.isAvailable, isFalse);
    });
  });

  // -- Scenarios 2, 3: Valid anchor → trusted capture succeeds.
  group('valid anchor', () {
    test('Android: valid anchor projects correct UTC time', () async {
      clock.nextMonotonicMs = 10000;
      clock.nextBootCount = 5;

      final serverTime = DateTime.utc(2026, 8, 17, 10, 0, 0);
      await service.setAnchor(serverTime);

      // Advance monotonic by 30 seconds.
      clock.nextMonotonicMs = 40000; // delta = 30 000 ms

      final result = await service.now();
      expect(result.isUtc, isTrue);
      expect(
        result,
        equals(DateTime.utc(2026, 8, 17, 10, 0, 30)),
      );
    });

    test('iOS: valid anchor projects correct UTC time (no bootCount)', () async {
      // Rebuild service with a wall clock matching the iOS test server time.
      final iosService = TrustedTimeService(
        clock,
        db,
        wallClock: () => DateTime.utc(2026, 8, 17, 14, 1, 0),
      );

      clock.nextMonotonicMs = 5000;
      clock.nextBootCount = null; // iOS

      final serverTime = DateTime.utc(2026, 8, 17, 14, 0, 0);
      await iosService.setAnchor(serverTime);

      // Advance monotonic by 60 seconds.
      clock.nextMonotonicMs = 65000; // delta = 60 000 ms

      final result = await iosService.now();
      expect(result.isUtc, isTrue);
      expect(
        result,
        equals(DateTime.utc(2026, 8, 17, 14, 1, 0)),
      );
    });

    test('isAvailable returns true', () async {
      clock.nextMonotonicMs = 1000;
      clock.nextBootCount = 1;

      await service.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

      clock.nextMonotonicMs = 2000;

      expect(await service.isAvailable, isTrue);
    });
  });

  // -- Scenario 6: Device wall clock manually changes while a valid anchor
  //    exists → captured_at remains based on Trusted Time.
  test('wall-clock change does not affect trusted time projection', () async {
    clock.nextMonotonicMs = 10000;
    clock.nextBootCount = 3;

    final serverTime = DateTime.utc(2026, 8, 17, 10, 0, 0);
    await service.setAnchor(serverTime);

    // Simulate 5 minutes of monotonic elapsed time. The wall clock could be
    // anything — DateTime.now() is never consulted for the projected time.
    clock.nextMonotonicMs = 310000; // delta = 300 000 ms = 5 min

    final result = await service.now();
    expect(result, equals(DateTime.utc(2026, 8, 17, 10, 5, 0)));
  });

  // -- Scenario 7: Android reboot detected by changed BOOT_COUNT → old anchor
  //    invalid.
  group('Android reboot detection (BOOT_COUNT)', () {
    test('changed boot count invalidates anchor', () async {
      clock.nextMonotonicMs = 10000;
      clock.nextBootCount = 5;

      await service.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

      // Reboot: boot count increases, monotonic might even be larger.
      clock.nextMonotonicMs = 20000;
      clock.nextBootCount = 6;

      await expectLater(
        service.now(),
        throwsA(isA<TrustedTimeUnavailableException>()),
      );
    });

    test('anchor is deleted from DB after reboot detection', () async {
      clock.nextMonotonicMs = 10000;
      clock.nextBootCount = 5;

      await service.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

      // Reboot
      clock.nextMonotonicMs = 20000;
      clock.nextBootCount = 6;

      // First call invalidates.
      try {
        await service.now();
      } catch (_) {}

      // New service instance loading from DB should find no anchor.
      final service2 = TrustedTimeService(clock, db, wallClock: wallClock);
      expect(await service2.isAvailable, isFalse);
    });
  });

  // -- Scenario 8: iOS reboot / boot-session change → old anchor invalid.
  group('iOS reboot detection', () {
    test('monotonic regression invalidates anchor', () async {
      clock.nextMonotonicMs = 100000;
      clock.nextBootCount = null; // iOS

      await service.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

      // Reboot: monotonic resets to a value lower than saved.
      clock.nextMonotonicMs = 5000;

      await expectLater(
        service.now(),
        throwsA(isA<TrustedTimeUnavailableException>()),
      );
    });

    test(
      'post-reboot uptime exceeding saved value detected by sanity check',
      () async {
        // Simulate: anchor created, then device off for 24 hours, then back
        // on. Post-reboot uptime exceeds saved monotonic value.
        //
        // estimatedNow = serverTime + (100000 - 10000)ms = serverTime + 90s
        //             = 2026-08-17T10:01:30 UTC
        // wallNow    = 2026-08-18T10:01:30 UTC (24 hours later)
        // Drift = 24 hours → way above threshold → detected.
        final iosService = TrustedTimeService(
          clock,
          db,
          wallClock: () => DateTime.utc(2026, 8, 18, 10, 1, 30),
        );

        clock.nextMonotonicMs = 10000;
        clock.nextBootCount = null; // iOS

        final serverTime = DateTime.utc(2026, 8, 17, 10, 0, 0);
        await iosService.setAnchor(serverTime);

        // Post-reboot: uptime exceeds saved value.
        clock.nextMonotonicMs = 100000;

        await expectLater(
          iosService.now(),
          throwsA(isA<TrustedTimeUnavailableException>()),
        );
      },
    );

    test(
      'drift of 61 seconds triggers sanity check (just above 60s threshold)',
      () async {
        // estimatedNow = serverTime + (70000 - 10000)ms = serverTime + 60s
        //             = 2026-08-17T10:01:00 UTC
        // wallNow    = 2026-08-17T10:02:01 UTC (61s ahead of estimatedNow)
        // Drift = 61s → above 60s threshold → detected.
        final iosService = TrustedTimeService(
          clock,
          db,
          wallClock: () => DateTime.utc(2026, 8, 17, 10, 2, 1),
        );

        clock.nextMonotonicMs = 10000;
        clock.nextBootCount = null; // iOS

        await iosService.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

        clock.nextMonotonicMs = 70000;

        await expectLater(
          iosService.now(),
          throwsA(isA<TrustedTimeUnavailableException>()),
        );
      },
    );

    test(
      'drift of 59 seconds does NOT trigger sanity check (below 60s threshold)',
      () async {
        // estimatedNow = serverTime + (70000 - 10000)ms = serverTime + 60s
        //             = 2026-08-17T10:01:00 UTC
        // wallNow    = 2026-08-17T10:01:59 UTC (59s ahead of estimatedNow)
        // Drift = 59s → below 60s threshold → anchor valid.
        final iosService = TrustedTimeService(
          clock,
          db,
          wallClock: () => DateTime.utc(2026, 8, 17, 10, 1, 59),
        );

        clock.nextMonotonicMs = 10000;
        clock.nextBootCount = null; // iOS

        await iosService.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

        clock.nextMonotonicMs = 70000;

        final result = await iosService.now();
        expect(result, equals(DateTime.utc(2026, 8, 17, 10, 1, 0)));
      },
    );
  });

  // -- Scenarios 9, 10: Reboot + offline → Check In / Check Out blocked.
  group('reboot + offline blocks attendance', () {
    test('Check In blocked after reboot (no new anchor)', () async {
      clock.nextMonotonicMs = 50000;
      clock.nextBootCount = 1;

      await service.setAnchor(DateTime.utc(2026, 8, 17, 8, 0, 0));

      // Reboot
      clock.nextMonotonicMs = 1000;
      clock.nextBootCount = 2;

      // now() throws — attendance blocked.
      await expectLater(
        service.now(),
        throwsA(isA<TrustedTimeUnavailableException>()),
      );
    });

    test('Check Out blocked after reboot (no new anchor)', () async {
      clock.nextMonotonicMs = 50000;
      clock.nextBootCount = 3;

      await service.setAnchor(DateTime.utc(2026, 8, 17, 8, 0, 0));

      // Reboot
      clock.nextMonotonicMs = 2000;
      clock.nextBootCount = 4;

      await expectLater(
        service.now(),
        throwsA(isA<TrustedTimeUnavailableException>()),
      );
    });
  });

  // -- Scenario 11: Reboot + successful server-time acquisition → new anchor
  //    established and attendance works again.
  test('new anchor after reboot re-enables trusted time', () async {
    clock.nextMonotonicMs = 50000;
    clock.nextBootCount = 1;

    await service.setAnchor(DateTime.utc(2026, 8, 17, 8, 0, 0));

    // Reboot
    clock.nextMonotonicMs = 1000;
    clock.nextBootCount = 2;

    // now() fails (anchor invalid).
    await expectLater(
      service.now(),
      throwsA(isA<TrustedTimeUnavailableException>()),
    );

    // Server contact establishes new anchor.
    clock.nextMonotonicMs = 2000;
    await service.setAnchor(DateTime.utc(2026, 8, 17, 12, 0, 0));

    // Advance 10 seconds.
    clock.nextMonotonicMs = 12000; // delta = 10 000 ms

    final result = await service.now();
    expect(result, equals(DateTime.utc(2026, 8, 17, 12, 0, 10)));
  });

  // -- Scenario 16: App force-close / process restart WITHOUT device reboot →
  //    valid anchor remains usable (loaded from SQLite).
  test('anchor survives app restart (new service instance)', () async {
    clock.nextMonotonicMs = 10000;
    clock.nextBootCount = 3;

    final serverTime = DateTime.utc(2026, 8, 17, 14, 0, 0);
    await service.setAnchor(serverTime);

    // Simulate app restart: create a new service instance reading from the
    // same database.
    final service2 = TrustedTimeService(clock, db, wallClock: wallClock);

    clock.nextMonotonicMs = 70000; // delta = 60 000 ms = 1 minute

    final result = await service2.now();
    expect(result, equals(DateTime.utc(2026, 8, 17, 14, 1, 0)));
  });

  // -- Scenario 17: Device sleep → elapsed trusted time continues correctly.
  test('monotonic clock including sleep projects correct time', () async {
    clock.nextMonotonicMs = 10000;
    clock.nextBootCount = 1;

    final serverTime = DateTime.utc(2026, 8, 17, 22, 0, 0);
    await service.setAnchor(serverTime);

    // Simulate 8 hours of sleep (the native monotonic clock includes sleep).
    const eightHoursMs = 8 * 60 * 60 * 1000;
    clock.nextMonotonicMs = 10000 + eightHoursMs;

    final result = await service.now();
    expect(result, equals(DateTime.utc(2026, 8, 18, 6, 0, 0)));
  });

  // -- Anchor refresh: setAnchor replaces the previous anchor.
  test('setAnchor overwrites previous anchor', () async {
    clock.nextMonotonicMs = 10000;
    clock.nextBootCount = 1;

    await service.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

    // New anchor at a later point.
    clock.nextMonotonicMs = 50000;
    await service.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 40));

    // Advance 20 seconds from new anchor.
    clock.nextMonotonicMs = 70000; // delta = 20 000 ms from new anchor

    final result = await service.now();
    expect(result, equals(DateTime.utc(2026, 8, 17, 10, 1, 0)));
  });

  // -- Platform clock returns null → TrustedTimeUnavailableException.
  test('null monotonicMs throws TrustedTimeUnavailableException', () async {
    clock.nextMonotonicMs = 1000;
    clock.nextBootCount = 1;
    await service.setAnchor(DateTime.utc(2026, 8, 17, 10, 0, 0));

    clock.nextMonotonicMs = null;

    await expectLater(
      service.now(),
      throwsA(isA<TrustedTimeUnavailableException>()),
    );
  });

  // -- TrustedTimeAnchor model serialization round-trip.
  group('TrustedTimeAnchor', () {
    test('round-trips through toMap / fromMap', () {
      final anchor = TrustedTimeAnchor(
        serverTimeUtc: DateTime.utc(2026, 8, 17, 10, 0, 0),
        monotonicMs: 12345,
        bootCount: 7,
      );

      final restored = TrustedTimeAnchor.fromMap(anchor.toMap());

      expect(restored.serverTimeUtc, equals(anchor.serverTimeUtc));
      expect(restored.monotonicMs, equals(anchor.monotonicMs));
      expect(restored.bootCount, equals(anchor.bootCount));
    });

    test('round-trips with null bootCount (iOS)', () {
      final anchor = TrustedTimeAnchor(
        serverTimeUtc: DateTime.utc(2026, 8, 17, 10, 0, 0),
        monotonicMs: 99999,
        bootCount: null,
      );

      final restored = TrustedTimeAnchor.fromMap(anchor.toMap());

      expect(restored.bootCount, isNull);
      expect(restored.monotonicMs, equals(99999));
    });

    test('estimateUtcNow projects correctly', () {
      final anchor = TrustedTimeAnchor(
        serverTimeUtc: DateTime.utc(2026, 8, 17, 10, 0, 0),
        monotonicMs: 10000,
      );

      final result = anchor.estimateUtcNow(310000); // +300s = +5min
      expect(result, equals(DateTime.utc(2026, 8, 17, 10, 5, 0)));
    });
  });
}
