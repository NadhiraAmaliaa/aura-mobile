// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Surat Pulang Cepat repository seam consumed by the presentation layer.

@ProviderFor(suratRepository)
final suratRepositoryProvider = SuratRepositoryProvider._();

/// The Surat Pulang Cepat repository seam consumed by the presentation layer.

final class SuratRepositoryProvider
    extends
        $FunctionalProvider<SuratRepository, SuratRepository, SuratRepository>
    with $Provider<SuratRepository> {
  /// The Surat Pulang Cepat repository seam consumed by the presentation layer.
  SuratRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suratRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suratRepositoryHash();

  @$internal
  @override
  $ProviderElement<SuratRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SuratRepository create(Ref ref) {
    return suratRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SuratRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SuratRepository>(value),
    );
  }
}

String _$suratRepositoryHash() => r'87917c2f5bf2bb5a63a8f0b53689834bc430de72';
