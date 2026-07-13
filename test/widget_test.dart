import 'package:aura_mobile/app/app.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/auth/data/auth_providers.dart';
import 'package:aura_mobile/features/auth/data/models/auth_models.dart';
import 'package:aura_mobile/features/auth/data/models/university_model.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/data/repositories/lookup_repository.dart';
import 'package:aura_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// No stored token -> the app resolves to the login screen. Other methods are
/// unused by the smoke test.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<String?> currentToken() async => null;

  @override
  Future<ApiResult<UserModel>> login(LoginRequest request) async =>
      Failure(const UnknownException());

  @override
  Future<ApiResult<UserModel>> me() async => Failure(const UnknownException());

  @override
  Future<ApiResult<void>> logout() async => const Success<void>(null);

  @override
  Future<UserModel?> cachedUser() async => null;
}

/// Returns an empty list synchronously so the dropdown resolves to its data
/// state (no infinite spinner) and `pumpAndSettle` can settle.
class _FakeLookupRepository implements LookupRepository {
  @override
  Future<ApiResult<List<University>>> universities() async =>
      const Success(<University>[]);
}

void main() {
  testWidgets('AuraApp resolves to the login screen without a session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          lookupRepositoryProvider.overrideWithValue(_FakeLookupRepository()),
        ],
        child: const AuraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Username (NIM)'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
