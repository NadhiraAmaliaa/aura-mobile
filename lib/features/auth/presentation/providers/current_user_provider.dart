import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_notifier.dart';
import 'auth_state.dart';

part 'current_user_provider.g.dart';

/// The id of the currently authenticated user, or `null` when the session is
/// still resolving or unauthenticated.
///
/// This is the ownership key for every user-specific on-device cache (offline
/// attendance queue, dashboard snapshot). Providers that read those stores watch
/// this so a user switch rebuilds them against the new owner — account B must
/// never see account A's cached attendance.
@riverpod
int? currentUserId(Ref ref) {
  final state = ref.watch(authProvider).asData?.value;
  return state is Authenticated ? state.user.id : null;
}
