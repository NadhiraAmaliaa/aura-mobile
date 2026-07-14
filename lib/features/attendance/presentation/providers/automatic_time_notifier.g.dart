// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automatic_time_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// UI-facing device automatic date & time status for the presence screen.
///
/// `null` means "not verifiable" (non-Android / read error) and is treated as
/// allowed; `false` blocks attendance and shows the enable notice; `true` is
/// fine. [refresh] re-reads the setting, e.g. when the app resumes after the
/// user returns from the system Date & Time settings screen.

@ProviderFor(AutomaticTimeStatus)
final automaticTimeStatusProvider = AutomaticTimeStatusProvider._();

/// UI-facing device automatic date & time status for the presence screen.
///
/// `null` means "not verifiable" (non-Android / read error) and is treated as
/// allowed; `false` blocks attendance and shows the enable notice; `true` is
/// fine. [refresh] re-reads the setting, e.g. when the app resumes after the
/// user returns from the system Date & Time settings screen.
final class AutomaticTimeStatusProvider
    extends $AsyncNotifierProvider<AutomaticTimeStatus, bool?> {
  /// UI-facing device automatic date & time status for the presence screen.
  ///
  /// `null` means "not verifiable" (non-Android / read error) and is treated as
  /// allowed; `false` blocks attendance and shows the enable notice; `true` is
  /// fine. [refresh] re-reads the setting, e.g. when the app resumes after the
  /// user returns from the system Date & Time settings screen.
  AutomaticTimeStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'automaticTimeStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$automaticTimeStatusHash();

  @$internal
  @override
  AutomaticTimeStatus create() => AutomaticTimeStatus();
}

String _$automaticTimeStatusHash() =>
    r'1f47721a44406a987e046e58c49b69af502ced7e';

/// UI-facing device automatic date & time status for the presence screen.
///
/// `null` means "not verifiable" (non-Android / read error) and is treated as
/// allowed; `false` blocks attendance and shows the enable notice; `true` is
/// fine. [refresh] re-reads the setting, e.g. when the app resumes after the
/// user returns from the system Date & Time settings screen.

abstract class _$AutomaticTimeStatus extends $AsyncNotifier<bool?> {
  FutureOr<bool?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool?>, bool?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool?>, bool?>,
              AsyncValue<bool?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
