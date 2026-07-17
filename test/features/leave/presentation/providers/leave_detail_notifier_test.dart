import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/leave/data/leave_providers.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/data/models/leave_submission.dart';
import 'package:aura_mobile/features/leave/data/repositories/leave_repository.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_detail_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _request = LeaveRequestModel(
  id: 5,
  requestNumber: 'LR-2026-0005',
  type: 'sakit',
  typeLabel: 'Sakit',
  reason: 'Demam',
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

ProviderContainer _container(_FakeLeaveRepository repository) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [leaveRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('LeaveDetailNotifier', () {
    test('loads the request for the given id on build', () async {
      final repository = _FakeLeaveRepository(const Success(_request));
      final container = _container(repository);

      final request = await container.read(leaveDetailProvider(5).future);

      expect(request.id, 5);
      expect(request.statusLabel, 'Disetujui');
      expect(repository.detailCalls, [5]);
    });

    test('surfaces an error when the request fails to load', () async {
      final repository = _FakeLeaveRepository(
        Failure(const NetworkException()),
      );
      final container = _container(repository);

      await expectLater(
        container.read(leaveDetailProvider(5).future),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
