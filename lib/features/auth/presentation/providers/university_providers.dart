import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/auth_providers.dart';
import '../../data/models/university_model.dart';

part 'university_providers.g.dart';

/// Universities available in the login dropdown (login-eligible interns only).
///
/// Auto-disposed so the list is refetched each time the login screen opens.
/// Surfaces failures as an `AsyncError` so the UI can offer a retry.
@riverpod
Future<List<University>> universities(Ref ref) async {
  final result = await ref.watch(lookupRepositoryProvider).universities();
  return switch (result) {
    Success(:final data) => data,
    Failure(:final exception) => throw exception,
  };
}
