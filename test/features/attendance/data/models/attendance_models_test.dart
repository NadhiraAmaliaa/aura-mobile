import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests locking the JSON shape the backend emits for
/// `GET /attendance/dashboard`.
///
/// The backend serializes coordinates from a `decimal:7` cast, so they arrive
/// as JSON *strings* (e.g. `"3.5952000"`), not numbers. These tests parse a
/// realistic envelope and assert the decoded types, guarding against contract
/// drift that `flutter analyze` cannot catch (it only fails at runtime).
void main() {
  group('AttendanceDashboardEnvelope.fromJson', () {
    // Mirrors the exact AttendanceController::dashboard() output for an intern
    // who has checked in (present, WFO) with the monthly recap.
    final dashboardJson = <String, dynamic>{
      'data': <String, dynamic>{
        'today': <String, dynamic>{
          'date': '2026-07-06',
          'is_working_day': true,
          'work_hours': <String, dynamic>{'start': '08:00', 'end': '17:00'},
          'attendance': <String, dynamic>{
            'id': 42,
            'attendance_date': '2026-07-06',
            'check_in_time': '07:58',
            'check_out_time': null,
            'check_in_latitude': '3.5952000',
            'check_in_longitude': '98.6722000',
            'check_out_latitude': null,
            'check_out_longitude': null,
            'status': 'present',
            'status_label': 'Hadir',
            'work_mode': 'wfo',
            'work_mode_label': 'Work From Office',
          },
          'leave': null,
        },
        'summary': <String, dynamic>{
          'month': '2026-07',
          'hadir': 4,
          'terlambat': 1,
          'izin': 0,
          'sakit': 0,
          'dinas': 1,
          'tidak_absen': 0,
        },
      },
    };

    test('parses the canonical dashboard payload without throwing', () {
      final envelope = AttendanceDashboardEnvelope.fromJson(dashboardJson);
      final today = envelope.data.today;

      expect(today.date, '2026-07-06');
      expect(today.isWorkingDay, isTrue);
      expect(today.workHours.start, '08:00');
      expect(today.workHours.end, '17:00');
      expect(today.leave, isNull);
    });

    test('decodes the attendance record with string coordinates', () {
      final attendance =
          AttendanceDashboardEnvelope.fromJson(dashboardJson).data.today.attendance;

      expect(attendance, isNotNull);
      expect(attendance!.id, 42);
      expect(attendance.checkInTime, '07:58');
      expect(attendance.checkOutTime, isNull);
      expect(attendance.checkInLatitude, '3.5952000');
      expect(attendance.checkInLongitude, '98.6722000');
      expect(attendance.status, 'present');
      expect(attendance.statusLabel, 'Hadir');
      expect(attendance.workMode, 'wfo');
      expect(attendance.workModeLabel, 'Work From Office');
    });

    test('decodes the monthly recap counts', () {
      final summary =
          AttendanceDashboardEnvelope.fromJson(dashboardJson).data.summary;

      expect(summary.month, '2026-07');
      expect(summary.hadir, 4);
      expect(summary.terlambat, 1);
      expect(summary.izin, 0);
      expect(summary.sakit, 0);
      expect(summary.dinas, 1);
      expect(summary.tidakAbsen, 0);
    });

    test('handles a non-working day with no record or leave', () {
      final json = <String, dynamic>{
        'data': <String, dynamic>{
          'today': <String, dynamic>{
            'date': '2026-07-11',
            'is_working_day': false,
            'work_hours': <String, dynamic>{'start': null, 'end': null},
            'attendance': null,
            'leave': null,
          },
          'summary': <String, dynamic>{'month': '2026-07'},
        },
      };

      final dashboard = AttendanceDashboardEnvelope.fromJson(json).data;

      expect(dashboard.today.isWorkingDay, isFalse);
      expect(dashboard.today.workHours.start, isNull);
      expect(dashboard.today.attendance, isNull);
      // Counts default to zero when the backend omits them.
      expect(dashboard.summary.hadir, 0);
      expect(dashboard.summary.tidakAbsen, 0);
    });

    test('decodes an approved leave covering today', () {
      final json = <String, dynamic>{
        'data': <String, dynamic>{
          'today': <String, dynamic>{
            'date': '2026-07-07',
            'is_working_day': true,
            'work_hours': <String, dynamic>{'start': '08:00', 'end': '17:00'},
            'attendance': null,
            'leave': <String, dynamic>{'type': 'sakit', 'type_label': 'Sakit'},
          },
          'summary': <String, dynamic>{'month': '2026-07', 'sakit': 1},
        },
      };

      final leave = AttendanceDashboardEnvelope.fromJson(json).data.today.leave;

      expect(leave, isNotNull);
      expect(leave!.type, 'sakit');
      expect(leave.typeLabel, 'Sakit');
    });
  });
}
