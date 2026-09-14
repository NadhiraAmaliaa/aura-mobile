// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_time_status_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// UI-facing trusted-time availability for the presence screen.
///
/// `true` means a valid trust anchor exists for the current boot session, so
/// attendance may proceed; `false` blocks attendance and shows the notice
/// (no anchor yet, or the anchor was invalidated by a device reboot). [refresh]
/// re-checks after the app resumes or once connectivity refreshes the anchor.

@ProviderFor(TrustedTimeStatus)
final trustedTimeStatusProvider = TrustedTimeStatusProvider._();

/// UI-facing trusted-time availability for the presence screen.
///
/// `true` means a valid trust anchor exists for the current boot session, so
/// attendance may proceed; `false` blocks attendance and shows the notice
/// (no anchor yet, or the anchor was invalidated by a device reboot). [refresh]
/// re-checks after the app resumes or once connectivity refreshes the anchor.
final class TrustedTimeStatusProvider
    extends $AsyncNotifierProvider<TrustedTimeStatus, bool> {
  /// UI-facing trusted-time availability for the presence screen.
  ///
  /// `true` means a valid trust anchor exists for the current boot session, so
  /// attendance may proceed; `false` blocks attendance and shows the notice
  /// (no anchor yet, or the anchor was invalidated by a device reboot). [refresh]
  /// re-checks after the app resumes or once connectivity refreshes the anchor.
  TrustedTimeStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedTimeStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedTimeStatusHash();

  @$internal
  @override
  TrustedTimeStatus create() => TrustedTimeStatus();
}

String _$trustedTimeStatusHash() => r'7390286b9cda16ad7d84f3129ca65ae5ada56e94';

/// UI-facing trusted-time availability for the presence screen.
///
/// `true` means a valid trust anchor exists for the current boot session, so
/// attendance may proceed; `false` blocks attendance and shows the notice
/// (no anchor yet, or the anchor was invalidated by a device reboot). [refresh]
/// re-checks after the app resumes or once connectivity refreshes the anchor.

abstract class _$TrustedTimeStatus extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
