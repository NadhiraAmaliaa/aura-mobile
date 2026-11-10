import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/data/models/leave_submission.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_submit_notifier.dart';
import 'package:aura_mobile/features/leave/presentation/screens/leave_submit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _created = LeaveRequestModel(
  id: 7,
  requestNumber: 'LR-2026-0007',
  type: 'izin',
  typeLabel: 'Izin',
  reason: 'Keperluan keluarga',
  status: 'pending',
  statusLabel: 'Menunggu',
);

const _evidenceHint = 'PDF atau gambar (jpg, jpeg, png, webp), maksimal 5 MB.';
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String _shortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Records submissions instead of calling the repository. [gate] holds the
/// response back so the in-flight state can be inspected.
class _FakeSubmitNotifier extends LeaveSubmitNotifier {
  _FakeSubmitNotifier({this.result = const Success(_created)});

  final ApiResult<LeaveRequestModel> result;
  final submissions = <LeaveSubmission>[];
  Completer<void>? gate;

  @override
  Future<ApiResult<LeaveRequestModel>> submit(
    LeaveSubmission submission,
  ) async {
    submissions.add(submission);
    await gate?.future;
    return result;
  }
}

const _pixelRatio = bool.fromEnvironment('LEAVE_PREVIEW') ? 2.0 : 1.0;

void _setViewport(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width * _pixelRatio, height * _pixelRatio);
  tester.view.devicePixelRatio = _pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Pumps the form at `/leave/submit`, above a stub landing page so a
