import 'package:aura_mobile/features/attendance/presentation/screens/attendance_presence_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const message =
      'Aktifkan Tanggal & Waktu Otomatis serta Zona Waktu Otomatis '
      'untuk melakukan presensi.';

  /// Pumps a harness whose button opens the block dialog and records the
  /// resolved choice into [choices].
  Future<void> pumpHarness(
    WidgetTester tester,
    List<AutoTimeBlockedChoice> choices,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async =>
                  choices.add(await showAutoTimeBlockedDialog(context)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the AGHRIS copy with OK and Buka Pengaturan', (
    tester,
  ) async {
    await pumpHarness(tester, []);

    expect(find.text('Tanggal & waktu tidak otomatis'), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'OK'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Buka Pengaturan'), findsOneWidget);
  });

  testWidgets('OK resolves to dismissed and closes the dialog', (tester) async {
    final choices = <AutoTimeBlockedChoice>[];
    await pumpHarness(tester, choices);

    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    expect(choices, [AutoTimeBlockedChoice.dismissed]);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Buka Pengaturan resolves to openSettings and closes', (
    tester,
  ) async {
    final choices = <AutoTimeBlockedChoice>[];
    await pumpHarness(tester, choices);

    await tester.tap(find.widgetWithText(TextButton, 'Buka Pengaturan'));
    await tester.pumpAndSettle();

    expect(choices, [AutoTimeBlockedChoice.openSettings]);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('is non-dismissible: tapping the barrier keeps it open', (
    tester,
  ) async {
    final choices = <AutoTimeBlockedChoice>[];
    await pumpHarness(tester, choices);

    // Tap the top-left corner, outside the dialog surface.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(choices, isEmpty);
  });
}
