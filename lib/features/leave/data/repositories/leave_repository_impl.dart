import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/app_exception.dart';
import '../../../../core/files/file_download_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/observability/error_reporter.dart';
import '../datasources/leave_api.dart';
import '../models/leave_models.dart';
import '../models/leave_submission.dart';
import 'leave_repository.dart';

/// Network-backed [LeaveRepository]. Unwraps the `data` envelope and maps all
/// transport errors to typed [AppException]s so callers only ever see an
/// [ApiResult].
class LeaveRepositoryImpl implements LeaveRepository {
  LeaveRepositoryImpl(this._api, this._downloads);

  final LeaveApi _api;
  final FileDownloadService _downloads;

  @override
  Future<ApiResult<LeaveListModel>> list({
    String? filter,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _api.list(filter, page, perPage);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<LeaveRequestModel>> detail(int id) async {
    try {
      final response = await _api.detail(id);
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<LeaveRequestModel>> submit(
    LeaveSubmission submission,
  ) async {
    try {
      final response = await _api.create(
        type: submission.type,
        reason: submission.reason,
        startDate: _isoDate(submission.startDate),
        endDate: _isoDate(submission.endDate),
        contactPhone: submission.contactPhone,
        address: submission.address,
        evidence: submission.evidence,
      );
      return Success(response.data);
    } on DioException catch (e) {
      return Failure(mapDioException(e));
    } catch (e, stackTrace) {
      return Failure(reportUnexpectedError(e, stackTrace));
    }
  }

  @override
  Future<ApiResult<void>> printApprovedPdf(LeaveRequestModel request) async {
    try {
      await _downloads.printPdf(
        url: '/leave-requests/${request.id}/pdf',
        documentName: 'pengajuan-${request.requestNumber}.pdf',
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

  @override
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) async {
    final url = request.evidenceUrl;
    if (url == null || url.isEmpty) {
      return Failure(
        const FileOpenException(message: 'Lampiran tidak tersedia.'),
      );
    }
    try {
      await _downloads.downloadAndOpen(
        url: url,
        fileName: _evidenceFileName(request, url),
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

  /// Machine-readable `yyyy-MM-dd` for the API (locale-independent).
  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// A stable local filename for the attachment, preserving its extension.
  String _evidenceFileName(LeaveRequestModel request, String url) {
    final extension = p.extension(Uri.parse(url).path);
    return 'lampiran-${request.requestNumber}$extension';
  }
}
