import 'dart:convert';
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
        // The server renders the PDF on demand (DomPDF + QR + logos). It is fast
        // once warm, but the first render after a cold start rebuilds the font
        // cache and can take a few seconds — a generous ceiling over the
        // client's 15s default keeps a slow render from tripping a spurious
        // "request timed out".
        receiveTimeout: const Duration(seconds: 90),
      ),
    );
    final bytes = Uint8List.fromList(response.data ?? const <int>[]);

    await Printing.layoutPdf(onLayout: (_) async => bytes, name: documentName);
  }

  /// Posts [data] as JSON to [url] and hands the streamed PDF back to the
  /// platform print framework (native print / "Save as PDF" preview).
  ///
  /// Used by stateless, on-demand documents that are rendered from form input
  /// rather than a persisted record (e.g. Surat Pulang Cepat): the request body
  /// carries the letter fields and the response body is the PDF itself. Nothing
  /// is persisted locally — the user chooses the destination via the system UI.
  ///
  /// Throws a [DioException] on a transport failure.
  Future<void> printPdfFromPost({
    required String url,
    required Map<String, dynamic> data,
    required String documentName,
  }) async {
    try {
      final response = await _dio.post<List<int>>(
        url,
        data: data,
        options: Options(
          responseType: ResponseType.bytes,
          // Same rationale as [printPdf]: the server renders on demand, and a
          // cold-start render can take a few seconds, so a generous receive
          // ceiling over the client's 15s default avoids a spurious timeout.
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
      final bytes = Uint8List.fromList(response.data ?? const <int>[]);

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: documentName,
      );
    } on DioException catch (e) {
      // The success body is the PDF (bytes), but an error body (e.g. a 422 with
      // field errors) is JSON. Because we requested bytes, that JSON arrives as
      // raw bytes; decode it back so the shared error mapper can read the
      // Laravel `message`/`errors` shape.
      throw _decodeErrorBody(e);
    }
  }

  /// Rewrites a bytes-typed error body back into decoded JSON so
  /// [mapDioException] can extract Laravel's `message` and `errors`. Leaves the
  /// exception untouched if there is no body or it is not valid JSON.
  DioException _decodeErrorBody(DioException e) {
    final data = e.response?.data;
    if (data is List<int> && data.isNotEmpty) {
      try {
        e.response!.data = jsonDecode(utf8.decode(data));
      } on FormatException {
        // Not JSON (unexpected) — leave the raw body in place.
      }
    }
    return e;
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
