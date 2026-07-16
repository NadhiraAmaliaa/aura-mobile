import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/leave/data/leave_providers.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/data/models/leave_submission.dart';
import 'package:aura_mobile/features/leave/data/repositories/leave_repository.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_download_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _request = LeaveRequestModel(
  id: 9,
  requestNumber: 'LR-2026-0009',
  type: 'sakit',
  typeLabel: 'Sakit',
  reason: 'Demam',
  status: 'approved',
  statusLabel: 'Disetujui',
  evidenceUrl: 'https://example.test/evidence.pdf',
  canDownloadPdf: true,
);

/// A repository whose file actions return scripted results and record calls.
class _FakeLeaveRepository implements LeaveRepository {
  _FakeLeaveRepository({
    this.pdfResult = const Success<void>(null),
    this.evidenceResult = const Success<void>(null),
  });

  final ApiResult<void> pdfResult;
  final ApiResult<void> evidenceResult;
  int pdfCalls = 0;
  int evidenceCalls = 0;

  @override
  Future<ApiResult<void>> downloadApprovedPdf(LeaveRequestModel request) async {
    pdfCalls++;
    return pdfResult;
  }

  @override
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) async {
    evidenceCalls++;
    return evidenceResult;
  }

  @override
  Future<ApiResult<LeaveListModel>> list({
    String? filter,
    int? page,
    int? perPage,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<LeaveRequestModel>> detail(int id) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<LeaveRequestModel>> submit(LeaveSubmission submission) =>
      throw UnimplementedError();
}

ProviderContainer _container(_FakeLeaveRepository repository) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [leaveRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('LeaveDownloadNotifier', () {
    test('downloadPdf returns success and settles to data', () async {
      final repository = _FakeLeaveRepository();
      final container = _container(repository);
      await container.read(leaveDownloadProvider.future);

      final result = await container
          .read(leaveDownloadProvider.notifier)
          .downloadPdf(_request);

      expect(result, isA<Success<void>>());
      expect(repository.pdfCalls, 1);
      expect(container.read(leaveDownloadProvider), const AsyncData<void>(null));
    });

    test('openEvidence returns failure and settles to error', () async {
      final repository = _FakeLeaveRepository(
        evidenceResult: Failure(const FileOpenException()),
      );
      final container = _container(repository);
      await container.read(leaveDownloadProvider.future);

      final result = await container
          .read(leaveDownloadProvider.notifier)
          .openEvidence(_request);

      expect(result, isA<Failure<void>>());
      expect(repository.evidenceCalls, 1);
      expect(
        container.read(leaveDownloadProvider),
        isA<AsyncError<void>>(),
      );
    });

    test('downloadPdf returns failure and settles to error', () async {
      final repository = _FakeLeaveRepository(
        pdfResult: Failure(const FileOpenException()),
      );
      final container = _container(repository);
      await container.read(leaveDownloadProvider.future);

      final result = await container
          .read(leaveDownloadProvider.notifier)
          .downloadPdf(_request);

      expect(result, isA<Failure<void>>());
      expect(repository.pdfCalls, 1);
      expect(
        container.read(leaveDownloadProvider),
        isA<AsyncError<void>>(),
      );
    });
  });
}
