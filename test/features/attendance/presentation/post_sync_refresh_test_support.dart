import 'dart:convert';
import 'dart:typed_data';

import 'package:aura_mobile/core/device/device_time_settings.dart';
import 'package:aura_mobile/core/device/trusted_time_service.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_entry.dart';
import 'package:aura_mobile/features/attendance/data/local/attendance_queue_store.dart';
import 'package:aura_mobile/features/attendance/data/local/dashboard_cache_store.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/attendance_day.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// The signed-in intern every scenario runs as.
const scenarioUserId = 7;

/// Where the fakes report the device to be (WFH, so no geofence applies).
const scenarioLatitude = 3.5952;
const scenarioLongitude = 98.6722;

/// The scenario's attendance day: the device's current date, so the trusted
/// clock, the backend's `today.date` and the device-clock-based pending-action
/// derivation all agree on one calendar day.
final DateTime _scenarioDay = DateTime.now();

/// [hour]:[minute] on the scenario day, in device-local time.
DateTime scenarioAt(int hour, [int minute = 0]) => DateTime(
  _scenarioDay.year,
  _scenarioDay.month,
  _scenarioDay.day,
  hour,
  minute,
);

/// The scenario day as the backend's `yyyy-MM-dd` attendance date.
final String scenarioDayKey = attendanceDateKey(scenarioAt(0));

/// `AttendanceResource` JSON for the scenario day's record, as the backend
/// returns it from POST /attendance/check-in, POST /attendance/check-out and
/// in the dashboard's `today.attendance`: checked in at 08:00 (WFH), and
/// checked out at [checkOutTime] when given.
Map<String, dynamic> attendanceRecordJson({String? checkOutTime}) => {
  'id': 41,
  'attendance_date': scenarioDayKey,
  'check_in_time': '08:00',
  'check_out_time': checkOutTime,
  'check_in_latitude': '3.5952000',
  'check_in_longitude': '98.6722000',
  'check_out_latitude': checkOutTime == null ? null : '3.5952000',
  'check_out_longitude': checkOutTime == null ? null : '98.6722000',
  'status': 'present',
  'status_label': 'Hadir',
  'work_mode': 'wfh',
  'work_mode_label': 'WFH',
};

/// The `data` payload of GET /attendance/dashboard for the scenario day, with
/// [attendance] as today's record (`null` = nothing recorded yet).
Map<String, dynamic> dashboardJson({Map<String, dynamic>? attendance}) => {
  'today': {
    'date': scenarioDayKey,
    'is_working_day': true,
    'work_hours': {'start': '08:00', 'end': '17:00'},
    'attendance': attendance,
    'leave': null,
  },
  'summary': {
    'month': scenarioDayKey.substring(0, 7),
    'hadir': 0,
    'terlambat': 0,
    'izin': 0,
    'sakit': 0,
    'dinas': 0,
    'tidak_absen': 0,
  },
};

/// The AURA backend at the HTTP boundary: a Dio [HttpClientAdapter] answering
/// the attendance endpoints with canned JSON. The production Retrofit client,
/// repository and Dio error mapping all run unchanged, and no real request is
/// ever made.
class FakeAttendanceBackend implements HttpClientAdapter {
  /// Every request received, as `METHOD /path`, in order.
  final List<String> calls = [];

  /// The bodies of the POSTed attendance events, in order.
  final List<Map<String, dynamic>> postedEvents = [];

  /// Successive answers to GET /attendance/dashboard (its `data` payload). A
  /// `null` answer times out, as a stalled response does on a device.
  final List<Map<String, dynamic>?> dashboardReplies = [];

  /// How many GET /attendance/dashboard requests timed out.
  int dashboardTimeouts = 0;

  /// The record POST /attendance/check-in returns.
  Map<String, dynamic>? checkInRecord;

