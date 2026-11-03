import 'package:aura_mobile/features/attendance/presentation/attendance_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('attendanceDateKey', () {
    test('formats the local date like the dashboard date', () {
      expect(attendanceDateKey(DateTime(2026, 7, 4, 23, 59)), '2026-07-04');
      expect(attendanceDateKey(DateTime(2026, 11, 30)), '2026-11-30');
    });

    test('uses the local calendar day of a UTC instant', () {
      final localEarlyMorning = DateTime(2026, 10, 31, 3, 20);
      expect(attendanceDateKey(localEarlyMorning.toUtc()), '2026-10-31');
    });
  });

  group('isOtherAttendanceDay', () {
    test('is false for a snapshot of the current date', () {
      expect(isOtherAttendanceDay('2026-10-31', '2026-10-31'), isFalse);
    });

    test('is true for a snapshot cached on another date', () {
      expect(isOtherAttendanceDay('2026-10-30', '2026-10-31'), isTrue);
    });

    test('never marks a snapshot stale without a trusted date', () {
      expect(isOtherAttendanceDay('2026-10-30', null), isFalse);
    });
  });
}
