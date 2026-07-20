import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/leave/data/leave_providers.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/data/models/leave_submission.dart';
import 'package:aura_mobile/features/leave/data/repositories/leave_repository.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_submit_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _created = LeaveRequestModel(
  id: 7,
  requestNumber: 'LR-2026-0007',
  type: 'izin',
  typeLabel: 'Izin',
  reason: 'Keperluan keluarga',
  status: 'pending',
  statusLabel: 'Menunggu',
);

final _submission = LeaveSubmission(
  type: 'izin',
  reason: 'Keperluan keluarga',
  startDate: DateTime(2026, 7, 6),
  endDate: DateTime(2026, 7, 7),
);

/// A repository whose `submit` returns a scripted result and records inputs.
class _FakeLeaveRepository implements LeaveRepository {
  _FakeLeaveRepository(this._result);

  final ApiResult<LeaveRequestModel> _result;
  final List<LeaveSubmission> submissions = [];

  @override
  Future<ApiResult<LeaveRequestModel>> submit(
    LeaveSubmission submission,
  ) async {
    submissions.add(submission);
    return _result;
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
  Future<ApiResult<void>> printApprovedPdf(LeaveRequestModel request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) =>
      throw UnimplementedError();
}

/// Connectivity stub reporting a fixed transport so the offline guard is
/// deterministic.
class _FakeConnectivity implements Connectivity {
  _FakeConnectivity({required this.connected});

  final bool connected;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      connected ? [ConnectivityResult.wifi] : [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

ProviderContainer _container(
  _FakeLeaveRepository repository, {
  bool connected = true,
}) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      leaveRepositoryProvider.overrideWithValue(repository),
      connectivityProvider.overrideWithValue(
        _FakeConnectivity(connected: connected),
      ),
    ],
  );
}

void main() {
  group('LeaveSubmitNotifier', () {
    test(
      'returns success and settles to data on a successful submit',
      () async {
        final repository = _FakeLeaveRepository(const Success(_created));
        final container = _container(repository);
        await container.read(leaveSubmitProvider.future);

        final result = await container
            .read(leaveSubmitProvider.notifier)
            .submit(_submission);

        expect(result, isA<Success<LeaveRequestModel>>());
        expect(repository.submissions.single.reason, 'Keperluan keluarga');
        expect(
          container.read(leaveSubmitProvider),
          const AsyncData<void>(null),
        );
      },
    );

    test('returns failure and settles to error when submit fails', () async {
      final repository = _FakeLeaveRepository(
        Failure(const ValidationException(message: 'Data tidak valid.')),
      );
      final container = _container(repository);
      await container.read(leaveSubmitProvider.future);

      final result = await container
          .read(leaveSubmitProvider.notifier)
          .submit(_submission);

      expect(result, isA<Failure<LeaveRequestModel>>());
      expect(container.read(leaveSubmitProvider), isA<AsyncError<void>>());
    });

    test(
      'blocks submit and returns an offline message when disconnected',
      () async {
        final repository = _FakeLeaveRepository(const Success(_created));
        final container = _container(repository, connected: false);
        await container.read(leaveSubmitProvider.future);

        final result = await container
            .read(leaveSubmitProvider.notifier)
            .submit(_submission);

        expect(result, isA<Failure<LeaveRequestModel>>());
        final failure = result as Failure<LeaveRequestModel>;
        expect(failure.exception, isA<NetworkException>());
        expect(failure.exception.message, contains('offline'));
        expect(repository.submissions, isEmpty);
        expect(container.read(leaveSubmitProvider), isA<AsyncError<void>>());
      },
    );
  });
}
