// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surat_submit_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the Surat Pulang Cepat form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the button
/// can show a spinner; [generate] returns the full [ApiResult] so the screen
/// can react to success (the native print sheet is shown by the download
/// service) or surface field-level validation errors.
///
/// Kept alive because the screen only calls [generate] via
/// `ref.read(...notifier)` and never watches this provider. As an auto-dispose
/// provider it would be torn down during the awaited request, so writing
/// `state` after the response would throw "used after dispose".

@ProviderFor(SuratSubmitNotifier)
final suratSubmitProvider = SuratSubmitNotifierProvider._();

/// Drives the Surat Pulang Cepat form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the button
/// can show a spinner; [generate] returns the full [ApiResult] so the screen
/// can react to success (the native print sheet is shown by the download
/// service) or surface field-level validation errors.
///
/// Kept alive because the screen only calls [generate] via
/// `ref.read(...notifier)` and never watches this provider. As an auto-dispose
/// provider it would be torn down during the awaited request, so writing
/// `state` after the response would throw "used after dispose".
final class SuratSubmitNotifierProvider
    extends $AsyncNotifierProvider<SuratSubmitNotifier, void> {
  /// Drives the Surat Pulang Cepat form.
  ///
  /// The `AsyncValue<void>` state reflects the in-flight request so the button
  /// can show a spinner; [generate] returns the full [ApiResult] so the screen
  /// can react to success (the native print sheet is shown by the download
  /// service) or surface field-level validation errors.
  ///
  /// Kept alive because the screen only calls [generate] via
  /// `ref.read(...notifier)` and never watches this provider. As an auto-dispose
  /// provider it would be torn down during the awaited request, so writing
  /// `state` after the response would throw "used after dispose".
  SuratSubmitNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suratSubmitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suratSubmitNotifierHash();

  @$internal
  @override
  SuratSubmitNotifier create() => SuratSubmitNotifier();
}

String _$suratSubmitNotifierHash() =>
    r'8546c85bdeb8af917f84f87cf1affb94eaf3cffc';

/// Drives the Surat Pulang Cepat form.
///
/// The `AsyncValue<void>` state reflects the in-flight request so the button
/// can show a spinner; [generate] returns the full [ApiResult] so the screen
/// can react to success (the native print sheet is shown by the download
/// service) or surface field-level validation errors.
///
/// Kept alive because the screen only calls [generate] via
/// `ref.read(...notifier)` and never watches this provider. As an auto-dispose
/// provider it would be torn down during the awaited request, so writing
/// `state` after the response would throw "used after dispose".

abstract class _$SuratSubmitNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
