import 'package:aura_mobile/features/attendance/presentation/attendance_month.dart';
import 'package:flutter_test/flutter_test.dart';

import 'history_test_support.dart';

void main() {
  group('parseAttendanceMonth', () {
    test('parses month keys and dates', () {
      expect(parseAttendanceMonth('2026-09'), (year: 2026, month: 9));
      expect(parseAttendanceMonth('2026-09-18'), (year: 2026, month: 9));
    });

    test('rejects missing or malformed values', () {
      for (final value in [null, '', '2026-13', '2026-00', '2026-9', 'juli']) {
        expect(parseAttendanceMonth(value), isNull, reason: '$value');
      }
    });
  });

  test('shiftAttendanceMonth crosses year boundaries', () {
    expect(shiftAttendanceMonth('2026-01', -1), '2025-12');
    expect(shiftAttendanceMonth('2025-12', 1), '2026-01');
    expect(shiftAttendanceMonth('2026-09', -11), '2025-10');
  });

  test('formatAttendanceMonth uses Indonesian month names', () {
    expect(formatAttendanceMonth('2026-09'), 'September 2026');
    expect(formatAttendanceMonth('2026-08'), 'Agustus 2026');
    expect(formatAttendanceMonth('bad'), 'bad');
  });

  group('initialHistoryMonth', () {
    final now = DateTime(2030, 1, 15);

    test('prefers the trusted date', () {
      expect(
        initialHistoryMonth(
          trustedDate: '2026-09-18',
          dashboardMonth: '2026-08',
          now: now,
        ),
        '2026-09',
      );
    });

    test('falls back to the dashboard month, then the device clock', () {
      expect(
        initialHistoryMonth(dashboardMonth: '2026-08', now: now),
        '2026-08',
      );
      expect(initialHistoryMonth(now: now), '2030-01');
    });
  });

  group('historyMonthRange', () {
    test('runs from the internship start month to the latest month', () {
      expect(
        historyMonthRange(latest: '2026-09', internStartDate: '2026-02-16'),
        (first: '2026-02', last: '2026-09'),
      );
    });

    test('offers twelve months without a start date', () {
      expect(historyMonthRange(latest: '2026-09'), (
        first: '2025-10',
        last: '2026-09',
      ));
    });

    test('offers only the latest month before the internship starts', () {
      expect(
        historyMonthRange(latest: '2026-09', internStartDate: '2026-11-01'),
        (first: '2026-09', last: '2026-09'),
      );
    });
  });

  test('attendanceItemsInMonth checks every record date', () {
    expect(
      attendanceItemsInMonth(monthRecords('2026-09', 3), '2026-09'),
      isTrue,
    );
    expect(attendanceItemsInMonth(const [], '2026-09'), isTrue);
    expect(
      attendanceItemsInMonth([
        historyRecord('2026-09-01'),
        historyRecord('2026-08-31'),
      ], '2026-09'),
      isFalse,
    );
  });
}
