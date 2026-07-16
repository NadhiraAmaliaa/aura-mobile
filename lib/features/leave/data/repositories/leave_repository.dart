import '../../../../core/network/api_result.dart';
import '../models/leave_models.dart';

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
}