/// successful submission can pop back to it.
Future<_FakeSubmitNotifier> _pumpForm(
  WidgetTester tester, {
  double width = 393,
  double height = 852,
  double textScale = 1,
  _FakeSubmitNotifier? notifier,
}) async {
  _setViewport(tester, width, height);
  final fake = notifier ?? _FakeSubmitNotifier();
  final router = GoRouter(
    initialLocation: '${RoutePaths.leave}/${RoutePaths.leaveSubmit}',
    routes: [
      GoRoute(
        path: RoutePaths.leave,
        name: RouteNames.leave,
        builder: (_, _) => const Scaffold(body: Text('Landing')),
        routes: [
          GoRoute(
            path: RoutePaths.leaveSubmit,
            name: RouteNames.leaveSubmit,
            builder: (_, _) => const LeaveSubmitScreen(),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [leaveSubmitProvider.overrideWith(() => fake)],
      child: MaterialApp.router(
        routerConfig: router,
        // The form keeps its light design whatever the app theme.
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
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

/// Writes `build/leave-preview/<name>.png` when run with LEAVE_PREVIEW, for
/// visual comparison against the design reference.
Future<void> _capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('LEAVE_PREVIEW')) return;
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

/// The page's own scroll view; every text field adds a nested Scrollable.
final _pageScroll = find
    .descendant(
      of: find.byType(LeaveSubmitScreen),
      matching: find.byType(Scrollable),
    )
    .first;

/// Tappable surface of the empty date field at [index] (0 = Tanggal Mulai).
Finder _dateBox(int index) => find
    .ancestor(
      of: find.text('Pilih tanggal').at(index),
      matching: find.byType(InkWell),
    )
    .first;

/// Opens the first empty date field and accepts the picker's initial date,
/// the earliest one allowed.
Future<void> _pickFirstEmptyDate(WidgetTester tester) async {
  final field = find.text('Pilih tanggal').first;
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Kirim Pengajuan'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Kirim Pengajuan'));
}

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

  testWidgets('keeps the AURA header, the selector and outside labels', (
    tester,
  ) async {
    await _pumpForm(tester);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Ajukan Izin / Sakit'),
      ),
      findsOneWidget,
    );

    // Same two-segment control, Izin selected, recoloured pastel yellow.
    final selector = tester.widget<SegmentedButton<String>>(
      find.byType(SegmentedButton<String>),
    );
    expect(selector.selected, {'izin'});
    expect(selector.showSelectedIcon, isTrue);
    expect(
      selector.style!.backgroundColor!.resolve({WidgetState.selected}),
      const Color(0xFFFFEBC4),
    );
    expect(selector.style!.backgroundColor!.resolve({}), Colors.white);

    // Labels sit above the inputs, not inside their outline.
    for (final label in [
      'Jenis Pengajuan',
      'Alasan',
      'Tanggal Mulai',
      'Tanggal Selesai',
      'Nomor Kontak (opsional)',
      'Alamat Selama Izin (opsional)',
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(InputDecorator),
          matching: find.text(label),
        ),
        findsNothing,
      );
    }
    for (final hint in [
      'Jelaskan alasan pengajuan Anda',
      'Masukkan nomor kontak',
      'Masukkan alamat selama izin',
    ]) {
      expect(find.text(hint), findsOneWidget);
    }
    expect(find.text('Lampiran Bukti'), findsOneWidget);
    expect(find.text(_evidenceHint), findsOneWidget);
    expect(find.text('Pilih Berkas'), findsOneWidget);
  });

  testWidgets('outside labels still name the inputs for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpForm(tester);
      final fields = find.byType(TextField);
      for (final (index, label) in [
        'Alasan',
        'Nomor Kontak (opsional)',
        'Alamat Selama Izin (opsional)',
      ].indexed) {
        final node = tester.getSemantics(fields.at(index));
        expect(node, isSemantics(isTextField: true));
        expect(node.label, contains(label));
      }
      for (final label in ['Tanggal Mulai', 'Tanggal Selesai']) {
        final node = tester.getSemantics(find.text(label));
        expect(node, isSemantics(isButton: true, hasTapAction: true));
        expect(node.label, contains('Pilih tanggal'));
      }
    } finally {
      handle.dispose();
    }
  });

  testWidgets('empty submission shows the existing errors per type', (
    tester,
  ) async {
    final notifier = await _pumpForm(tester);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.text('Alasan wajib diisi.'), findsOneWidget);
    expect(find.text('Tanggal awal wajib diisi.'), findsOneWidget);
    expect(find.text('Tanggal akhir wajib diisi.'), findsOneWidget);
    // Evidence stays optional for izin.
    expect(
      find.text('Lampiran bukti wajib untuk pengajuan sakit.'),
      findsNothing,
    );
    expect(find.text('Lampiran Bukti'), findsOneWidget);

    await tester.ensureVisible(find.text('Sakit'));
    await tester.tap(find.text('Sakit'));
    await tester.pumpAndSettle();
    // Required marker for sakit.
    expect(find.text('Lampiran Bukti *'), findsOneWidget);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('Lampiran bukti wajib untuk pengajuan sakit.'),
      findsOneWidget,
    );
    expect(notifier.submissions, isEmpty);
  });

  testWidgets('date picker keeps its limits in AURA colours', (tester) async {
    await _pumpForm(tester);
    final tomorrow = _today().add(const Duration(days: 1));

    await tester.tap(find.text('Pilih tanggal').first);
    await tester.pumpAndSettle();
    final dialog = find.byType(DatePickerDialog);
    // Izin starts at H-1.
    expect(tester.widget<DatePickerDialog>(dialog).firstDate, tomorrow);
    expect(
      Theme.of(tester.element(dialog)).colorScheme.primary,
      ColorScheme.fromSeed(seedColor: const Color(0xFF174B76)).primary,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // Shown short in the field.
    expect(find.text(_shortDate(tomorrow)), findsOneWidget);

    // Sakit may start today.
    await tester.tap(find.text('Sakit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_shortDate(tomorrow)));
    await tester.pumpAndSettle();
    expect(tester.widget<DatePickerDialog>(dialog).firstDate, _today());
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('keeps the character limits and counters', (tester) async {
    await _pumpForm(tester);
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => (field.maxLength, field.maxLines)),
      [(1000, 4), (30, 1), (500, 2)],
    );
    for (final counter in ['0/1000', '0/30', '0/500']) {
      expect(find.text(counter), findsOneWidget);
    }
  });

  testWidgets('submits the same payload, shows progress, then returns', (
    tester,
  ) async {
    final notifier = _FakeSubmitNotifier()..gate = Completer<void>();
    await _pumpForm(tester, notifier: notifier);
    final tomorrow = _today().add(const Duration(days: 1));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      '  Keperluan keluarga  ',
    );
    await _pickFirstEmptyDate(tester);
    await _pickFirstEmptyDate(tester);
    await tester.enterText(find.byType(TextFormField).at(1), '0812345678');
    await _tapSubmit(tester);
    await tester.pump();

    final submission = notifier.submissions.single;
    expect(submission.type, 'izin');
    expect(submission.reason, 'Keperluan keluarga');
    expect(submission.startDate, tomorrow);
    expect(submission.endDate, tomorrow);
    expect(submission.contactPhone, '0812345678');
    expect(submission.address, isNull);
    expect(submission.evidence, isNull);

    // In flight: spinner, button and inputs disabled.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).enabled,
      isFalse,
    );

    notifier.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Pengajuan berhasil dikirim.'), findsOneWidget);
    expect(find.text('Landing'), findsOneWidget);
  });

  testWidgets('maps a 422 back onto its field', (tester) async {
    final notifier = _FakeSubmitNotifier(
      result: const Failure(
        ValidationException(
          message: 'Data tidak valid.',
          errors: {
            'start_date': ['Tanggal bentrok dengan pengajuan lain.'],
          },
        ),
      ),
    );
    await _pumpForm(tester, notifier: notifier);
    await tester.enterText(find.byType(TextFormField).at(0), 'Sakit gigi');
    await _pickFirstEmptyDate(tester);
    await _pickFirstEmptyDate(tester);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(notifier.submissions, hasLength(1));
    expect(find.text('Tanggal bentrok dengan pengajuan lain.'), findsOneWidget);
    expect(find.text('Data tidak valid.'), findsOneWidget);
    expect(find.byType(LeaveSubmitScreen), findsOneWidget);
  });

  testWidgets('validates Alasan even after it scrolls out of view', (
    tester,
  ) async {
    final notifier = await _pumpForm(tester);
    // Valid dates, so only the empty reason should block the submission.
    await _pickFirstEmptyDate(tester);
    await _pickFirstEmptyDate(tester);

    // A short viewport leaves Alasan far above the visible area once the
    // submit button is scrolled into view.
    _setViewport(tester, 393, 300);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Kirim Pengajuan'),
      100,
      scrollable: _pageScroll,
    );
    await tester.tap(find.text('Kirim Pengajuan'));
    await tester.pumpAndSettle();

    expect(
      notifier.submissions.map((submission) => submission.reason),
      isEmpty,
    );
    expect(find.text('Alasan wajib diisi.', skipOffstage: false), findsOne);
  });

  // The FlutterTest font draws every glyph 1em wide, far wider than Roboto,
  // so the measured layouts fall back earlier here than on a device. A wide
  // page fits the full composition even with that font; phone widths are
  // covered by the LEAVE_PREVIEW captures with real Roboto.
  testWidgets('pairs the dates and the upload action when they fit', (
    tester,
  ) async {
    await _pumpForm(tester, width: 768, height: 1024);
    final start = tester.getRect(_dateBox(0));
    final end = tester.getRect(_dateBox(1));
    expect(end.top, start.top);
    expect(end.height, start.height);
    expect(start.right, lessThan(end.left));
    expect(
      tester.getRect(find.text('Pilih Berkas')).left,
      greaterThan(tester.getRect(find.text(_evidenceHint)).right),
    );
  });

  testWidgets('captures previews of the filled and error states', (
    tester,
  ) async {
    await _pumpForm(tester, height: 1100);
    await _capturePreview(tester, 'submit_393');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    await tester.drag(_pageScroll, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await _capturePreview(tester, 'submit_393_errors');
    await tester.enterText(find.byType(TextFormField).at(0), 'Acara keluarga');
    await _pickFirstEmptyDate(tester);
    await _pickFirstEmptyDate(tester);
    await tester.drag(_pageScroll, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await _capturePreview(tester, 'submit_393_filled');
    expect(tester.takeException(), isNull);
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
          await _pumpForm(
            tester,
            width: viewport.width,
            height: viewport.height,
            textScale: scale,
          );
          final name =
              'submit_${viewport.width.round()}x${viewport.height.round()}'
              '@$scale';
          await _capturePreview(tester, name);

          // Sakit with nothing filled in: every error on screen at once.
          await tester.tap(find.text('Sakit'));
          await tester.pumpAndSettle();
          await _tapSubmit(tester);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await _capturePreview(tester, '${name}_errors');

          // Every control stays inside the page gutters.
          for (final control in [
            find.byType(SegmentedButton<String>),
            ...List.generate(3, (index) => find.byType(TextField).at(index)),
            _dateBox(0),
            _dateBox(1),
            find.text('Pilih Berkas'),
            find.byType(FilledButton),
          ]) {
            final rect = tester.getRect(control);
            expect(rect.left, greaterThanOrEqualTo(16));
            expect(rect.right, lessThanOrEqualTo(viewport.width - 16));
          }

          // Date fields form one row of equal boxes or one column.
          final start = tester.getRect(_dateBox(0));
          final end = tester.getRect(_dateBox(1));
          final oneRow = end.top == start.top && end.height == start.height;
          final oneColumn = end.left == start.left && end.top > start.bottom;
          expect(oneRow || oneColumn, isTrue);
        },
      );
    }
  }
}
