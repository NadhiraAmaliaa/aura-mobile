import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/files/file_download_service.dart';
import 'repositories/surat_repository.dart';
import 'repositories/surat_repository_impl.dart';

part 'surat_providers.g.dart';

/// The Surat Pulang Cepat repository seam consumed by the presentation layer.
@riverpod
SuratRepository suratRepository(Ref ref) =>
    SuratRepositoryImpl(ref.watch(fileDownloadServiceProvider));
