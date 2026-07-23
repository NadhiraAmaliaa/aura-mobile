import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/data/models/leave_submission.dart';
import 'package:aura_mobile/features/leave/data/repositories/leave_repository.dart';
import 'package:aura_mobile/features/notifications/domain/notification_deep_link.dart';
import 'package:aura_mobile/features/notifications/domain/notification_target_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

const _request = LeaveRequestModel(
  id: 42,
  requestNumber: 'LR-20260722-0007',
  type: 'izin',
  typeLabel: 'Izin',
  reason: 'Keperluan keluarga',
  status: 'approved',
  statusLabel: 'Disetujui',
);

/// A repository whose `detail` returns a scripted result and records ids.
class _FakeLeaveRepository implements LeaveRepository {
  _FakeLeaveRepository(this._result);

  final ApiResult<LeaveRequestModel> _result;
  final List<int> detailCalls = [];

  @override
  Future<ApiResult<LeaveRequestModel>> detail(int id) async {
    detailCalls.add(id);
    return _result;
  }

  @override
  Future<ApiResult<LeaveListModel>> list({
    String? filter,
    int? page,
    int? perPage,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<LeaveRequestModel>> submit(LeaveSubmission submission) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> printApprovedPdf(LeaveRequestModel request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) =>
      throw UnimplementedError();
}

void main() {
  group('resolveNotificationTarget', () {
    test('opens the leave detail page when the request loads', () async {
      final repository = _FakeLeaveRepository(const Success(_request));

      final target = await resolveNotificationTarget(
        const LeaveDecisionDeepLink(leaveRequestId: 42),
        leaveRepository: repository,
      );

      expect(target.name, RouteNames.leaveDetail);
      expect(target.pathParameters, {'id': '42'});
      expect(repository.detailCalls, [42]);
    });

    test('falls back to the leave history list when the request '
        'cannot be loaded', () async {
      final repository = _FakeLeaveRepository(
        Failure(const NetworkException()),
      );

      final target = await resolveNotificationTarget(
        const LeaveDecisionDeepLink(leaveRequestId: 42),
        leaveRepository: repository,
      );

      expect(target.name, RouteNames.leaveHistory);
      expect(target.pathParameters, isEmpty);
      expect(repository.detailCalls, [42]);
    });
  });
}
