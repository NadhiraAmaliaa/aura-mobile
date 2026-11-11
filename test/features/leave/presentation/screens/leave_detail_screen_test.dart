import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_detail_notifier.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_download_notifier.dart';
import 'package:aura_mobile/features/leave/presentation/screens/leave_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _heading = Color(0xFF123F69);

/// The reference design's request: pending sakit with every optional field.
const _pendingSakit = LeaveRequestModel(
  id: 2,
  requestNumber: 'LR-20261110-0002',
  type: 'sakit',
  typeLabel: 'Sakit',
  reason: 'Rawat Inap',
  startDate: '2026-11-12',
  endDate: '2026-11-14',
  totalDays: 2,
  contactPhone: '08535154678',
  address: 'Jakarta',
  evidenceUrl: 'https://aura.test/storage/evidence/bukti.pdf',
  status: 'pending',
  statusLabel: 'Menunggu',
);

/// Decided at 05:00 WIB: still 9 November in UTC.
const _decidedAt = '2026-11-10T05:00:00+07:00';

const _approvedIzin = LeaveRequestModel(
  id: 1,
  requestNumber: 'LR-20261110-0001',
  type: 'izin',
  typeLabel: 'Izin',
  reason: 'Bimbingan Skripsi',
  startDate: '2026-11-11',
  endDate: '2026-11-11',
  totalDays: 1,
  contactPhone: '08213215555',
  address: 'Bandung',
  status: 'approved',
  statusLabel: 'Disetujui',
  adminNote: 'Semoga bimbingannya lancar.',
  approverName: 'Lina Hukumm',
  approvedAt: _decidedAt,
  canDownloadPdf: true,
);

const _rejectedSakit = LeaveRequestModel(
  id: 3,
  requestNumber: 'LR-20261110-0003',
  type: 'sakit',
  typeLabel: 'Sakit',
  reason: 'Demam',
  startDate: '2026-11-12',
  endDate: '2026-11-12',
  totalDays: 1,
  status: 'rejected',
  statusLabel: 'Ditolak',
  adminNote: 'Surat dokter belum dilampirkan.',
  approverName: 'Lina Hukumm',
  approvedAt: _decidedAt,
);

/// Serves [load]'s result instead of the repository and counts refreshes.
class _FakeDetailNotifier extends LeaveDetailNotifier {
  _FakeDetailNotifier(this.load);

  final Future<LeaveRequestModel> Function() load;
  int refreshes = 0;

  @override
  Future<LeaveRequestModel> build(int id) => load();

  @override
  Future<void> refresh() async {
    refreshes++;
  }
}

/// Records the file actions and, like the real notifier, is loading while
/// one runs; [gate] holds it there.
class _FakeDownloadNotifier extends LeaveDownloadNotifier {
  _FakeDownloadNotifier({this.result = const Success<void>(null)});

  final ApiResult<void> result;
  final actions = <String>[];
  Completer<void>? gate;

  @override
  Future<ApiResult<void>> openEvidence(LeaveRequestModel request) =>
      _run('evidence');

  @override
  Future<ApiResult<void>> printPdf(LeaveRequestModel request) => _run('pdf');

