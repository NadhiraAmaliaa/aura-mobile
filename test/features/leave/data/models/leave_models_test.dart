import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests: the leave DTOs must parse the exact JSON the backend
/// `LeaveRequestResource` and index/detail envelopes emit.
void main() {
  group('LeaveRequestModel.fromJson', () {
    test('maps every snake_case field from an approved request', () {
      final json = {
        'id': 12,
        'request_number': 'LR-20260706-0003',
        'type': 'izin',
        'type_label': 'Izin',
        'reason': 'Acara keluarga',
        'start_date': '2026-07-06',
        'end_date': '2026-07-07',
        'total_days': 2,
        'contact_phone': '08123456789',
        'address': 'Jl. Melati No. 1',
        'evidence_url': 'https://aura.test/storage/leave-evidence/a.pdf',
        'status': 'approved',
        'status_label': 'Disetujui',
        'admin_note': null,
        'approver_name': 'Budi',
        'approved_at': '2026-07-05T10:00:00+07:00',
        'can_download_pdf': true,
        'created_at': '2026-07-04T09:00:00+07:00',
      };

      final model = LeaveRequestModel.fromJson(json);

      expect(model.id, 12);
      expect(model.requestNumber, 'LR-20260706-0003');
      expect(model.type, 'izin');
      expect(model.typeLabel, 'Izin');
      expect(model.reason, 'Acara keluarga');
      expect(model.startDate, '2026-07-06');
      expect(model.endDate, '2026-07-07');
      expect(model.totalDays, 2);
      expect(model.contactPhone, '08123456789');
      expect(model.address, 'Jl. Melati No. 1');
      expect(model.evidenceUrl, contains('leave-evidence'));
      expect(model.status, 'approved');
      expect(model.statusLabel, 'Disetujui');
      expect(model.adminNote, isNull);
      expect(model.approverName, 'Budi');
      expect(model.approvedAt, '2026-07-05T10:00:00+07:00');
      expect(model.canDownloadPdf, isTrue);
      expect(model.createdAt, '2026-07-04T09:00:00+07:00');
    });

    test('defaults canDownloadPdf to false and tolerates null optionals', () {
      final json = {
        'id': 1,
        'request_number': 'LR-20260706-0001',
        'type': 'sakit',
        'type_label': 'Sakit',
        'reason': 'Demam',
        'start_date': '2026-07-06',
        'end_date': '2026-07-06',
        'total_days': 1,
        'contact_phone': null,
        'address': null,
        'evidence_url': null,
        'status': 'pending',
        'status_label': 'Menunggu',
        'admin_note': null,
        'approver_name': null,
        'approved_at': null,
        'created_at': null,
      };

      final model = LeaveRequestModel.fromJson(json);

      expect(model.canDownloadPdf, isFalse);
      expect(model.evidenceUrl, isNull);
      expect(model.approverName, isNull);
    });
  });

  group('LeaveListEnvelope.fromJson', () {
    test('parses the index envelope with items and pagination', () {
      final json = {
        'data': {
          'items': [
            {
              'id': 1,
              'request_number': 'LR-20260706-0001',
              'type': 'izin',
              'type_label': 'Izin',
              'reason': 'Keperluan pribadi',
              'start_date': '2026-07-06',
              'end_date': '2026-07-06',
              'total_days': 1,
              'status': 'pending',
              'status_label': 'Menunggu',
              'can_download_pdf': false,
            },
          ],
          'pagination': {
            'current_page': 1,
            'per_page': 15,
            'total': 1,
            'last_page': 1,
            'has_more': false,
          },
        },
      };

      final envelope = LeaveListEnvelope.fromJson(json);

      expect(envelope.data.items, hasLength(1));
      expect(envelope.data.items.first.requestNumber, 'LR-20260706-0001');
      expect(envelope.data.pagination.currentPage, 1);
      expect(envelope.data.pagination.total, 1);
      expect(envelope.data.pagination.hasMore, isFalse);
    });
  });

  group('LeaveDetailEnvelope.fromJson', () {
    test('parses the show envelope', () {
      final json = {
        'data': {
          'id': 9,
          'request_number': 'LR-20260706-0009',
          'type': 'sakit',
          'type_label': 'Sakit',
          'reason': 'Flu',
          'start_date': '2026-07-06',
          'end_date': '2026-07-06',
          'total_days': 1,
          'status': 'rejected',
          'status_label': 'Ditolak',
          'admin_note': 'Bukti tidak jelas',
          'can_download_pdf': false,
        },
      };

      final envelope = LeaveDetailEnvelope.fromJson(json);

      expect(envelope.data.id, 9);
      expect(envelope.data.status, 'rejected');
      expect(envelope.data.adminNote, 'Bukti tidak jelas');
    });
  });
}
