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
import 'package:aura_mobile/features/profile/presentation/providers/avatar_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _baseUser = UserModel(
  id: 7,
  name: 'Nadhira Amalia',
  email: 'nadhira@student.uny.ac.id',
  role: 'intern',
  intern: InternModel(id: 1, nim: '203040044', status: 'active'),
);

const _withPhoto = UserModel(
  id: 7,
  name: 'Nadhira Amalia',
  email: 'nadhira@student.uny.ac.id',
  avatarUrl: 'https://example.test/storage/avatars/new.jpg',
  role: 'intern',
  intern: InternModel(id: 1, nim: '203040044', status: 'active'),
);

/// A scriptable auth repository recording the avatar calls it receives.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.uploadResult = const Success(_withPhoto)});

  final ApiResult<UserModel> uploadResult;
  final ApiResult<UserModel> deleteResult = const Success(_baseUser);
  int uploads = 0;
  int deletes = 0;

  @override
  Future<ApiResult<UserModel>> updateAvatar(File photo) async {
    uploads++;
    return uploadResult;
  }

  @override
  Future<ApiResult<UserModel>> deleteAvatar() async {
    deletes++;
    return deleteResult;
  }

  @override
  Future<String?> currentToken() async => 'valid-token';

  @override
  Future<ApiResult<UserModel>> me() async => const Success(_baseUser);

  @override
  Future<UserModel?> cachedUser() async => _baseUser;

  @override
  Future<ApiResult<void>> logout() async => const Success<void>(null);

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserModel>> updateContact(ContactUpdateRequest request) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> updatePassword(PasswordUpdateRequest request) =>
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
  group('AvatarNotifier', () {
    test('uploads the photo and refreshes the session user', () async {
      final repository = _FakeAuthRepository();
      final container = _container(repository);
      await container.read(authProvider.future);

      final result = await container
          .read(avatarProvider.notifier)
          .upload(File('avatar.jpg'));

      expect(result, isA<Success<UserModel>>());
      expect(repository.uploads, 1);
      expect(container.read(avatarProvider), const AsyncData<void>(null));

      final session = container.read(authProvider).value;
      expect(session, isA<Authenticated>());
      expect(
        (session as Authenticated).user.avatarUrl,
        'https://example.test/storage/avatars/new.jpg',
      );
    });

    test('removes the photo and refreshes the session user', () async {
      final repository = _FakeAuthRepository();
      final container = _container(repository);
      await container.read(authProvider.future);

      final result = await container.read(avatarProvider.notifier).remove();

      expect(result, isA<Success<UserModel>>());
      expect(repository.deletes, 1);

      final session = container.read(authProvider).value;
      expect((session as Authenticated).user.avatarUrl, isNull);
    });

    test('settles to error when the upload fails', () async {
      final repository = _FakeAuthRepository(
        uploadResult: Failure(
          const ValidationException(
            message: 'Data tidak valid.',
            errors: {
              'photo': ['Ukuran foto maksimal 5 MB.'],
            },
          ),
        ),
      );
      final container = _container(repository);
      await container.read(authProvider.future);

      final result = await container
          .read(avatarProvider.notifier)
          .upload(File('big.jpg'));

      expect(result, isA<Failure<UserModel>>());
      expect(container.read(avatarProvider), isA<AsyncError<void>>());
    });

    test(
      'blocks the upload and returns an offline message when disconnected',
      () async {
        final repository = _FakeAuthRepository();
        final container = _container(repository, connected: false);
        await container.read(authProvider.future);

        final result = await container
            .read(avatarProvider.notifier)
            .upload(File('avatar.jpg'));

        expect(result, isA<Failure<UserModel>>());
        expect(repository.uploads, 0);
        final error = (result as Failure<UserModel>).exception;
        expect(error, isA<NetworkException>());
        expect(error.message.toLowerCase(), contains('offline'));
      },
    );
  });
}
