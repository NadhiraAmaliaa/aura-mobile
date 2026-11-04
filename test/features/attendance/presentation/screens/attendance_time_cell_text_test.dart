import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/screens/attendance_history_screen.dart';
import 'package:flutter_test/flutter_test.dart';

AttendanceModel _record({
  String? date = '2026-09-18',
  String? checkIn,
  String? checkOut,
  String status = 'present',
  String statusLabel = 'Hadir',
}) => AttendanceModel(
  id: 1,
  attendanceDate: date,
  checkInTime: checkIn,
  checkOutTime: checkOut,
  status: status,
  statusLabel: statusLabel,
);

void main() {
  group('attendanceHistoryRowText', () {
    test('splits the date into the day number and Indonesian weekday', () {
      final text = attendanceHistoryRowText(
        _record(checkIn: '07:52', checkOut: '15:01'),
      );

      expect(text.day, '18');
      expect(text.weekday, 'Jumat');
      expect(text.checkIn, '07:52');
      expect(text.checkOut, '15:01');
      expect(text.statusLabel, isNull);
    });

    test('uses the single-digit day without padding', () {
      final text = attendanceHistoryRowText(_record(date: '2026-06-01'));

      expect(text.day, '1');
      expect(text.weekday, 'Senin');
    });

    test('shows the placeholder for a missing check-out', () {
      final text = attendanceHistoryRowText(_record(checkIn: '07:23'));

      expect(text.checkIn, '07:23');
      expect(text.checkOut, attendanceMissingTime);
      expect(text.statusLabel, isNull);
    });

    test('shows the placeholder for a missing check-in', () {
      final text = attendanceHistoryRowText(_record(checkOut: '17:00'));

      expect(text.checkIn, attendanceMissingTime);
      expect(text.checkOut, '17:00');
    });

    test(
      'shows the backend label for leave and absence days without times',
      () {
        for (final (status, label) in [
          ('sick', 'Sakit'),
          ('permission', 'Izin'),
          ('absent', 'Alpha'),
        ]) {
          final text = attendanceHistoryRowText(
            _record(status: status, statusLabel: label),
          );

          expect(text.statusLabel, label, reason: status);
          expect(text.checkIn, isNull, reason: status);
          expect(text.checkOut, isNull, reason: status);
        }
      },
    );

    test('never invents a status for a present record without times', () {
      final text = attendanceHistoryRowText(_record());

      expect(text.statusLabel, isNull);
      expect(text.checkIn, attendanceMissingTime);
      expect(text.checkOut, attendanceMissingTime);
    });

    test('keeps recorded times even when the status is a leave status', () {
      final text = attendanceHistoryRowText(
        _record(checkIn: '08:10', status: 'permission', statusLabel: 'Izin'),
      );

      expect(text.statusLabel, isNull);
      expect(text.checkIn, '08:10');
      expect(text.checkOut, attendanceMissingTime);
    });

    test('tolerates a missing date', () {
      final text = attendanceHistoryRowText(_record(date: null));

      expect(text.day, '-');
      expect(text.weekday, '');
    });
  });
}
