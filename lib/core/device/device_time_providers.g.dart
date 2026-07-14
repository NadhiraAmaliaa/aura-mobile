// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_time_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device automatic date & time seam (real platform read in production,
/// faked in tests).

@ProviderFor(deviceTimeSettings)
final deviceTimeSettingsProvider = DeviceTimeSettingsProvider._();

/// The device automatic date & time seam (real platform read in production,
/// faked in tests).

final class DeviceTimeSettingsProvider
    extends
        $FunctionalProvider<
          DeviceTimeSettings,
          DeviceTimeSettings,
          DeviceTimeSettings
        >
    with $Provider<DeviceTimeSettings> {
  /// The device automatic date & time seam (real platform read in production,
  /// faked in tests).
  DeviceTimeSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTimeSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTimeSettingsHash();

  @$internal
  @override
  $ProviderElement<DeviceTimeSettings> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceTimeSettings create(Ref ref) {
    return deviceTimeSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceTimeSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceTimeSettings>(value),
    );
  }
}

String _$deviceTimeSettingsHash() =>
    r'f28c98a3ce3a2d0468b3712005f032ed93feb48e';
