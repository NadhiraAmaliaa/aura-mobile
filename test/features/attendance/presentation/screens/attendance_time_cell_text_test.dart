import 'package:aura_mobile/features/attendance/presentation/screens/attendance_history_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('attendanceTimeCellText', () {
    test('returns the recorded time when present', () {
      expect(attendanceTimeCellText('08:00', status: 'present'), '08:00');
      expect(attendanceTimeCellText('17:00', status: 'late'), '17:00');
    });

    test('shows an em dash for leave days without a time', () {
      expect(attendanceTimeCellText(null, status: 'sick'), '—');
      expect(attendanceTimeCellText(null, status: 'permission'), '—');
    });

    test('shows the neutral placeholder for non-leave days without a time', () {
      expect(attendanceTimeCellText(null, status: 'present'), '--:--');
      expect(attendanceTimeCellText(null, status: 'late'), '--:--');
      expect(attendanceTimeCellText(null, status: 'absent'), '--:--');
    });
  });
}
