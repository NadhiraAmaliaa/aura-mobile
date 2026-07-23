// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_deep_link_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single owner of notification-tap navigation ("deep linking").
///
/// Armed once by the root widget for the whole app session. It owns both tap
/// entry points — [FirebaseMessaging.getInitialMessage] (app launched from a
/// terminated state) and [FirebaseMessaging.onMessageOpenedApp] (tap while
/// backgrounded) — so there is exactly one consumer of each; the foreground
/// [FcmService] deliberately no longer touches them.
///
/// A tapped notification is mapped to a typed [NotificationDeepLink] and held
/// as a pending intent. Navigation is deferred until the router would actually
/// allow an authenticated destination — session resolved, signed in, and the
/// offline bootstrap ready — because a terminated-state launch resolves its
/// initial message before auth/bootstrap finish, and navigating early would be
/// undone by the router's redirect. Watching the auth and bootstrap providers
/// re-runs [build] when readiness changes, at which point the pending intent is
/// flushed.
///
/// Generic by design: adding a notification type is a new variant in
/// [NotificationDeepLink] and a case in [resolveNotificationTarget]; this
/// handler needs no changes.

@ProviderFor(NotificationDeepLinkHandler)
final notificationDeepLinkHandlerProvider =
    NotificationDeepLinkHandlerProvider._();

/// Single owner of notification-tap navigation ("deep linking").
///
/// Armed once by the root widget for the whole app session. It owns both tap
/// entry points — [FirebaseMessaging.getInitialMessage] (app launched from a
/// terminated state) and [FirebaseMessaging.onMessageOpenedApp] (tap while
/// backgrounded) — so there is exactly one consumer of each; the foreground
/// [FcmService] deliberately no longer touches them.
///
/// A tapped notification is mapped to a typed [NotificationDeepLink] and held
/// as a pending intent. Navigation is deferred until the router would actually
/// allow an authenticated destination — session resolved, signed in, and the
/// offline bootstrap ready — because a terminated-state launch resolves its
/// initial message before auth/bootstrap finish, and navigating early would be
/// undone by the router's redirect. Watching the auth and bootstrap providers
/// re-runs [build] when readiness changes, at which point the pending intent is
/// flushed.
///
/// Generic by design: adding a notification type is a new variant in
/// [NotificationDeepLink] and a case in [resolveNotificationTarget]; this
/// handler needs no changes.
final class NotificationDeepLinkHandlerProvider
    extends $AsyncNotifierProvider<NotificationDeepLinkHandler, void> {
  /// Single owner of notification-tap navigation ("deep linking").
  ///
  /// Armed once by the root widget for the whole app session. It owns both tap
  /// entry points — [FirebaseMessaging.getInitialMessage] (app launched from a
  /// terminated state) and [FirebaseMessaging.onMessageOpenedApp] (tap while
  /// backgrounded) — so there is exactly one consumer of each; the foreground
  /// [FcmService] deliberately no longer touches them.
  ///
  /// A tapped notification is mapped to a typed [NotificationDeepLink] and held
  /// as a pending intent. Navigation is deferred until the router would actually
  /// allow an authenticated destination — session resolved, signed in, and the
  /// offline bootstrap ready — because a terminated-state launch resolves its
  /// initial message before auth/bootstrap finish, and navigating early would be
  /// undone by the router's redirect. Watching the auth and bootstrap providers
  /// re-runs [build] when readiness changes, at which point the pending intent is
  /// flushed.
  ///
  /// Generic by design: adding a notification type is a new variant in
  /// [NotificationDeepLink] and a case in [resolveNotificationTarget]; this
  /// handler needs no changes.
  NotificationDeepLinkHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationDeepLinkHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationDeepLinkHandlerHash();

  @$internal
  @override
  NotificationDeepLinkHandler create() => NotificationDeepLinkHandler();
}

String _$notificationDeepLinkHandlerHash() =>
    r'2ccf285920a4b6a8ad43fd5c03dfbb7de617ecc2';

/// Single owner of notification-tap navigation ("deep linking").
///
/// Armed once by the root widget for the whole app session. It owns both tap
/// entry points — [FirebaseMessaging.getInitialMessage] (app launched from a
/// terminated state) and [FirebaseMessaging.onMessageOpenedApp] (tap while
/// backgrounded) — so there is exactly one consumer of each; the foreground
/// [FcmService] deliberately no longer touches them.
///
/// A tapped notification is mapped to a typed [NotificationDeepLink] and held
/// as a pending intent. Navigation is deferred until the router would actually
/// allow an authenticated destination — session resolved, signed in, and the
/// offline bootstrap ready — because a terminated-state launch resolves its
/// initial message before auth/bootstrap finish, and navigating early would be
/// undone by the router's redirect. Watching the auth and bootstrap providers
/// re-runs [build] when readiness changes, at which point the pending intent is
/// flushed.
///
/// Generic by design: adding a notification type is a new variant in
/// [NotificationDeepLink] and a case in [resolveNotificationTarget]; this
/// handler needs no changes.

abstract class _$NotificationDeepLinkHandler extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
