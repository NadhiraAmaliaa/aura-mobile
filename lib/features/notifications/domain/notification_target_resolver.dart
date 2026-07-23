import '../../../app/router/routes.dart';
import '../../../core/network/api_result.dart';
import '../../leave/data/repositories/leave_repository.dart';
import 'notification_deep_link.dart';

/// A resolved navigation intent: a GoRouter named route plus its path params.
typedef NotificationRouteTarget = ({
  String name,
  Map<String, String> pathParameters,
});

/// Resolves a typed [NotificationDeepLink] to a concrete navigation target,
/// validating any referenced resource against its repository first.
///
/// Kept pure with respect to navigation — it returns a target instead of
/// navigating — so it can be unit-tested against fake repositories. The handler
/// provider is a thin glue layer that feeds this result to the router.
///
/// The `switch` is exhaustive over the sealed [NotificationDeepLink]; a new
/// notification variant will not compile until it is resolved here too.
Future<NotificationRouteTarget> resolveNotificationTarget(
  NotificationDeepLink link, {
  required LeaveRepository leaveRepository,
}) async {
  switch (link) {
    case LeaveDecisionDeepLink(:final leaveRequestId):
      // Pre-validate existence: a decided request the intern can still load
      // opens its detail page; anything else (deleted, revoked access, or a
      // transient load failure) falls back to the Leave History list.
      final result = await leaveRepository.detail(leaveRequestId);
      return result.fold(
        onSuccess: (_) => (
          name: RouteNames.leaveDetail,
          pathParameters: {'id': '$leaveRequestId'},
        ),
        onFailure: (_) => (
          name: RouteNames.leaveHistory,
          pathParameters: const <String, String>{},
        ),
      );
  }
}
