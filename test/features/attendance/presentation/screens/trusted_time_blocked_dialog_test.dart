import 'package:aura_mobile/features/attendance/presentation/screens/attendance_presence_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const title = 'Waktu perangkat belum terverifikasi';
  const message =
      'Hubungkan ke internet terlebih dahulu untuk memverifikasi waktu '
      'sebelum melakukan absensi.';

  /// Pumps a harness whose button opens the block dialog and records when it
  /// resolves into [resolved].
  Future<void> pumpHarness(WidgetTester tester, List<void> resolved) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showTrustedTimeBlockedDialog(context);
                resolved.add(null);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the trusted-time copy with a single OK action', (
    tester,
  ) async {
    await pumpHarness(tester, []);

    expect(find.text(title), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'OK'), findsOneWidget);
    // Unlike the auto-time dialog there is no settings shortcut.
    expect(find.widgetWithText(TextButton, 'Buka Pengaturan'), findsNothing);
  });

  testWidgets('OK closes the dialog and resolves', (tester) async {
    final resolved = <void>[];
    await pumpHarness(tester, resolved);

    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(resolved, hasLength(1));
  });

  testWidgets('is non-dismissible: tapping the barrier keeps it open', (
    tester,
  ) async {
    await pumpHarness(tester, []);

    // Tap the top-left corner, outside the dialog surface.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
