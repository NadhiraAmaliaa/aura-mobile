import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/features/leave/presentation/screens/leave_landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _destinations = [
  (title: 'Ajukan\nIzin / Sakit', name: RouteNames.leaveSubmit),
  (title: 'Menunggu Persetujuan', name: RouteNames.leavePending),
  (title: 'Riwayat Pengajuan', name: RouteNames.leaveHistory),
  (title: 'Surat Pulang Cepat', name: RouteNames.leaveSurat),
];

/// Pumps the landing page at `/leave` with stub children registered under the
/// app's real route names.
Future<GoRouter> _pumpLanding(
  WidgetTester tester, {
  double width = 393,
  double height = 852,
  double textScale = 1,
}) async {
  const pixelRatio = bool.fromEnvironment('LEAVE_PREVIEW') ? 2.0 : 1.0;
  tester.view.physicalSize = Size(width * pixelRatio, height * pixelRatio);
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: RoutePaths.leave,
    routes: [
      GoRoute(
        path: RoutePaths.leave,
        name: RouteNames.leave,
        builder: (_, _) => const LeaveLandingScreen(),
        routes: [
          for (final (path, name) in [
            (RoutePaths.leaveSubmit, RouteNames.leaveSubmit),
            (RoutePaths.leavePending, RouteNames.leavePending),
            (RoutePaths.leaveHistory, RouteNames.leaveHistory),
            (RoutePaths.leaveSurat, RouteNames.leaveSurat),
          ])
            GoRoute(
              path: path,
              name: name,
              builder: (_, _) => Scaffold(body: Text('Destination $name')),
            ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      // The page keeps its light design whatever the app theme.
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: RepaintBoundary(
          key: const ValueKey('leave-preview'),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Writes `build/leave-preview/<name>.png` when run with LEAVE_PREVIEW, for
/// visual comparison against the design reference.
Future<void> _capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('LEAVE_PREVIEW')) return;
  await tester.runAsync(() async {
    final context = tester.element(find.byType(LeaveLandingScreen));
    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      await precacheImage(image.image, context);
    }
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('leave-preview')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/leave-preview').create(recursive: true);
    await File(
      'build/leave-preview/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

/// Rect of the tappable surface around a card's title.
Rect _cardRect(WidgetTester tester, String title) => tester.getRect(
  find.ancestor(of: find.text(title), matching: find.byType(InkWell)).first,
);

void main() {
  setUpAll(() async {
    // Real Roboto weights for previews; the test font is used otherwise.
    final fontDir = Platform.environment['LEAVE_PREVIEW_FONT_DIR'];
    if (fontDir == null) return;
    final roboto = FontLoader('Roboto');
    for (final weight in ['regular', 'medium', 'bold']) {
      roboto.addFont(
        File(
          '$fontDir/roboto-$weight.ttf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    }
    await roboto.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '$fontDir/materialicons-regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await icons.load();
  });

  testWidgets('keeps the AURA header and the shared leave illustration', (
    tester,
  ) async {
    await _pumpLanding(tester);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Izin & Sakit'),
      ),
      findsOneWidget,
    );
    final illustration = tester.widget<Image>(find.byType(Image));
    expect(
      (illustration.image as ResizeImage).imageProvider,
      const AssetImage('assets/images/home/menu_leave.png'),
    );
    await _capturePreview(tester, 'leave');
    await tester.scrollUntilVisible(find.text('Catatan Penting'), 120);
    expect(find.text('Catatan Penting'), findsOneWidget);
  });

  for (final destination in _destinations) {
    final label = destination.title.replaceAll('\n', ' ');
    testWidgets('$label opens its existing route and back returns', (
      tester,
    ) async {
      final router = await _pumpLanding(tester);
      await tester.ensureVisible(find.text(destination.title));
      await tester.tap(find.text(destination.title));
      await tester.pumpAndSettle();
      expect(find.text('Destination ${destination.name}'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(LeaveLandingScreen), findsOneWidget);
    });

    testWidgets('$label card navigates from its corner', (tester) async {
      await _pumpLanding(tester);
      await tester.ensureVisible(find.text(destination.title));
      await tester.pumpAndSettle();
      final card = _cardRect(tester, destination.title);
      await tester.tapAt(card.bottomRight - const Offset(16, 16));
      await tester.pumpAndSettle();
      expect(find.text('Destination ${destination.name}'), findsOneWidget);
    });
  }

  testWidgets('Ajukan Sekarang opens the submission form', (tester) async {
    await _pumpLanding(tester);
    await tester.tap(find.text('Ajukan Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Destination ${RouteNames.leaveSubmit}'), findsOneWidget);
  });

  testWidgets('each card is one accessible button; the note is not', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpLanding(tester);
      for (final label in [
        'Ajukan Izin / Sakit. Buat pengajuan izin atau sakit baru',
        'Menunggu Persetujuan. Pengajuan yang masih diproses',
        'Riwayat Pengajuan. Pengajuan yang disetujui atau ditolak',
        'Surat Pulang Cepat. Buat surat izin pulang sebelum waktunya',
      ]) {
        expect(
          tester.getSemantics(find.bySemanticsLabel(label)),
          matchesSemantics(label: label, isButton: true, hasTapAction: true),
        );
      }
      await tester.scrollUntilVisible(find.text('Catatan Penting'), 120);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Catatan Penting'))),
        isSemantics(isButton: false, hasTapAction: false),
      );
    } finally {
      handle.dispose();
    }
  });

  // The FlutterTest font draws every glyph 1em wide, far wider than Roboto,
  // so the measured layouts fall back earlier here than on a device. A wide
  // page fits the full reference composition even with that font; phone
  // widths are covered by the LEAVE_PREVIEW captures with real Roboto.
  testWidgets('keeps the reference composition when the copy fits', (
    tester,
  ) async {
    await _pumpLanding(tester, width: 768, height: 1024);
    // Illustration beside the submission copy.
    final illustration = tester.getRect(find.byType(Image));
    final title = tester.getRect(find.text('Ajukan\nIzin / Sakit'));
    expect(illustration.right, lessThan(title.left));
    // Two equal status cards in one row, each icon beside its title.
    final pending = _cardRect(tester, 'Menunggu Persetujuan');
    final history = _cardRect(tester, 'Riwayat Pengajuan');
    expect(history.top, pending.top);
    expect(history.height, pending.height);
    expect(pending.right, lessThan(history.left));
    expect(
      tester.getRect(find.byIcon(Icons.hourglass_bottom_rounded)).right,
      lessThan(tester.getRect(find.text('Menunggu Persetujuan')).left),
    );
  });

  for (final viewport in [
    (width: 320.0, height: 568.0),
    (width: 360.0, height: 640.0),
    (width: 393.0, height: 852.0),
    (width: 430.0, height: 932.0),
    (width: 768.0, height: 1024.0),
  ]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets(
        'fits ${viewport.width}x${viewport.height} at text scale $scale',
        (tester) async {
          await _pumpLanding(
            tester,
            width: viewport.width,
            height: viewport.height,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          final name =
              'leave_${viewport.width.round()}x${viewport.height.round()}'
              '@$scale';
          await _capturePreview(tester, name);

          // The list builds lazily and scrollUntilVisible only moves down, so
          // cards are visited top to bottom and scrolled in before measuring.
          final rects = <String, Rect>{};
          for (final title in [
            for (final destination in _destinations) destination.title,
            'Catatan Penting',
          ]) {
            await tester.scrollUntilVisible(find.text(title), 120);
            await tester.pumpAndSettle();
            rects[title] = title == 'Catatan Penting'
                ? tester.getRect(
                    find
                        .ancestor(
                          of: find.text(title),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                : _cardRect(tester, title);
            // Measured together, while both status cards are laid out.
            if (title == 'Riwayat Pengajuan') {
              rects['Menunggu Persetujuan'] = _cardRect(
                tester,
                'Menunggu Persetujuan',
              );
            }
          }
          expect(tester.takeException(), isNull);
          await _capturePreview(tester, '${name}_end');

          // Every card stays inside the page gutters.
          for (final rect in rects.values) {
            expect(rect.left, greaterThanOrEqualTo(16));
            expect(rect.right, lessThanOrEqualTo(viewport.width - 16));
          }

          // Status cards are one row of equal cards or one column.
          final pending = rects['Menunggu Persetujuan']!;
          final history = rects['Riwayat Pengajuan']!;
          final oneRow =
              history.top == pending.top && history.height == pending.height;
          final oneColumn =
              history.left == pending.left && history.top > pending.bottom;
          expect(oneRow || oneColumn, isTrue);
        },
      );
    }
  }
}
