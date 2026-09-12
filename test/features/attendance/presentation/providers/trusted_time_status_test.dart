import 'dart:async';

import 'package:aura_mobile/core/device/trusted_time_providers.dart';
import 'package:aura_mobile/core/device/trusted_time_service.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_time_status_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A connectivity seam with a canned reachability result.
class _FakeConnectivity implements Connectivity {
  _FakeConnectivity(this.results);

  List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A Trusted Time service stand-in that exposes the same reactive lifecycle
/// (anchorChanges / firstAttempt / hasCompletedAttempt) the interceptor drives.
class _FakeTrustedTimeService implements TrustedTimeService {
  _FakeTrustedTimeService({this.available = false, this.attempted = false});

  bool available;
  bool attempted;

  final ValueNotifier<int> _revision = ValueNotifier<int>(0);
  final Completer<void> _firstAttempt = Completer<void>();

  @override
  Future<bool> get isAvailable async => available;

  @override
  bool get hasCompletedAttempt => attempted;

  @override
  Future<void> get firstAttempt => _firstAttempt.future;

  @override
  Listenable get anchorChanges => _revision;

  @override
  Future<DateTime> now() async {
    if (!available) throw const TrustedTimeUnavailableException();
    return DateTime.utc(2026, 9, 7, 10);
  }

  /// Simulates a completed verification attempt reported by the interceptor.
  void completeAttempt({required bool success}) {
    attempted = true;
    if (success) available = true;
    if (!_firstAttempt.isCompleted) _firstAttempt.complete();
    _revision.value++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProviderContainer _container({
  required _FakeTrustedTimeService service,
  required List<ConnectivityResult> connectivity,
}) {
  return ProviderContainer.test(
    overrides: [
      trustedTimeServiceProvider.overrideWith((ref) async => service),
      connectivityProvider.overrideWithValue(_FakeConnectivity(connectivity)),
    ],
  );
}

const _wifi = [ConnectivityResult.wifi];
const _offline = [ConnectivityResult.none];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('online with a valid anchor resolves to available (true)', () async {
    final service = _FakeTrustedTimeService(available: true, attempted: true);
    final container = _container(service: service, connectivity: _wifi);
    addTearDown(container.dispose);

    expect(await container.read(trustedTimeStatusProvider.future), isTrue);
  });

  test('offline with no anchor resolves to unavailable (false)', () async {
    final service = _FakeTrustedTimeService();
    final container = _container(service: service, connectivity: _offline);
    addTearDown(container.dispose);

    expect(await container.read(trustedTimeStatusProvider.future), isFalse);
  });

  test('online attempt failure/timeout resolves to unavailable (false)',
      () async {
    final service = _FakeTrustedTimeService();
    final container = _container(service: service, connectivity: _wifi);
    addTearDown(container.dispose);

    final future = container.read(trustedTimeStatusProvider.future);
    // The interceptor reports a completed attempt that established no anchor.
    service.completeAttempt(success: false);

    expect(await future, isFalse);
  });

  test('transient in-flight state stays loading (never false, no dialog)',
      () async {
    final service = _FakeTrustedTimeService();
    final container = _container(service: service, connectivity: _wifi);
    addTearDown(container.dispose);

    container.listen(trustedTimeStatusProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final state = container.read(trustedTimeStatusProvider);
    expect(state.isLoading, isTrue);
    // A `null` value never trips the `== false` dialog gate on the screen.
    expect(state.value, isNull);
  });

  test('recovers to available after a later successful establishment',
      () async {
    final service = _FakeTrustedTimeService();
    final container = _container(service: service, connectivity: _wifi);
    addTearDown(container.dispose);

    container.listen(trustedTimeStatusProvider, (_, _) {});

    // First attempt fails → verified unavailable.
    service.completeAttempt(success: false);
    await container.read(trustedTimeStatusProvider.future);
    expect(container.read(trustedTimeStatusProvider).value, isFalse);

    // A later successful establishment flips the status reactively.
    service.completeAttempt(success: true);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(container.read(trustedTimeStatusProvider).value, isTrue);
  });

  test('re-entry while still unavailable re-yields false (dialog shows again)',
      () async {
    final service = _FakeTrustedTimeService(available: false, attempted: true);
    final container = _container(service: service, connectivity: _wifi);
    addTearDown(container.dispose);

    expect(await container.read(trustedTimeStatusProvider.future), isFalse);

    // Simulate leaving and re-opening the screen (autoDispose rebuild).
    container.invalidate(trustedTimeStatusProvider);
    expect(await container.read(trustedTimeStatusProvider.future), isFalse);
  });
}
