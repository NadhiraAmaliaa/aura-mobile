import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests locking the JSON shape the backend emits for
/// `GET /attendance/history` — the paginated list plus its pagination block.
void main() {
  group('AttendanceHistoryEnvelope.fromJson', () {
    final historyJson = <String, dynamic>{
      'data': <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 42,
            'attendance_date': '2026-07-06',
            'check_in_time': '07:58',
            'check_out_time': '17:02',
            'check_in_latitude': '3.5952000',
            'check_in_longitude': '98.6722000',
            'check_out_latitude': null,
            'check_out_longitude': null,
            'status': 'present',
            'status_label': 'Hadir',
            'work_mode': 'wfo',
            'work_mode_label': 'Work From Office',
          },
          <String, dynamic>{
            'id': 41,
            'attendance_date': '2026-07-03',
            'check_in_time': '08:30',
            'check_out_time': null,
            'check_in_latitude': null,
            'check_in_longitude': null,
            'check_out_latitude': null,
            'check_out_longitude': null,
            'status': 'late',
            'status_label': 'Terlambat',
            'work_mode': 'wfh',
            'work_mode_label': 'Work From Home',
          },
        ],
        'pagination': <String, dynamic>{
          'current_page': 1,
          'per_page': 15,
          'total': 20,
          'last_page': 2,
          'has_more': true,
        },
      },
    };

    test('parses the page items newest-first without throwing', () {
      final page = AttendanceHistoryEnvelope.fromJson(historyJson).data;

      expect(page.items, hasLength(2));
      expect(page.items.first.id, 42);
      expect(page.items.first.attendanceDate, '2026-07-06');
      expect(page.items.first.status, 'present');
      expect(page.items.last.status, 'late');
      expect(page.items.last.checkOutTime, isNull);
    });

    test('decodes the pagination metadata', () {
      final pagination =
          AttendanceHistoryEnvelope.fromJson(historyJson).data.pagination;

      expect(pagination.currentPage, 1);
      expect(pagination.perPage, 15);
      expect(pagination.total, 20);
      expect(pagination.lastPage, 2);
      expect(pagination.hasMore, isTrue);
    });

    test('defaults items to an empty list when omitted', () {
      final json = <String, dynamic>{
        'data': <String, dynamic>{
          'pagination': <String, dynamic>{
            'current_page': 1,
            'per_page': 15,
            'total': 0,
            'last_page': 1,
            'has_more': false,
          },
        },
      };

      final page = AttendanceHistoryEnvelope.fromJson(json).data;

      expect(page.items, isEmpty);
      expect(page.pagination.hasMore, isFalse);
    });
  });
}
