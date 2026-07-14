import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'device_time_settings.dart';

part 'device_time_providers.g.dart';

/// The device automatic date & time seam (real platform read in production,
/// faked in tests).
@Riverpod(keepAlive: true)
DeviceTimeSettings deviceTimeSettings(Ref ref) =>
    MethodChannelDeviceTimeSettings();
