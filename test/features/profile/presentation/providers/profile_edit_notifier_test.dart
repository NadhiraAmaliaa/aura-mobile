import 'dart:io';

import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/core/network/connectivity_providers.dart';
import 'package:aura_mobile/features/auth/data/auth_providers.dart';
import 'package:aura_mobile/features/auth/data/models/auth_models.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:aura_mobile/features/profile/presentation/providers/profile_edit_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _baseUser = UserModel(
  id: 7,
  name: 'Nadhira Amalia',
  email: 'lama@student.uny.ac.id',
  role: 'intern',
  intern: InternModel(
    id: 1,
    nim: '203040044',
    status: 'active',
    phone: '0812-0000-0000',
  ),
);

const _updatedUser = UserModel(
  id: 7,
  name: 'Nadhira Amalia',
  email: 'baru@student.uny.ac.id',
  role: 'intern',
  intern: InternModel(
    id: 1,
    nim: '203040044',
    status: 'active',
    phone: '0899-1111-2222',
  ),
);

/// A scriptable auth repository recording the contact update it receives.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._contactResult);

  final ApiResult<UserModel> _contactResult;
  final List<ContactUpdateRequest> contactRequests = [];

  @override
  Future<String?> currentToken() async => 'valid-token';

  @override
  Future<ApiResult<UserModel>> me() async => const Success(_baseUser);

  @override
  Future<UserModel?> cachedUser() async => _baseUser;

  @override
  Future<ApiResult<void>> logout() async => const Success<void>(null);

  @override
  Future<ApiResult<UserModel>> updateContact(
    ContactUpdateRequest request,
  ) async {
    contactRequests.add(request);
    return _contactResult;
  }

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) =>
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
  group('ProfileEditNotifier', () {
    test('updates the session user and settles to data on success', () async {
      final repository = _FakeAuthRepository(const Success(_updatedUser));
      final container = _container(repository);
      // Resolve the session so it is authenticated before editing.
      await container.read(authProvider.future);

      final result = await container
          .read(profileEditProvider.notifier)
          .updateContact(
            const ContactUpdateRequest(
              email: 'baru@student.uny.ac.id',
              phone: '0899-1111-2222',
            ),
          );

      expect(result, isA<Success<UserModel>>());
      expect(repository.contactRequests.single.email, 'baru@student.uny.ac.id');
      expect(container.read(profileEditProvider), const AsyncData<void>(null));

      final session = container.read(authProvider).value;
      expect(session, isA<Authenticated>());
      expect((session as Authenticated).user.email, 'baru@student.uny.ac.id');
      expect(session.user.intern?.phone, '0899-1111-2222');
    });

    test(
      'returns failure and settles to error when the update fails',
      () async {
        final repository = _FakeAuthRepository(
          Failure(
            const ValidationException(
              message: 'Data tidak valid.',
              errors: {
                'email': ['Email sudah digunakan.'],
              },
            ),
          ),
        );
        final container = _container(repository);
        await container.read(authProvider.future);

        final result = await container
            .read(profileEditProvider.notifier)
            .updateContact(const ContactUpdateRequest(email: 'x@y.com'));

        expect(result, isA<Failure<UserModel>>());
        expect(container.read(profileEditProvider), isA<AsyncError<void>>());
      },
    );

    test(
      'blocks the update and returns an offline message when disconnected',
      () async {
        final repository = _FakeAuthRepository(const Success(_updatedUser));
        final container = _container(repository, connected: false);
        await container.read(authProvider.future);

        final result = await container
            .read(profileEditProvider.notifier)
            .updateContact(const ContactUpdateRequest(email: 'x@y.com'));

        expect(result, isA<Failure<UserModel>>());
        final failure = result as Failure<UserModel>;
        expect(failure.exception, isA<NetworkException>());
        expect(failure.exception.message, contains('offline'));
        expect(repository.contactRequests, isEmpty);
      },
    );
  });
}
