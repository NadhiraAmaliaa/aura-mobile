import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/files/file_download_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
import '../models/surat_submission.dart';
import 'surat_repository.dart';

/// Network-backed [SuratRepository].
///
/// There is no typed Retrofit client here: the endpoint returns a PDF stream,
/// not JSON, so the request goes straight through [FileDownloadService], which
/// posts the letter fields and hands the streamed PDF to the print framework.
/// All transport errors are mapped to typed [AppException]s so callers only see
/// an [ApiResult].
class SuratRepositoryImpl implements SuratRepository {
  SuratRepositoryImpl(this._downloads);

  final FileDownloadService _downloads;

  /// Path relative to the versioned base URL; leading slash preserves the `v1`
  /// segment (see architecture doc §7).
  static const _endpoint = '/surat-pulang-cepat/pdf';

  @override
  Future<ApiResult<void>> generateLetter(SuratSubmission submission) async {
    try {
      await _downloads.printPdfFromPost(
        url: _endpoint,
        data: _bodyFor(submission),
        documentName: 'surat-izin-pulang.pdf',
      );
      return const Success<void>(null);
    } on AppException catch (e) {
      return Failure(e);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  /// Maps the submission onto the backend request body. Field names track the
  /// current backend contract (`StoreSuratPulangCepatRequest`); keep them in
  /// sync when SDM finalises the letter structure.
  Map<String, dynamic> _bodyFor(SuratSubmission submission) => {
    'early_leave_date': _isoDate(submission.earlyLeaveDate),
    'leave_time': submission.leaveTime,
    'reason': submission.reason,
  };

  /// Machine-readable `yyyy-MM-dd` for the API (locale-independent).
  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
