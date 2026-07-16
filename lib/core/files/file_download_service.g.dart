// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_download_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The shared [FileDownloadService], bound to the authenticated Dio instance.

@ProviderFor(fileDownloadService)
final fileDownloadServiceProvider = FileDownloadServiceProvider._();

/// The shared [FileDownloadService], bound to the authenticated Dio instance.

final class FileDownloadServiceProvider
    extends
        $FunctionalProvider<
          FileDownloadService,
          FileDownloadService,
          FileDownloadService
        >
    with $Provider<FileDownloadService> {
  /// The shared [FileDownloadService], bound to the authenticated Dio instance.
  FileDownloadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileDownloadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileDownloadServiceHash();

  @$internal
  @override
  $ProviderElement<FileDownloadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FileDownloadService create(Ref ref) {
    return fileDownloadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileDownloadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileDownloadService>(value),
    );
  }
}

String _$fileDownloadServiceHash() =>
    r'd4612ac273ff8fabaad1ab31c6906ef7f378ba2d';
