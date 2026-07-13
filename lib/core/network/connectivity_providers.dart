import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_providers.g.dart';

/// The device's shared [Connectivity] instance.
@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) => Connectivity();

/// Emits whenever the device's connectivity changes.
///
/// A change to any non-`none` transport is the app's cue to flush the offline
/// attendance queue.
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityChanges(Ref ref) {
  return ref.watch(connectivityProvider).onConnectivityChanged;
}

/// Whether at least one non-`none` transport is currently available.
bool hasConnectivity(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);
