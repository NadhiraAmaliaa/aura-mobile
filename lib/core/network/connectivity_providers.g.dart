// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device's shared [Connectivity] instance.

@ProviderFor(connectivity)
final connectivityProvider = ConnectivityProvider._();

/// The device's shared [Connectivity] instance.

final class ConnectivityProvider
    extends $FunctionalProvider<Connectivity, Connectivity, Connectivity>
    with $Provider<Connectivity> {
  /// The device's shared [Connectivity] instance.
  ConnectivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityHash();

  @$internal
  @override
  $ProviderElement<Connectivity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Connectivity create(Ref ref) {
    return connectivity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Connectivity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Connectivity>(value),
    );
  }
}

String _$connectivityHash() => r'e66720f09edf1a8b09e450e1eaedd51da9443f0e';

/// Emits whenever the device's connectivity changes.
///
/// A change to any non-`none` transport is the app's cue to flush the offline
/// attendance queue.

@ProviderFor(connectivityChanges)
final connectivityChangesProvider = ConnectivityChangesProvider._();

/// Emits whenever the device's connectivity changes.
///
/// A change to any non-`none` transport is the app's cue to flush the offline
/// attendance queue.

final class ConnectivityChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  /// Emits whenever the device's connectivity changes.
  ///
  /// A change to any non-`none` transport is the app's cue to flush the offline
  /// attendance queue.
  ConnectivityChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityChangesHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityChanges(ref);
  }
}

String _$connectivityChangesHash() =>
    r'899cf245a6b56647f0250858480dc1870add60f7';
