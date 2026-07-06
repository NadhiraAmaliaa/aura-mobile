import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/user_model.dart';

part 'auth_state.freezed.dart';

/// Resolved session state. The "resolving" phase is represented by the
/// surrounding `AsyncValue` (loading) on [AuthNotifier], not a variant here.
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.authenticated(UserModel user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
}
