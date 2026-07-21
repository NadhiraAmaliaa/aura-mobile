import 'dart:io';

import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/auth/data/auth_providers.dart';
import 'package:aura_mobile/features/auth/data/models/auth_models.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A scriptable auth repository: a stored token, a scripted `/auth/me` result,
/// and an optional cached profile. Records whether the session was cleared.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.token, required this.meResult, this.cached});

  String? token;
  ApiResult<UserModel> meResult;
  UserModel? cached;
  bool loggedOut = false;

  @override
  Future<String?> currentToken() async => token;

  @override
  Future<ApiResult<UserModel>> me() async => meResult;

  @override
  Future<UserModel?> cachedUser() async => cached;

  @override
  Future<ApiResult<void>> logout() async {
    loggedOut = true;
    token = null;
    cached = null;
    return const Success<void>(null);
  }

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserModel>> updateContact(ContactUpdateRequest request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> updatePassword(PasswordUpdateRequest request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserModel>> updateAvatar(File photo) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserModel>> deleteAvatar() => throw UnimplementedError();
}

const _user = UserModel(id: 7, name: 'Intern Satu', role: 'intern');

ProviderContainer _containerFor(_FakeAuthRepository repository) {
  return ProviderContainer.test(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('AuthNotifier.build (cold-start session restore)', () {
    test(
      'restores the cached session when the backend is unreachable',
      () async {
        final repository = _FakeAuthRepository(
          token: 'valid-token',
          meResult: Failure(const NetworkException()),
          cached: _user,
        );
        final container = _containerFor(repository);

        final state = await container.read(authProvider.future);

        expect(state, isA<Authenticated>());
        expect((state as Authenticated).user, _user);
        // A transient failure must never clear a previously valid session.
        expect(repository.loggedOut, isFalse);
        expect(repository.token, 'valid-token');
      },
    );

    test('logs the user out when the server explicitly returns 401', () async {
      final repository = _FakeAuthRepository(
        token: 'expired-token',
        meResult: Failure(const UnauthorizedException()),
        cached: _user,
      );
      final container = _containerFor(repository);

      final state = await container.read(authProvider.future);

      expect(state, isA<Unauthenticated>());
      // Session cleared even though a cached profile existed.
      expect(repository.loggedOut, isTrue);
    });

    test('authenticates from a successful /auth/me', () async {
      final repository = _FakeAuthRepository(
        token: 'valid-token',
        meResult: const Success(_user),
      );
      final container = _containerFor(repository);

      final state = await container.read(authProvider.future);

      expect(state, isA<Authenticated>());
      expect((state as Authenticated).user, _user);
      expect(repository.loggedOut, isFalse);
    });

    test('stays unauthenticated when there is no stored token', () async {
      final repository = _FakeAuthRepository(
        token: null,
        meResult: Failure(const NetworkException()),
        cached: _user,
      );
      final container = _containerFor(repository);

      final state = await container.read(authProvider.future);

      expect(state, isA<Unauthenticated>());
    });

    test(
      'is unauthenticated offline when no profile has been cached yet',
      () async {
        final repository = _FakeAuthRepository(
          token: 'valid-token',
          meResult: Failure(const RequestTimeoutException()),
          cached: null,
        );
        final container = _containerFor(repository);

        final state = await container.read(authProvider.future);

        expect(state, isA<Unauthenticated>());
        // Token is preserved (not a 401), so a later online launch can validate.
        expect(repository.loggedOut, isFalse);
      },
    );
  });
}
