import 'package:aura_mobile/shared/utils/captured_at.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCapturedAt', () {
    test('produces an ISO-8601 string with an explicit UTC offset', () {
      final formatted = formatCapturedAt(DateTime(2026, 7, 12, 14, 3, 7));

      // yyyy-MM-ddTHH:mm:ss + (+|-)HH:mm
      expect(
        formatted,
        matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$'),
      );
      expect(formatted, startsWith('2026-07-12T14:03:07'));
    });

    test('round-trips back to the same instant it represents', () {
      final source = DateTime(2026, 7, 12, 14, 3, 7);

      final parsed = DateTime.parse(formatCapturedAt(source));

      expect(parsed.isAtSameMomentAs(source), isTrue);
    });

    test('carries the local offset for the formatted wall-clock', () {
      final source = DateTime(2026, 1, 1, 9);
      final expectedOffset = source.timeZoneOffset;
      final sign = expectedOffset.isNegative ? '-' : '+';
      final hh = expectedOffset.abs().inHours.toString().padLeft(2, '0');
      final mm =
          (expectedOffset.abs().inMinutes % 60).toString().padLeft(2, '0');

      expect(formatCapturedAt(source), endsWith('$sign$hh:$mm'));
    });
  });
}
