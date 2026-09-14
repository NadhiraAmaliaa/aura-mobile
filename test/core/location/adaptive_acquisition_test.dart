import 'dart:async';

import 'package:aura_mobile/core/location/adaptive_acquisition.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

/// Builds a [Position] carrying only the [accuracy] the adaptive logic reads.
Position _pos(double accuracy, {double lat = -6.851679, double lng = 107.583}) =>
    Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime(2024),
      accuracy: accuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

/// Runs [selectAdaptiveFix] with the production 20/50/3s/2s/7s policy over a
/// caller-driven stream, capturing the outcome.
({StreamController<Position> controller, AcquisitionOutcome? Function() read})
_start(FakeAsync async) {
  final controller = StreamController<Position>();
  AcquisitionOutcome? outcome;
  selectAdaptiveFix(
    controller.stream,
    acceptableAccuracy: 20,
    moderateAccuracy: 50,
    warmUp: const Duration(seconds: 3),
    settle: const Duration(seconds: 2),
    hardCap: const Duration(seconds: 7),
  ).then((o) => outcome = o);
  async.flushMicrotasks();
  return (controller: controller, read: () => outcome);
}

void main() {
  group('selectAdaptiveFix', () {
    test(
      'moderate fix before 3s then silence finishes via the 3s checkpoint '
      'after the 2s settle',
      () {
        fakeAsync((async) {
          final run = _start(async);

          async.elapse(const Duration(milliseconds: 1715));
          run.controller.add(_pos(39.1));
          async.flushMicrotasks();
          async.elapse(const Duration(milliseconds: 963)); // t=2678
          run.controller.add(_pos(31.1));
          async.flushMicrotasks();

          // No further events. The time-driven checkpoint at 3s must notice the
          // moderate best and settle ~2s later (~5s), not wait for the cap.
          async.elapse(const Duration(milliseconds: 500)); // t=3178
          expect(run.read(), isNull, reason: 'still settling');

          async.elapse(const Duration(seconds: 2)); // t=5178, settle fired at 5s
          final outcome = run.read();
          expect(outcome, isNotNull);
          expect(outcome!.reason, AcquisitionFinish.settle);
          expect(outcome.position!.accuracy, 31.1);
          expect(async.nonPeriodicTimerCount, 0);

          run.controller.close();
          async.flushMicrotasks();
        });
      },
    );

    test('a <=20m fix returns immediately, before the warm-up', () {
      fakeAsync((async) {
        final run = _start(async);

        async.elapse(const Duration(milliseconds: 500));
        run.controller.add(_pos(15));
        async.flushMicrotasks();

        final outcome = run.read();
        expect(outcome, isNotNull);
        expect(outcome!.reason, AcquisitionFinish.goodEarlyExit);
        expect(outcome.position!.accuracy, 15);
        expect(async.nonPeriodicTimerCount, 0);

        run.controller.close();
        async.flushMicrotasks();
      });
    });

    test('persistently coarse fixes finish at the 7s hard cap with the best '
        'seen', () {
      fakeAsync((async) {
        final run = _start(async);

        async.elapse(const Duration(seconds: 1));
        run.controller.add(_pos(80));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3)); // t=4
        run.controller.add(_pos(70)); // still coarse (>50)
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2)); // t=6
        run.controller.add(_pos(90));
        async.flushMicrotasks();

        expect(run.read(), isNull, reason: 'cap not yet reached');

        async.elapse(const Duration(seconds: 2)); // t=8, cap fired at 7s
        final outcome = run.read();
        expect(outcome, isNotNull);
        expect(outcome!.reason, AcquisitionFinish.hardCap);
        expect(outcome.position!.accuracy, 70);
        expect(async.nonPeriodicTimerCount, 0);

        run.controller.close();
        async.flushMicrotasks();
      });
    });

    test('a moderate fix near the hard cap yields exactly one completion path '
        '(cap wins, settle cancelled)', () {
      fakeAsync((async) {
        final run = _start(async);

        async.elapse(const Duration(seconds: 1));
        run.controller.add(_pos(80)); // coarse through the base checkpoint
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 5900)); // t=6900
        run.controller.add(_pos(30)); // moderate arms a settle to ~8.9s
        async.flushMicrotasks();

        // Cap fires at 7s, before the settle would; it must be the sole winner.
        async.elapse(const Duration(milliseconds: 300)); // t=7200
        final outcome = run.read();
        expect(outcome, isNotNull);
        expect(outcome!.reason, AcquisitionFinish.hardCap);
        expect(outcome.position!.accuracy, 30);
        // No timer survived -> the settle was cancelled, not left racing.
        expect(async.nonPeriodicTimerCount, 0);

        // Nothing further completes or throws once the cap has won.
        async.elapse(const Duration(seconds: 3));
        expect(run.read()!.reason, AcquisitionFinish.hardCap);

        run.controller.close();
        async.flushMicrotasks();
      });
    });

    test('the best (lowest-accuracy) fix received is the one returned', () {
      fakeAsync((async) {
        final run = _start(async);

        async.elapse(const Duration(seconds: 1));
        run.controller.add(_pos(45)); // moderate; checkpoint will settle
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3)); // t=4, past checkpoint+settle armed
        run.controller.add(_pos(40)); // improves best
        async.flushMicrotasks();
        run.controller.add(_pos(60)); // worse; must be ignored
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 2)); // settle fires (armed at 3s -> 5s)
        final outcome = run.read();
        expect(outcome, isNotNull);
        expect(outcome!.reason, AcquisitionFinish.settle);
        expect(outcome.position!.accuracy, 40);

        run.controller.close();
        async.flushMicrotasks();
      });
    });

    test('no fixes before the cap yields a fallback outcome with no position',
        () {
      fakeAsync((async) {
        final run = _start(async);

        async.elapse(const Duration(seconds: 8)); // past the 7s cap
        final outcome = run.read();
        expect(outcome, isNotNull);
        expect(outcome!.reason, AcquisitionFinish.fallback);
        expect(outcome.position, isNull);
        expect(async.nonPeriodicTimerCount, 0);

        run.controller.close();
        async.flushMicrotasks();
      });
    });
  });
}
