import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/auth/data/auth_providers.dart';
import 'package:aura_mobile/features/auth/data/models/auth_models.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura_mobile/features/profile/presentation/providers/change_password_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _request = PasswordUpdateRequest(
  currentPassword: 'old-password',
  password: 'new-password',
  passwordConfirmation: 'new-password',
);

/// A scriptable auth repository recording the password update it receives.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._result);

  final ApiResult<void> _result;
  final List<PasswordUpdateRequest> passwordRequests = [];

  @override
  Future<ApiResult<void>> updatePassword(PasswordUpdateRequest request) async {
    passwordRequests.add(request);
    return _result;
  }

  @override
  Future<String?> currentToken() async => 'valid-token';

  @override
  Future<ApiResult<UserModel>> me() => throw UnimplementedError();

  @override
  Future<UserModel?> cachedUser() async => null;

  @override
  Future<ApiResult<void>> logout() async => const Success<void>(null);

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserModel>> updateContact(ContactUpdateRequest request) =>
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
  _FakeAuthRepository repository, {
  bool connected = true,
}) {
  return ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      connectivityProvider.overrideWithValue(
        _FakeConnectivity(connected: connected),
      ),
    ],
  );
}

void main() {
  group('ChangePasswordNotifier', () {
    test(
      'returns success and settles to data on a successful change',
      () async {
        final repository = _FakeAuthRepository(const Success<void>(null));
        final container = _container(repository);
        await container.read(changePasswordProvider.future);

        final result = await container
            .read(changePasswordProvider.notifier)
            .submit(_request);

        expect(result, isA<Success<void>>());
        expect(
          repository.passwordRequests.single.currentPassword,
          'old-password',
        );
        expect(
          container.read(changePasswordProvider),
          const AsyncData<void>(null),
        );
      },
    );

    test(
      'returns failure and settles to error when the change fails',
      () async {
        final repository = _FakeAuthRepository(
          Failure(
            const ValidationException(
              message: 'Data tidak valid.',
              errors: {
                'current_password': ['Kata sandi saat ini salah.'],
              },
            ),
          ),
        );
        final container = _container(repository);
        await container.read(changePasswordProvider.future);

        final result = await container
            .read(changePasswordProvider.notifier)
            .submit(_request);

        expect(result, isA<Failure<void>>());
        expect(container.read(changePasswordProvider), isA<AsyncError<void>>());
      },
    );

    test(
      'blocks the change and returns an offline message when disconnected',
      () async {
        final repository = _FakeAuthRepository(const Success<void>(null));
        final container = _container(repository, connected: false);
        await container.read(changePasswordProvider.future);

        final result = await container
            .read(changePasswordProvider.notifier)
            .submit(_request);

        expect(result, isA<Failure<void>>());
        final failure = result as Failure<void>;
        expect(failure.exception, isA<NetworkException>());
        expect(failure.exception.message, contains('offline'));
        expect(repository.passwordRequests, isEmpty);
      },
    );
  });
}
