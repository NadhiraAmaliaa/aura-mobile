import 'package:flutter/foundation.dart';

/// A parsed, navigable intent extracted from an FCM message's `data` payload.
///
/// This is the single, reusable mapping from raw notification data to a typed
/// deep link. New notification types are added as a new variant plus a new case
/// in [NotificationDeepLink.fromData]; downstream code switches over the sealed
/// type, so the compiler flags every place that must handle the new variant.
@immutable
sealed class NotificationDeepLink {
  const NotificationDeepLink();

  /// Maps a raw FCM `data` payload to a typed deep link, or `null` when the
  /// payload carries no recognised, actionable link — an unknown `type` or a
  /// missing / malformed field. Callers treat `null` as "no navigation".
  ///
  /// Payload values arrive as strings over FCM, so numeric fields are parsed
  /// defensively.
  static NotificationDeepLink? fromData(Map<String, dynamic> data) {
    switch (data['type']) {
      case LeaveDecisionDeepLink.type:
        final id = int.tryParse('${data['leave_request_id']}');
        if (id == null) return null;
        return LeaveDecisionDeepLink(leaveRequestId: id);
      default:
        return null;
    }
  }
}

/// A tap on an approval / rejection notification for a leave request. Targets
/// the corresponding leave-request detail page.
final class LeaveDecisionDeepLink extends NotificationDeepLink {
  const LeaveDecisionDeepLink({required this.leaveRequestId});

  /// The backend `data.type` discriminator this link is built from.
  static const String type = 'leave_request_decision';

  final int leaveRequestId;

  @override
  bool operator ==(Object other) =>
      other is LeaveDecisionDeepLink &&
      other.leaveRequestId == leaveRequestId;

  @override
  int get hashCode => leaveRequestId.hashCode;
}
