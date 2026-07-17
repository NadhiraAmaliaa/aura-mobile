import '../../../../core/network/api_result.dart';
import '../models/leave_models.dart';
import '../models/leave_submission.dart';

/// Leave-request boundary consumed by the presentation layer.
///
/// Per architecture doc §3.1, `leave` does not warrant a full domain layer:
/// the data DTOs cross this seam directly (no separate entities). The abstract
/// interface is kept solely as a testing seam so notifiers can be exercised
/// against a fake.
abstract interface class LeaveRepository {
  /// Loads one page of the intern's leave requests, newest first. [filter]
  /// narrows to `pending` or `history`; null returns all. [page] is 1-based.
  Future<ApiResult<LeaveListModel>> list({
    String? filter,
    int? page,
    int? perPage,
  });

  /// Loads a single leave request owned by the intern.
  Future<ApiResult<LeaveRequestModel>> detail(int id);

  /// Submits a new leave request (izin / sakit) and returns the created record.
  Future<ApiResult<LeaveRequestModel>> submit(LeaveSubmission submission);

  /// Fetches the approved-request PDF and opens the native print / "Save as
  /// PDF" preview so the user prints or saves it through the system UI.
  Future<ApiResult<void>> printApprovedPdf(LeaveRequestModel request);

  /// Downloads the uploaded evidence attachment and opens it.
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request);
}
