import 'dart:async';

import 'package:aura_mobile/core/device/trusted_time_providers.dart';
import 'package:aura_mobile/core/device/trusted_time_service.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_attendance_date_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// An anchor-change signal that counts its attached listeners.
class _CountingRevision extends ValueNotifier<int> {
  _CountingRevision() : super(0);

  int listeners = 0;

  @override
  void addListener(VoidCallback listener) {
    listeners++;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners--;
    super.removeListener(listener);
  }
}

/// A trusted clock whose time (or unavailability) the test controls, with the
/// same anchor-change signal as the real service.
class _FakeTrustedTime implements TrustedTimeService {
  _FakeTrustedTime(this.instant);

  DateTime instant;
  TrustedTimeUnavailableException? error;
  final _revision = _CountingRevision();

  /// Listeners currently attached to [anchorChanges].
  int get anchorListeners => _revision.listeners;

  /// Simulates an anchor being established or invalidated.
  void bumpAnchor() => _revision.value++;

  @override
  Listenable get anchorChanges => _revision;

  @override
  Future<DateTime> now() async {
    final error = this.error;
    if (error != null) throw error;
    return instant;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProviderContainer _containerFor(_FakeTrustedTime trustedTime) {
  return ProviderContainer.test(
    overrides: [
      trustedTimeServiceProvider.overrideWith((ref) async => trustedTime),
    ],
  );
}

/// The first date the provider emits, kept alive by a listener the way a
/// watching screen keeps it alive in the app.
Future<String?> _firstDate(ProviderContainer container) {
  container.listen(trustedAttendanceDateProvider, (_, _) {});
  return container.read(trustedAttendanceDateProvider.future);
}

/// Lets queued microtasks (the provider's async re-evaluation) complete.
Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('emits the local calendar date of the trusted time', () async {
    final trustedTime = _FakeTrustedTime(DateTime(2026, 10, 31, 3, 20).toUtc());
    final container = _containerFor(trustedTime);
    addTearDown(container.dispose);

    expect(await _firstDate(container), '2026-10-31');
  });

  test('is unknown while trusted time is unavailable after a reboot', () async {
    final trustedTime = _FakeTrustedTime(DateTime(2026, 10, 31).toUtc())
      ..error = const TrustedTimeUnavailableException(
        TrustedTimeUnavailableException.rebootMessage,
      );
    final container = _containerFor(trustedTime);
    addTearDown(container.dispose);

    expect(await _firstDate(container), isNull);
  });

  test('follows the trusted date when the anchor changes', () async {
    final trustedTime = _FakeTrustedTime(
      DateTime(2026, 10, 30, 23, 59).toUtc(),
    );
    final container = _containerFor(trustedTime);
    addTearDown(container.dispose);
    final values = <String?>[];
    container.listen(
      trustedAttendanceDateProvider,
      (_, next) => values.add(next.value),
      fireImmediately: true,
    );
    await container.read(trustedAttendanceDateProvider.future);

    trustedTime
      ..instant = DateTime(2026, 10, 31, 0, 1).toUtc()
      ..bumpAnchor();
    await _settle();

    expect(container.read(trustedAttendanceDateProvider).value, '2026-10-31');

    trustedTime
      ..error = const TrustedTimeUnavailableException()
      ..bumpAnchor();
    await _settle();

    expect(container.read(trustedAttendanceDateProvider).value, isNull);
    expect(values.whereType<String>(), ['2026-10-30', '2026-10-31']);
  });

  testWidgets('notices a day rollover without any anchor change', (
    tester,
  ) async {
    final trustedTime = _FakeTrustedTime(
      DateTime(2026, 10, 30, 23, 59, 50).toUtc(),
    );
    final container = _containerFor(trustedTime);
    final subscription = container.listen(
      trustedAttendanceDateProvider,
      (_, _) {},
    );
    await tester.pump();
    expect(container.read(trustedAttendanceDateProvider).value, '2026-10-30');

    // Offline across midnight: no API response refreshes the anchor.
    trustedTime.instant = DateTime(2026, 10, 31, 0, 0, 20).toUtc();
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();

    expect(container.read(trustedAttendanceDateProvider).value, '2026-10-31');

    subscription.close();
    container.dispose();
  });

  testWidgets('allocates nothing when disposed while trusted time resolves', (
    tester,
  ) async {
    final trustedTime = _FakeTrustedTime(DateTime(2026, 10, 31).toUtc());
    final service = Completer<TrustedTimeService>();
    final container = ProviderContainer.test(
      overrides: [
        trustedTimeServiceProvider.overrideWith((ref) => service.future),
      ],
    );

    // Watched, then abandoned before the trusted-time service has resolved.
    container.listen(trustedAttendanceDateProvider, (_, _) {}).close();
    // Riverpod disposes an unlistened provider on a zero-duration timer.
    await tester.pump(Duration.zero);
    expect(container.exists(trustedAttendanceDateProvider), isFalse);

    service.complete(trustedTime);
    await tester.pump();

    // No anchor listener is left on the service. A leaked periodic timer would
    // also fail this test as a timer still pending at the end.
    expect(trustedTime.anchorListeners, 0);
    container.dispose();
  });
}
