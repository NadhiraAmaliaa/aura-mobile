import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/device/device_time_providers.dart';

part 'automatic_time_notifier.g.dart';

/// UI-facing device automatic date & time status for the presence screen.
///
/// `null` means "not verifiable" (non-Android / read error) and is treated as
/// allowed; `false` blocks attendance and shows the enable notice; `true` is
/// fine. [refresh] re-reads the setting, e.g. when the app resumes after the
/// user returns from the system Date & Time settings screen.
@riverpod
class AutomaticTimeStatus extends _$AutomaticTimeStatus {
  @override
  Future<bool?> build() {
    return ref.watch(deviceTimeSettingsProvider).isAutomaticEnabled();
  }

  /// Re-check the setting after the user returns from the settings screen.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(deviceTimeSettingsProvider).isAutomaticEnabled(),
    );
  }
}
