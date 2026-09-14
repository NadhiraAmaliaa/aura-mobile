import 'package:aura_mobile/core/device/trusted_time_service.dart';
import 'package:aura_mobile/core/network/trusted_time_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the order of anchor establishment vs. response forwarding, plus any
/// completed verification attempts.
class _RecordingTrustedTimeService implements TrustedTimeService {
  final List<String> events = [];
  bool anchored = false;

  @override
  Future<void> establishAnchor(DateTime serverTimeUtc) async {
    // A real establishment awaits platform-channel calls; simulate that gap so
    // a fire-and-forget bug would let the response overtake it.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    anchored = true;
    events.add('establish');
  }

  @override
  void noteVerificationAttempt() => events.add('attempt');

  @override
  Future<bool> get isAvailable async => anchored;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _RecordingResponseHandler extends ResponseInterceptorHandler {
  _RecordingResponseHandler(this.service);

  final _RecordingTrustedTimeService service;

  @override
  void next(Response response) => service.events.add('next');
}

class _RecordingErrorHandler extends ErrorInterceptorHandler {
  _RecordingErrorHandler(this.service);

  final _RecordingTrustedTimeService service;

  @override
  void next(DioException err) => service.events.add('next-error');
}

Response _response({String? date}) {
  return Response(
    requestOptions: RequestOptions(path: '/'),
    headers: date == null
        ? Headers()
        : Headers.fromMap({
            'date': [date],
          }),
  );
}

void main() {
  const date = 'Mon, 07 Sep 2026 10:00:00 GMT';

  test('a Date-bearing response is not forwarded before the anchor is set',
      () async {
    final service = _RecordingTrustedTimeService();
    final interceptor = TrustedTimeInterceptor(Future.value(service));
    final handler = _RecordingResponseHandler(service);

    interceptor.onResponse(_response(date: date), handler);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    // Establishment must precede forwarding, and the anchor is set by then.
    expect(service.events, ['establish', 'next']);
    expect(service.anchored, isTrue);
  });

  test('a response without a Date still records a completed attempt', () async {
    final service = _RecordingTrustedTimeService();
    final interceptor = TrustedTimeInterceptor(Future.value(service));
    final handler = _RecordingResponseHandler(service);

    interceptor.onResponse(_response(), handler);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.events, containsAll(<String>['attempt', 'next']));
  });

  test('a request error records a completed attempt (loading → unavailable)',
      () async {
    final service = _RecordingTrustedTimeService();
    final interceptor = TrustedTimeInterceptor(Future.value(service));
    final handler = _RecordingErrorHandler(service);

    interceptor.onError(
      DioException(requestOptions: RequestOptions(path: '/')),
      handler,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.events, contains('attempt'));
  });
}