  Future<ApiResult<void>> _run(String action) async {
    actions.add(action);
    state = const AsyncLoading();
    await gate?.future;
    state = const AsyncData(null);
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

typedef _Fakes = ({_FakeDetailNotifier detail, _FakeDownloadNotifier files});

/// Pumps the detail page of [request] under `/leave`, as the list opens it.
Future<_Fakes> _pumpDetail(
  WidgetTester tester, {
  LeaveRequestModel request = _pendingSakit,
  Future<LeaveRequestModel> Function()? load,
  _FakeDownloadNotifier? files,
  double width = 393,
  double height = 852,
  double textScale = 1,
  bool settle = true,
}) async {
  _setViewport(tester, width, height);
  late _FakeDetailNotifier detail;
  final downloads = files ?? _FakeDownloadNotifier();
  final router = GoRouter(
    initialLocation: '${RoutePaths.leave}/detail/${request.id}',
    routes: [
      GoRoute(
        path: RoutePaths.leave,
        name: RouteNames.leave,
        builder: (_, _) => const Scaffold(body: Text('Landing')),
        routes: [
          GoRoute(
            path: RoutePaths.leaveDetail,
            name: RouteNames.leaveDetail,
            builder: (_, state) =>
                LeaveDetailScreen(id: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      // A fresh container per pump, so each call gets its own fakes.
      key: UniqueKey(),
      retry: (_, _) => null,
      overrides: [
        leaveDetailProvider.overrideWith2(
          (_) => detail = _FakeDetailNotifier(load ?? () async => request),
        ),
        leaveDownloadProvider.overrideWith(() => downloads),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        // The page keeps its light design whatever the app theme.
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: RepaintBoundary(
            key: const ValueKey('detail-preview'),
            child: child,
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return (detail: detail, files: downloads);
}

/// Writes `build/leave-preview/<name>.png` when run with LEAVE_PREVIEW.
Future<void> _capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('LEAVE_PREVIEW')) return;
  await tester.runAsync(() async {
    final context = tester.element(find.byType(LeaveDetailScreen));
    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      await precacheImage(image.image, context);
    }
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('detail-preview')),
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

/// The nearest coloured box around [finder]: a tile, badge, pill or panel.
BoxDecoration _boxAround(WidgetTester tester, Finder finder) =>
    tester
            .widget<DecoratedBox>(
              find
                  .ancestor(of: finder, matching: find.byType(DecoratedBox))
                  .first,
            )
            .decoration
        as BoxDecoration;

// The page is a lazy ListView: its lower sections are built offstage, below
// the visible area, until scrolled to. These finders include them.

/// The white card holding [text].
Finder _cardOf(String text) => find
    .ancestor(
      of: find.text(text, skipOffstage: false),
      matching: find.byType(Material),
    )
    .first;

Finder _button(String label) => find.ancestor(
  of: find.text(label, skipOffstage: false),
  matching: find.byType(FilledButton),
);

/// The processing card's rows are plain text: no icon but the note panel's,
/// labels and divider at the card's content edges, level with the panel,
/// which keeps its status tint.
void _expectPlainProcessingRows(
  WidgetTester tester, {
  required String noteLabel,
  required IconData noteIcon,
  required Color noteTint,
}) {
  final card = _cardOf('Diproses oleh');
  Finder inCard(Finder finder) =>
      find.descendant(of: card, matching: finder, skipOffstage: false);
  expect(
    tester.widgetList<Icon>(inCard(find.byType(Icon))).map((i) => i.icon),
    [noteIcon],
  );
  final content = tester.getRect(card).deflate(16);
  for (final label in ['Diproses oleh', 'Tanggal Diproses']) {
    expect(tester.getRect(find.text(label)).left, content.left);
  }
  final divider = tester.getRect(inCard(find.byType(Divider)));
  expect((divider.left, divider.right), (content.left, content.right));
  final panel = find.ancestor(
    of: find.text(noteLabel, skipOffstage: false),
    matching: find.byType(DecoratedBox),
  );
  expect(tester.getRect(panel.first).left, content.left);
  expect(
    (tester.widget<DecoratedBox>(panel.first).decoration as BoxDecoration)
        .color,
    noteTint.withValues(alpha: 0.6),
  );
}

/// Whether [a] and [b] find the same widget, e.g. the same card.
bool _same(WidgetTester tester, Finder a, Finder b) =>
    identical(tester.element(a), tester.element(b));

/// Scrolls the page down until [text] is on screen.
Future<void> _reveal(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
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

  testWidgets('follows the reference: heading, date card, information card', (
    tester,
  ) async {
    await _pumpDetail(tester);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Detail Pengajuan'),
      ),
      findsOneWidget,
    );

    // Heading: the sakit icon on its pink tile, number and status badge.
    final icon = find.image(const AssetImage('assets/images/leave/sakit.png'));
    expect(icon, findsOneWidget);
    expect(tester.getSize(icon), const Size.square(34));
    expect(
      tester.getSize(
        find.ancestor(of: icon, matching: find.byType(SizedBox)).first,
      ),
      const Size.square(56),
    );
    expect(_boxAround(tester, icon).color, const Color(0xFFFFE5E8));
    expect(tester.widget<Text>(find.text('Sakit')).style!.color, _heading);
    expect(find.text('LR-20261110-0002'), findsOneWidget);
    expect(
      _boxAround(tester, find.text('Menunggu')).color,
      const Color(0xFFD9F1F8),
    );
    // No illustration: the type icon is the only image.
    expect(find.byType(Image), findsOneWidget);

    // Date card, with the day count on the pink pill.
    for (final (label, value) in [
      ('Tanggal Mulai', 'Kamis, 12 November 2026'),
      ('Tanggal Selesai', 'Sabtu, 14 November 2026'),
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(find.text(value), findsOneWidget);
      expect(tester.widget<Text>(find.text(value)).style!.color, _heading);
    }
    expect(find.text('Jumlah Hari'), findsOneWidget);
    expect(
      _boxAround(tester, find.text('2 hari')).color,
      const Color(0xFFFFE5E8),
    );
    for (final dateIcon in [
      Icons.calendar_today_outlined,
      Icons.event_outlined,
    ]) {
      expect(
        tester.widget<Icon>(find.byIcon(dateIcon)).color,
        const Color(0xFFC62F3B),
      );
    }

    // Information card, after the date card, on its own white card.
    for (final (label, value) in [
      ('Alasan', 'Rawat Inap'),
      ('Alamat', 'Jakarta'),
      ('Kontak', '08535154678'),
      ('Lampiran', 'Tersedia'),
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(find.text(value), findsOneWidget);
    }
    final dateCard = tester.widget<Material>(_cardOf('Tanggal Mulai'));
    expect(dateCard.color, Colors.white);
    expect(dateCard.borderRadius, BorderRadius.circular(20));
    expect(_boxAround(tester, _cardOf('Tanggal Mulai')).boxShadow, isNotEmpty);
    expect(
      tester.getRect(_cardOf('Alasan')).top,
      greaterThan(tester.getRect(_cardOf('Tanggal Mulai')).bottom),
    );

    // Pending: nothing processed yet, no letter to print.
    expect(find.text('Diproses oleh'), findsNothing);
    expect(find.text('Cetak PDF'), findsNothing);
    expect(find.text('Lihat Lampiran'), findsOneWidget);
  });

  testWidgets('izin is green; approved adds processing, note and Cetak PDF', (
    tester,
  ) async {
    await _pumpDetail(tester, request: _approvedIzin);
    final icon = find.image(const AssetImage('assets/images/leave/izin.png'));
    expect(_boxAround(tester, icon).color, const Color(0xFFE3F4DC));
    expect(
      _boxAround(tester, find.text('1 hari')).color,
      const Color(0xFFE3F4DC),
    );
    expect(
      _boxAround(tester, find.text('Disetujui')).color,
      const Color(0xFFDDF3E1),
    );
    expect(find.text('Rabu, 11 November 2026'), findsNWidgets(2));

    // The processing card, in green.
    expect(find.text('Diproses oleh'), findsOneWidget);
    expect(find.text('Lina Hukumm'), findsOneWidget);
    expect(find.text('Tanggal Diproses'), findsOneWidget);
    expect(find.text('10 November 2026'), findsOneWidget);
    _expectPlainProcessingRows(
      tester,
      noteLabel: 'Catatan Mentor',
      noteIcon: Icons.chat_bubble_outline,
      noteTint: const Color(0xFFDDF3E1),
    );
    expect(
      tester.getRect(_cardOf('Diproses oleh')).top,
      greaterThan(tester.getRect(_cardOf('Alasan')).bottom),
    );
    // The mentor's note, now shown on approvals too.
    expect(find.text('Catatan Mentor'), findsOneWidget);
    expect(find.text('Semoga bimbingannya lancar.'), findsOneWidget);
    expect(find.text('Catatan Penolakan'), findsNothing);
    expect(
      _same(tester, _cardOf('Catatan Mentor'), _cardOf('Diproses oleh')),
      isTrue,
      reason: 'the note sits inside the processing card',
    );

    // No attachment: Cetak PDF alone, in the forms' navy.
    await _reveal(tester, 'Cetak PDF');
    expect(find.text('Lihat Lampiran', skipOffstage: false), findsNothing);
    expect(find.text('Lampiran', skipOffstage: false), findsNothing);
    final print = tester.widget<FilledButton>(_button('Cetak PDF'));
    expect(print.style!.backgroundColor!.resolve({}), const Color(0xFF194875));
    expect(
      find.byIcon(Icons.print_outlined, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('rejected: red processing card with the rejection note', (
    tester,
  ) async {
    await _pumpDetail(tester, request: _rejectedSakit);
    expect(
      _boxAround(tester, find.text('Ditolak')).color,
      const Color(0xFFFDE3E3),
    );
    _expectPlainProcessingRows(
      tester,
      noteLabel: 'Catatan Penolakan',
      noteIcon: Icons.info_outline,
      noteTint: const Color(0xFFFDE3E3),
    );
    expect(find.text('Catatan Penolakan'), findsOneWidget);
    expect(find.text('Catatan Mentor'), findsNothing);
    final note = find.text('Surat dokter belum dilampirkan.');
    expect(note, findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Catatan Penolakan')).style!.color,
      const Color(0xFFB3261E),
    );
    expect(
      _same(tester, _cardOf('Catatan Penolakan'), _cardOf('Diproses oleh')),
      isTrue,
    );
    // Neither file action applies.
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('shows a note only for approvals and rejections', (tester) async {
    await _pumpDetail(tester, request: _approvedIzin.copyWith(adminNote: null));
    expect(find.text('Catatan Mentor'), findsNothing);
    expect(find.text('Diproses oleh'), findsOneWidget);

    await _pumpDetail(tester, request: _rejectedSakit.copyWith(adminNote: ''));
    expect(find.text('Catatan Penolakan'), findsNothing);

    // Another status keeps its neutral badge and shows no note.
    await _pumpDetail(
      tester,
      request: _rejectedSakit.copyWith(
        status: 'cancelled',
        statusLabel: 'Dibatalkan',
      ),
    );
    expect(
      _boxAround(tester, find.text('Dibatalkan')).color,
      const Color(0xFFECEFF3),
    );
    expect(find.text('Catatan Penolakan'), findsNothing);
    expect(find.text('Catatan Mentor'), findsNothing);
    expect(find.text('Diproses oleh'), findsOneWidget);
  });

  // The server writes approved_at in its own timezone (Asia/Jakarta) with
  // the offset. The page shows that calendar date, as the web app and the PDF
  // do, whatever timezone this device is set to.
  testWidgets('dates a decision by the server calendar date', (tester) async {
    for (final (approvedAt, shown) in [
      // 22:00 UTC the day before: the original bug showed 9 November.
      (_decidedAt, '10 November 2026'),
      // Already 11 November in WITA and WIT.
      ('2026-11-10T23:30:00+07:00', '10 November 2026'),
      // Another server offset: 9 November 22:30 in WIB, still the 10th.
      ('2026-11-10T00:30:00+09:00', '10 November 2026'),
      // A bare date.
      ('2026-11-10', '10 November 2026'),
      // Unexpected values are shown as sent.
      ('kemarin sore', 'kemarin sore'),
      ('2026-11-10 pukul lima', '2026-11-10 pukul lima'),
    ]) {
      await _pumpDetail(
        tester,
        request: _approvedIzin.copyWith(approvedAt: approvedAt),
      );
      final date = find.descendant(
        of: _cardOf('Tanggal Diproses'),
        matching: find.text(shown, skipOffstage: false),
      );
      expect(date, findsOneWidget, reason: approvedAt);
      expect(
        find.textContaining('9 November', skipOffstage: false),
        findsNothing,
        reason: approvedAt,
      );
      expect(
        find.textContaining('11 November 2026', skipOffstage: false),
        findsNWidgets(2),
        reason: '$approvedAt: only the request dates are the 11th',
      );
    }
  });

  testWidgets('hides Jumlah Hari when unknown and keeps the date fallbacks', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      request: _pendingSakit.copyWith(
        startDate: null,
        endDate: null,
        totalDays: null,
        address: '',
        contactPhone: null,
        evidenceUrl: null,
      ),
    );
    expect(find.text('Jumlah Hari'), findsNothing);
    expect(find.textContaining('hari'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
    expect(find.text('-'), findsNWidgets(2));
    // Only the always-present Alasan row, and no file actions.
    for (final label in ['Alamat', 'Kontak', 'Lampiran']) {
      expect(find.text(label), findsNothing);
    }
    expect(find.text('Alasan'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('reads each row as its label and value', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpDetail(tester, request: _rejectedSakit);
      for (final (label, value) in [
        ('Tanggal Mulai', 'Kamis, 12 November 2026'),
        ('Alasan', 'Demam'),
        ('Diproses oleh', 'Lina Hukumm'),
        ('Catatan Penolakan', 'Surat dokter belum dilampirkan.'),
      ]) {
        final node = tester.getSemantics(find.text(label));
        expect(node.label, contains(label));
        expect(node.label, contains(value));
      }
    } finally {
      handle.dispose();
    }
  });

  testWidgets('Lihat Lampiran is soft navy, opens the file, waits for it', (
    tester,
  ) async {
    final files = _FakeDownloadNotifier()..gate = Completer<void>();
    await _pumpDetail(
      tester,
      request: _approvedIzin.copyWith(evidenceUrl: 'https://aura.test/b.pdf'),
      files: files,
    );
    await _reveal(tester, 'Lihat Lampiran');
    final attachment = _button('Lihat Lampiran');
    final style = tester.widget<FilledButton>(attachment).style!;
    expect(style.backgroundColor!.resolve({}), const Color(0xFFE8EFFB));
    expect(style.foregroundColor!.resolve({}), const Color(0xFF0B2559));
    expect(
      tester.getRect(attachment).bottom,
      lessThan(tester.getRect(_button('Cetak PDF')).top),
    );

    await tester.tap(attachment);
    await tester.pump();
    expect(files.actions, ['evidence']);
    // Both actions wait while one runs, without a spinner.
    for (final label in ['Lihat Lampiran', 'Cetak PDF']) {
      expect(tester.widget<FilledButton>(_button(label)).onPressed, isNull);
    }
    expect(find.byType(CircularProgressIndicator), findsNothing);

    files.gate!.complete();
    await tester.pumpAndSettle();
    for (final label in ['Lihat Lampiran', 'Cetak PDF']) {
      expect(tester.widget<FilledButton>(_button(label)).onPressed, isNotNull);
    }
  });

  testWidgets('Cetak PDF shows the preparing hint and reports failures', (
    tester,
  ) async {
    final files = _FakeDownloadNotifier(
      result: const Failure(NetworkException(message: 'Gagal mengunduh.')),
    )..gate = Completer<void>();
    await _pumpDetail(tester, request: _approvedIzin, files: files);
    final print = _button('Cetak PDF');
    await _reveal(tester, 'Cetak PDF');
    await tester.tap(print);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(files.actions, ['pdf']);
    expect(find.text('Menyiapkan PDF…'), findsOneWidget);
    expect(tester.widget<FilledButton>(print).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Cetak PDF'), findsOneWidget);

    files.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Menyiapkan PDF…'), findsNothing);
    expect(find.text('Gagal mengunduh.'), findsOneWidget);
  });

  testWidgets('keeps the loading, error, retry and pull-to-refresh', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      load: () => Completer<LeaveRequestModel>().future,
      settle: false,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    var fakes = await _pumpDetail(
      tester,
      load: () async =>
          throw const NetworkException(message: 'Tidak ada koneksi.'),
    );
    expect(find.text('Tidak ada koneksi.'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pump();
    expect(fakes.detail.refreshes, 1);

    await _pumpDetail(tester, load: () async => throw StateError('boom'));
    expect(find.text('Gagal memuat detail pengajuan.'), findsOneWidget);

    fakes = await _pumpDetail(tester);
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(fakes.detail.refreshes, 1);
  });

  testWidgets('captures previews of every status', (tester) async {
    await _pumpDetail(tester);
    await _capturePreview(tester, 'detail_pending_393');
    await _pumpDetail(
      tester,
      request: _approvedIzin.copyWith(evidenceUrl: 'https://aura.test/b.pdf'),
      height: 1100,
    );
    await _capturePreview(tester, 'detail_approved_393');
    await _pumpDetail(tester, request: _rejectedSakit);
    await _capturePreview(tester, 'detail_rejected_393');
    await _pumpDetail(
      tester,
      load: () async =>
          throw const NetworkException(message: 'Tidak ada koneksi internet.'),
    );
    await _capturePreview(tester, 'detail_error_393');
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
          // Every section at once: attachment, decision, note and PDF.
          final request = _rejectedSakit.copyWith(
            status: 'approved',
            statusLabel: 'Disetujui',
            startDate: '2026-09-28',
            endDate: '2026-12-28',
            totalDays: 64,
            reason:
                'Rawat inap di rumah sakit setelah operasi usus buntu, '
                'disertai masa pemulihan sesuai anjuran dokter.',
            address: 'Jl. Merdeka Selatan No. 17, Gambir, Jakarta Pusat',
            contactPhone: '081234567890',
            evidenceUrl: 'https://aura.test/b.pdf',
            canDownloadPdf: true,
          );
          await _pumpDetail(
            tester,
            request: request,
            width: viewport.width,
            height: viewport.height,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          final name =
              'detail_${viewport.width.round()}x${viewport.height.round()}'
              '@$scale';
          await _capturePreview(tester, name);

          // The badge never covers the type or the number.
          final badge = tester.getRect(find.text('Disetujui'));
          for (final text in ['Sakit', request.requestNumber]) {
            expect(badge.overlaps(tester.getRect(find.text(text))), isFalse);
          }

          // Cards and buttons stay inside the gutters, at most Home's width,
          // checked top to bottom as the page scrolls.
          for (final (text, target) in [
            ('Tanggal Mulai', _cardOf('Tanggal Mulai')),
            ('Alasan', _cardOf('Alasan')),
            ('Diproses oleh', _cardOf('Diproses oleh')),
            ('Lihat Lampiran', _button('Lihat Lampiran')),
            ('Cetak PDF', _button('Cetak PDF')),
          ]) {
            await _reveal(tester, text);
            final rect = tester.getRect(target);
            expect(rect.left, greaterThanOrEqualTo(16));
            expect(rect.right, lessThanOrEqualTo(viewport.width - 16));
            expect(rect.width, lessThanOrEqualTo(680));
          }
          expect(tester.takeException(), isNull);
          await _capturePreview(tester, '${name}_end');
        },
      );
    }
  }
}
