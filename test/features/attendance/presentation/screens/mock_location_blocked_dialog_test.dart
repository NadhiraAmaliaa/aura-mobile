import 'package:aura_mobile/features/attendance/presentation/widgets/attendance_block_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const title = 'Lokasi tidak dapat diverifikasi';
  const message =
      'Lokasi palsu terdeteksi. Presensi tidak dapat dilakukan '
      'karena lokasi Anda tidak dapat diverifikasi.\n\n'
      'Jika Anda menggunakan aplikasi Fake GPS atau Mock Location, '
      'nonaktifkan terlebih dahulu, lalu coba lagi.';

  /// Pumps a harness whose button opens the block dialog and records when it
  /// resolves into [resolved].
  Future<void> pumpHarness(WidgetTester tester, List<void> resolved) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showMockLocationBlockedDialog(context);
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

  testWidgets('renders the mock-location copy with a single Mengerti action', (
    tester,
  ) async {
    await pumpHarness(tester, []);

    expect(find.text(title), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Mengerti'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('Mengerti closes the dialog and resolves', (tester) async {
    final resolved = <void>[];
    await pumpHarness(tester, resolved);

    await tester.tap(find.widgetWithText(TextButton, 'Mengerti'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(resolved, hasLength(1));
  });

  testWidgets('is non-dismissible: tapping the barrier keeps it open', (
    tester,
  ) async {
    final resolved = <void>[];
    await pumpHarness(tester, resolved);

    // Tap the top-left corner, outside the dialog surface.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(resolved, isEmpty);
  });

  testWidgets('is non-dismissible: Android Back keeps it open', (tester) async {
    final resolved = <void>[];
    await pumpHarness(tester, resolved);

    // The system back button / back gesture.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(resolved, isEmpty);
  });
}
