import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Why the adaptive warm-up stopped listening.
enum AcquisitionFinish {
  /// A genuinely good fix (<= acceptableAccuracy) arrived; returned at once.
  goodEarlyExit,

  /// A moderate fix was granted its settle window, then returned.
  settle,

  /// Only coarse fixes arrived; the hard cap returned the best seen.
  hardCap,

  /// The stream produced nothing before the cap; the caller must do a single
  /// bounded read. [AcquisitionOutcome.position] is null in this case.
  fallback,
}

/// Result of an adaptive acquisition: the chosen [position] (null only for
/// [AcquisitionFinish.fallback]) and the [reason] the warm-up stopped.
typedef AcquisitionOutcome = ({Position? position, AcquisitionFinish reason});

/// Adaptive warm-up over a stream of position fixes.
///
/// Decides when to stop based on accuracy and time, so a good fix returns fast
/// while a coarse network fix is not accepted too early:
/// - a fix at or below [acceptableAccuracy] metres returns immediately;
/// - a time-driven checkpoint at [warmUp] (and any later fix) arms a [settle]
///   window once the best fix is at or below [moderateAccuracy] metres, even if
///   the stream goes silent after an early fix;
/// - [hardCap] is the single completion authority for coarse conditions and
///   also bounds a late settle, so exactly one finish reason can win.
///
/// The returned future completes with the chosen [AcquisitionOutcome], or with
/// an error if the stream errors (callers map it to a location failure).
Future<AcquisitionOutcome> selectAdaptiveFix(
  Stream<Position> stream, {
  required double acceptableAccuracy,
  required double moderateAccuracy,
  required Duration warmUp,
  required Duration settle,
  required Duration hardCap,
}) {
  final completer = Completer<AcquisitionOutcome>();
  Position? best;
  StreamSubscription<Position>? subscription;
  Timer? baseTimer;
  Timer? settleTimer;
  Timer? capTimer;
  var baseWindowPassed = false;

  void cleanup() {
    baseTimer?.cancel();
    settleTimer?.cancel();
    capTimer?.cancel();
    unawaited(subscription?.cancel());
  }

  // Single completion authority: the first reason to call this wins; every
  // other timer/branch becomes a no-op.
  void finish(Position? position, AcquisitionFinish reason) {
    if (completer.isCompleted) return;
    cleanup();
    completer.complete((position: position, reason: reason));
  }

  void armSettleIfModerate() {
    if (settleTimer != null || completer.isCompleted) return;
    final current = best;
    if (current != null && current.accuracy <= moderateAccuracy) {
      settleTimer = Timer(settle, () => finish(best, AcquisitionFinish.settle));
    }
  }

  // Time-driven checkpoint: fires even when the stream goes silent after an
  // early fix, so a moderate best is noticed at warmUp rather than at the cap.
  baseTimer = Timer(warmUp, () {
    baseWindowPassed = true;
    armSettleIfModerate();
  });

  capTimer = Timer(hardCap, () {
    finish(
      best,
      best == null ? AcquisitionFinish.fallback : AcquisitionFinish.hardCap,
    );
  });

  subscription = stream.listen(
    (position) {
      if (best == null || position.accuracy < best!.accuracy) best = position;
      // Genuinely good fix: return immediately, at any point.
      if (position.accuracy <= acceptableAccuracy) {
        finish(position, AcquisitionFinish.goodEarlyExit);
        return;
      }
      // Past the base window a moderate fix arms the settle here too.
      if (baseWindowPassed) armSettleIfModerate();
    },
    onError: (Object error) {
      if (completer.isCompleted) return;
      cleanup();
      completer.completeError(error);
    },
  );

  return completer.future;
}
