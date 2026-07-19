import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/surat/data/models/surat_submission.dart';
import 'package:aura_mobile/features/surat/data/repositories/surat_repository.dart';
import 'package:aura_mobile/features/surat/data/surat_providers.dart';
import 'package:aura_mobile/features/surat/presentation/providers/surat_submit_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _submission = SuratSubmission(
  earlyLeaveDate: DateTime(2026, 7, 18),
  leaveTime: '14:30',
  reason: 'Ada keperluan keluarga yang mendesak.',
);

/// A repository whose `generateLetter` returns a scripted result and records
/// inputs.
class _FakeSuratRepository implements SuratRepository {
  _FakeSuratRepository(this._result);

  final ApiResult<void> _result;
  final List<SuratSubmission> submissions = [];

  @override
  Future<ApiResult<void>> generateLetter(SuratSubmission submission) async {
    submissions.add(submission);
    return _result;
  }
}

ProviderContainer _container(_FakeSuratRepository repository) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [suratRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('SuratSubmitNotifier', () {
    test(
      'returns success and settles to data on a successful generate',
      () async {
        final repository = _FakeSuratRepository(const Success<void>(null));
        final container = _container(repository);
        await container.read(suratSubmitProvider.future);

        final result = await container
            .read(suratSubmitProvider.notifier)
            .generate(_submission);

        expect(result, isA<Success<void>>());
        expect(repository.submissions.single.leaveTime, '14:30');
        expect(
          container.read(suratSubmitProvider),
          const AsyncData<void>(null),
        );
      },
    );

    test('returns failure and settles to error when generate fails', () async {
      final repository = _FakeSuratRepository(
        Failure(const ValidationException(message: 'Data tidak valid.')),
      );
      final container = _container(repository);
      await container.read(suratSubmitProvider.future);

      final result = await container
          .read(suratSubmitProvider.notifier)
          .generate(_submission);

      expect(result, isA<Failure<void>>());
      expect(container.read(suratSubmitProvider), isA<AsyncError<void>>());
    });
  });
}