  /// The record POST /attendance/check-out returns.
  Map<String, dynamic>? checkOutRecord;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final call = '${options.method} ${options.path}';
    calls.add(call);
    switch (call) {
      case 'GET /attendance/dashboard':
        if (dashboardReplies.isEmpty) {
          throw StateError('No scripted reply left for $call');
        }
        final reply = dashboardReplies.removeAt(0);
        if (reply == null) {
          dashboardTimeouts++;
          // What Dio's IO adapter raises when the response never arrives.
          throw DioException.receiveTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: options,
          );
        }
        return _json({'data': reply});
      case 'POST /attendance/check-in':
        postedEvents.add(Map<String, dynamic>.from(options.data as Map));
        return _json({'message': 'Check In berhasil.', 'data': checkInRecord});
      case 'POST /attendance/check-out':
        postedEvents.add(Map<String, dynamic>.from(options.data as Map));
        return _json({
          'message': 'Check Out berhasil.',
          'data': checkOutRecord,
        });
    }
    throw StateError('Unexpected request: $call');
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody _json(Object body) => ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// A bare Dio wired to [backend]. The production auth and trusted-time
/// interceptors are left out: neither takes part in the sync → dashboard
/// refresh hand-off under test.
Dio dioFor(FakeAttendanceBackend backend) =>
    Dio(BaseOptions(baseUrl: 'https://aura.test/api/v1'))
      ..httpClientAdapter = backend;

/// A trusted clock pinned to [instant], moved by the test between actions.
class SteppedTrustedTime implements TrustedTimeService {
  SteppedTrustedTime(this.instant);

  DateTime instant;

  @override
  Future<DateTime> now() async => instant.toUtc();

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<void> setAnchor(DateTime serverTimeUtc) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A device whose automatic date & time setting is on.
class AutomaticClockSettings implements DeviceTimeSettings {
  const AutomaticClockSettings();

  @override
  Future<bool?> isAutomaticEnabled() async => true;

  @override
  Future<bool> openDateTimeSettings() async => true;
}

/// A device that stays on Wi-Fi: the dashboard really attempts its request
/// (no offline short-circuit) and no connectivity change ever fires.
class OnlineConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

/// In-memory [AttendanceQueueStore] with the semantics of
/// `SqfliteAttendanceQueueStore`, for widget tests: sqflite's real I/O does
/// not complete inside the widget tester's fake-async zone.
class MemoryAttendanceQueueStore implements AttendanceQueueStore {
  final Map<String, AttendanceQueueEntry> _rows = {};

  Iterable<AttendanceQueueEntry> _owned(int userId) =>
      _rows.values.where((entry) => entry.userId == userId);

  @override
  Future<void> save(AttendanceQueueEntry entry) async {
    _rows[entry.clientEventId] = entry;
  }

  @override
  Future<bool> updateIfPresent(AttendanceQueueEntry entry) async {
    if (!_rows.containsKey(entry.clientEventId)) return false;
    _rows[entry.clientEventId] = entry;
    return true;
  }

  @override
  Future<void> replacePendingCheckOut(AttendanceQueueEntry entry) async {
    final day = entry.capturedAt.substring(0, 10);
    _rows.removeWhere(
      (_, row) =>
          row.userId == entry.userId &&
          row.type == AttendanceEventType.checkOut &&
          row.status == QueuedEventStatus.pending &&
          row.capturedAt.substring(0, 10) == day,
    );
    _rows[entry.clientEventId] = entry;
  }

  @override
  Future<List<AttendanceQueueEntry>> pendingEntries(int userId) async =>
      _owned(
          userId,
        ).where((entry) => entry.status == QueuedEventStatus.pending).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<List<AttendanceQueueEntry>> allEntries(int userId) async =>
      _owned(userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<int> pendingCount(int userId) async =>
      (await pendingEntries(userId)).length;

  @override
  Future<void> purgeSyncedBefore(int userId, DateTime cutoff) async {
    _rows.removeWhere(
      (_, row) =>
          row.userId == userId &&
          row.status == QueuedEventStatus.synced &&
          row.createdAt.isBefore(cutoff),
    );
  }
}

/// In-memory [DashboardCacheStore] that round-trips through JSON exactly like
/// `SqfliteDashboardCacheStore`, for widget tests.
class MemoryDashboardCacheStore implements DashboardCacheStore {
  final Map<int, String> _payloads = {};

  @override
  Future<void> save(int userId, AttendanceDashboardModel dashboard) async {
    _payloads[userId] = jsonEncode(dashboard.toJson());
  }

  @override
  Future<AttendanceDashboardModel?> read(int userId) async {
    final payload = _payloads[userId];
    if (payload == null) return null;
    return AttendanceDashboardModel.fromJson(
      jsonDecode(payload) as Map<String, dynamic>,
    );
  }
}
