import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/app_exception.dart';
import '../providers/core_providers.dart';

part 'file_download_service.g.dart';

/// Downloads a remote file through the shared, authenticated [Dio] client and
/// opens it with the device's default viewer.
///
/// Reusable infrastructure (not leave-specific): any feature that needs to
/// fetch and view a binary — PDFs, attachments — can depend on it. Files are
/// written to the app's temporary directory, which needs no storage
/// permission; "download" here means "fetch and view", not "save to the public
/// Downloads folder".
class FileDownloadService {
  FileDownloadService(this._dio);

  final Dio _dio;

  /// Fetches [url] (absolute, or relative to the Dio base URL so the bearer
  /// token is attached) into a temp file named [fileName], then opens it.
  ///
  /// Throws a [DioException] on a transport failure and a [FileOpenException]
  /// when the OS has no way to open the downloaded file.
  Future<void> downloadAndOpen({
    required String url,
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final savePath = p.join(directory.path, fileName);

    await _dio.download(url, savePath);

    final result = await OpenFilex.open(savePath);
    if (result.type != ResultType.done) {
      throw FileOpenException(message: _messageFor(result));
    }
  }

  /// Fetches [url] as raw bytes through the authenticated client and hands the
  /// PDF to the platform print framework, which shows the native print /
  /// "Save as PDF" preview. The app never persists the file — the user chooses
  /// the destination (print or save) through the system UI.
  ///
  /// Throws a [DioException] on a transport failure.
  Future<void> printPdf({
    required String url,
    required String documentName,
  }) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        // The server renders the PDF on demand (DomPDF + QR + logos), which can
        // take far longer than a normal JSON call — the cold render alone is
        // ~30s. Override the client's 15s default so a slow render doesn't trip
        // a spurious "request timed out".
        receiveTimeout: const Duration(seconds: 90),
      ),
    );
    final bytes = Uint8List.fromList(response.data ?? const <int>[]);

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: documentName,
    );
  }

  String _messageFor(OpenResult result) => switch (result.type) {
    ResultType.noAppToOpen =>
      'Tidak ada aplikasi yang dapat membuka berkas ini.',
    ResultType.permissionDenied => 'Izin dibutuhkan untuk membuka berkas.',
    ResultType.fileNotFound => 'Berkas tidak ditemukan.',
    _ => 'Gagal membuka berkas.',
  };
}

/// The shared [FileDownloadService], bound to the authenticated Dio instance.
@riverpod
FileDownloadService fileDownloadService(Ref ref) =>
    FileDownloadService(ref.watch(dioProvider));
