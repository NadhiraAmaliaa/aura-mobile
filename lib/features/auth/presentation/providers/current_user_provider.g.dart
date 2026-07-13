// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The id of the currently authenticated user, or `null` when the session is
/// still resolving or unauthenticated.
///
/// This is the ownership key for every user-specific on-device cache (offline
/// attendance queue, dashboard snapshot). Providers that read those stores watch
/// this so a user switch rebuilds them against the new owner — account B must
/// never see account A's cached attendance.

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// The id of the currently authenticated user, or `null` when the session is
/// still resolving or unauthenticated.
///
/// This is the ownership key for every user-specific on-device cache (offline
/// attendance queue, dashboard snapshot). Providers that read those stores watch
/// this so a user switch rebuilds them against the new owner — account B must
/// never see account A's cached attendance.

final class CurrentUserIdProvider extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// The id of the currently authenticated user, or `null` when the session is
  /// still resolving or unauthenticated.
  ///
  /// This is the ownership key for every user-specific on-device cache (offline
  /// attendance queue, dashboard snapshot). Providers that read those stores watch
  /// this so a user switch rebuilds them against the new owner — account B must
  /// never see account A's cached attendance.
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return currentUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$currentUserIdHash() => r'a68fdd2edfeea9b2cb0da762f24bf206bcc82723';
