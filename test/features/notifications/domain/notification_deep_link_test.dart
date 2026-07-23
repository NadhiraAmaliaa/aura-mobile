import 'package:aura_mobile/features/notifications/domain/notification_deep_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationDeepLink.fromData', () {
    test('maps a leave-decision payload to a LeaveDecisionDeepLink', () {
      final link = NotificationDeepLink.fromData({
        'type': 'leave_request_decision',
        'leave_request_id': '42',
        'request_number': 'LR-20260722-0007',
        'status': 'approved',
      });

      expect(link, const LeaveDecisionDeepLink(leaveRequestId: 42));
    });

    test('parses a numeric leave_request_id sent as an int', () {
      final link = NotificationDeepLink.fromData({
        'type': 'leave_request_decision',
        'leave_request_id': 7,
      });

      expect(link, const LeaveDecisionDeepLink(leaveRequestId: 7));
    });

    test('returns null for an unknown notification type', () {
      final link = NotificationDeepLink.fromData({
        'type': 'something_else',
        'leave_request_id': '42',
      });

      expect(link, isNull);
    });

    test('returns null when the type is missing', () {
      final link = NotificationDeepLink.fromData({'leave_request_id': '42'});

      expect(link, isNull);
    });

    test('returns null when leave_request_id is missing', () {
      final link = NotificationDeepLink.fromData({
        'type': 'leave_request_decision',
      });

      expect(link, isNull);
    });

    test('returns null when leave_request_id is not numeric', () {
      final link = NotificationDeepLink.fromData({
        'type': 'leave_request_decision',
        'leave_request_id': 'not-a-number',
      });

      expect(link, isNull);
    });
  });
}
