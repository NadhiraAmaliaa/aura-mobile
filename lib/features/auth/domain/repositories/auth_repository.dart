import '../../../../core/network/api_result.dart';
import '../../data/models/auth_models.dart';
import '../../data/models/user_model.dart';

/// Abstract auth boundary — the seam the presentation layer depends on and the
/// point tests override with a fake.
///
/// Deviation note (documented in the summary): the app does not introduce
/// separate domain entities for auth. A 1:1 entity mirror of the user DTO would
/// be ceremony without payoff (see architecture doc §3.1 / §10), so the data
/// DTOs cross this boundary directly. The abstract repository is still kept
/// here in `domain/` to preserve the documented testing seam.
abstract interface class AuthRepository {
  /// Authenticates the intern and persists the issued token on success.
  Future<ApiResult<UserModel>> login(LoginRequest request);

  /// Returns the currently authenticated user (used on cold-start restore).
  Future<ApiResult<UserModel>> me();

  /// Revokes the server token and clears the local token (best effort).
  Future<ApiResult<void>> logout();

  /// The persisted bearer token, if any.
  Future<String?> currentToken();

  /// The last authenticated user cached on-device, if any. Used to restore the
  /// session on cold start when the backend is unreachable.
  Future<UserModel?> cachedUser();
}
