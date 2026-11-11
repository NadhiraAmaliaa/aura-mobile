import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/features/leave/data/models/leave_models.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_list_notifier.dart';
import 'package:aura_mobile/features/leave/presentation/providers/leave_list_state.dart';
import 'package:aura_mobile/features/leave/presentation/screens/leave_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _sakitAsset = 'assets/images/leave/sakit.png';
const _izinAsset = 'assets/images/leave/izin.png';

LeaveRequestModel _request(
  int id, {
  String type = 'izin',
  String status = 'pending',
  String? start = '2026-11-12',
  String? end = '2026-11-14',
  int? totalDays = 3,
}) => LeaveRequestModel(
  id: id,
  requestNumber: 'LR-20261110-${id.toString().padLeft(4, '0')}',
  type: type,
  typeLabel: switch (type) {
    'sakit' => 'Sakit',
    'izin' => 'Izin',
    _ => 'Dinas Luar',
  },
  reason: 'Keperluan keluarga',
  startDate: start,
  endDate: end,
  totalDays: totalDays,
  status: status,
  statusLabel: switch (status) {
    'pending' => 'Menunggu',
    'approved' => 'Disetujui',
    'rejected' => 'Ditolak',
    _ => 'Dibatalkan',
  },
);

LeaveListState _page(
  List<LeaveRequestModel> items, {
  bool hasMore = false,
  bool isLoadingMore = false,
  bool isOffline = false,
}) => LeaveListState(
  items: items,
  pagination: LeavePaginationModel(hasMore: hasMore),
  isLoadingMore: isLoadingMore,
  isOffline: isOffline,
);

/// The reference design's two pending requests.
final _pending = [
  _request(2, type: 'sakit', end: '2026-11-14', totalDays: 2),
  _request(1, start: '2026-11-11', end: '2026-11-11', totalDays: 1),
];

/// Serves [load]'s result instead of the repository and counts the calls the
/// screen makes.
class _FakeLeaveListNotifier extends LeaveListNotifier {
  _FakeLeaveListNotifier(this.load);

  final Future<LeaveListState> Function() load;
  int refreshes = 0;
  int loadMores = 0;

  @override
  Future<LeaveListState> build(LeaveListFilter filter) => load();

  @override
  Future<void> refresh() async {
    refreshes++;
  }

  @override
  Future<void> loadMore() async {
    loadMores++;
  }
}

const _pixelRatio = bool.fromEnvironment('LEAVE_PREVIEW') ? 2.0 : 1.0;

void _setViewport(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width * _pixelRatio, height * _pixelRatio);
  tester.view.devicePixelRatio = _pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Pumps the [filter] list under `/leave`, with a stub detail page to open.
Future<_FakeLeaveListNotifier> _pumpList(
  WidgetTester tester, {
  LeaveListFilter filter = LeaveListFilter.pending,
  Future<LeaveListState> Function()? load,
  double width = 393,
  double height = 852,
  double textScale = 1,
  bool settle = true,
}) async {
  _setViewport(tester, width, height);
  late _FakeLeaveListNotifier fake;
  final router = GoRouter(
    initialLocation:
        '${RoutePaths.leave}/'
        '${filter == LeaveListFilter.pending ? RoutePaths.leavePending : RoutePaths.leaveHistory}',
    routes: [
      GoRoute(
        path: RoutePaths.leave,
        name: RouteNames.leave,
        builder: (_, _) => const Scaffold(body: Text('Landing')),
        routes: [
          GoRoute(
            path: RoutePaths.leavePending,
            name: RouteNames.leavePending,
            builder: (_, _) =>
                const LeaveListScreen(filter: LeaveListFilter.pending),
          ),
          GoRoute(
            path: RoutePaths.leaveHistory,
            name: RouteNames.leaveHistory,
            builder: (_, _) =>
                const LeaveListScreen(filter: LeaveListFilter.history),
          ),
          GoRoute(
            path: RoutePaths.leaveDetail,
            name: RouteNames.leaveDetail,
            builder: (_, state) =>
                Scaffold(body: Text('Detail ${state.pathParameters['id']}')),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      // A fresh container per pump, so each call gets its own fake.
      key: UniqueKey(),
      retry: (_, _) => null,
      overrides: [
        leaveListProvider.overrideWith2(
          (_) => fake = _FakeLeaveListNotifier(
            load ?? () async => _page(_pending),
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        // The list keeps its light design whatever the app theme.
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: RepaintBoundary(
            key: const ValueKey('list-preview'),
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
  return fake;
}

/// Writes `build/leave-preview/<name>.png` when run with LEAVE_PREVIEW.
Future<void> _capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('LEAVE_PREVIEW')) return;
  await tester.runAsync(() async {
    final context = tester.element(find.byType(LeaveListScreen));
    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      await precacheImage(image.image, context);
    }
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('list-preview')),
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

/// The range "[start] – [end]": one line while it fits, otherwise split
/// after the dash, as the 1em-wide test font does at phone widths.
void _expectRange(String start, String end) {
  if (find.text('$start – $end').evaluate().length == 1) return;
  expect(find.text('$start –'), findsOneWidget);
  expect(find.text(end), findsOneWidget);
}

/// The tappable card showing [number].
Finder _card(String number) =>
    find.ancestor(of: find.text(number), matching: find.byType(InkWell)).first;

/// The nearest coloured box around [finder]: a tile, badge or pill.
BoxDecoration _boxAround(WidgetTester tester, Finder finder) =>
    tester
            .widget<DecoratedBox>(
              find
                  .ancestor(of: finder, matching: find.byType(DecoratedBox))
                  .first,
            )
            .decoration
        as BoxDecoration;

Color? _textColor(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

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

  testWidgets('opens on the cards right under the AURA app bar', (
    tester,
  ) async {
    await _pumpList(tester);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Menunggu Persetujuan'),
      ),
      findsOneWidget,
    );
    // No illustration or intro above the list.
    expect(
      tester.getRect(_card('LR-20261110-0002')).top -
          tester.getRect(find.byType(AppBar)).bottom,
      lessThanOrEqualTo(8),
    );

    // The reference card's content, newest first.
    _expectRange('12 November 2026', '14 November 2026');
    for (final text in [
      'Sakit',
      'LR-20261110-0002',
      '2 hari',
      'Izin',
      'LR-20261110-0001',
      '11 November 2026',
      '1 hari',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('Menunggu'), findsNWidgets(2));
    expect(
      tester.getRect(_card('LR-20261110-0001')).top,
      greaterThan(tester.getRect(_card('LR-20261110-0002')).bottom),
    );

    // White, rounded and softly shadowed.
    final card = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('LR-20261110-0002'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(card.color, Colors.white);
    expect(card.borderRadius, BorderRadius.circular(20));
    final surface = _boxAround(tester, find.byWidget(card));
    expect(surface.boxShadow, isNotEmpty);
  });

  testWidgets('tints sakit pink and izin green around the provided icons', (
    tester,
  ) async {
    await _pumpList(tester);
    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images.map((image) => (image.image as AssetImage).assetName), [
      _sakitAsset,
      _izinAsset,
    ]);

    for (final (asset, tint, foreground, days) in [
      (_sakitAsset, 0xFFFFE5E8, 0xFFC62F3B, '2 hari'),
      (_izinAsset, 0xFFE3F4DC, 0xFF237A12, '1 hari'),
    ]) {
      final image = find.image(AssetImage(asset));
      expect(tester.getSize(image), const Size.square(30));
      // The tile behind the icon is drawn in Flutter.
      final tile = find
          .ancestor(of: image, matching: find.byType(DecoratedBox))
          .first;
      expect(tester.getSize(tile), const Size.square(48));
      expect(_boxAround(tester, image).color, Color(tint));
      expect(_boxAround(tester, find.text(days)).color, Color(tint));
      expect(_textColor(tester, days), Color(foreground));
    }
  });

  testWidgets('colours each status: pending, approved, rejected, other', (
    tester,
  ) async {
    await _pumpList(
      tester,
      filter: LeaveListFilter.history,
      load: () async => _page([
        _request(4, status: 'approved'),
        _request(3, type: 'sakit', status: 'rejected'),
        _request(2, status: 'cancelled'),
        _request(1, type: 'dinas', status: 'pending'),
      ]),
    );
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Riwayat Pengajuan'),
      ),
      findsOneWidget,
    );
    for (final (label, background, foreground) in [
      ('Menunggu', 0xFFD9F1F8, 0xFF155A7A),
      ('Disetujui', 0xFFDDF3E1, 0xFF1E6B2E),
      ('Ditolak', 0xFFFDE3E3, 0xFFB3261E),
      ('Dibatalkan', 0xFFECEFF3, 0xFF58636A),
    ]) {
      expect(_boxAround(tester, find.text(label)).color, Color(background));
      expect(_textColor(tester, label), Color(foreground));
    }
    // A type without its own icon gets the AURA blue and a generic one.
    expect(find.byIcon(Icons.event_note_outlined), findsOneWidget);
    expect(
      _boxAround(tester, find.byIcon(Icons.event_note_outlined)).color,
      const Color(0xFFE3EEFF),
    );
  });

  testWidgets('both lists draw the same card', (tester) async {
    final request = _request(9, type: 'sakit');
    final rects = <Rect>[];
    for (final filter in LeaveListFilter.values) {
      await _pumpList(
        tester,
        filter: filter,
        load: () async => _page([request]),
      );
      rects.add(tester.getRect(_card('LR-20261110-0009')));
    }
    expect(rects.last, rects.first);
  });

  testWidgets('hides an unknown day count and keeps the date fallbacks', (
    tester,
  ) async {
    await _pumpList(
      tester,
      load: () async => _page([
        _request(2, totalDays: null),
        _request(1, start: null, end: null, totalDays: null),
      ]),
    );
    expect(find.textContaining('hari'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
    _expectRange('12 November 2026', '14 November 2026');
    expect(find.text('-'), findsOneWidget);
  });

  // At 320dp with 2x text neither font fits a two-date range on one line.
  testWidgets('breaks a long range after its dash, keeping each date', (
    tester,
  ) async {
    await _pumpList(
      tester,
      width: 320,
      height: 568,
      textScale: 2,
      load: () async => _page([_request(1, end: '2026-12-28')]),
    );
    final start = tester.getRect(find.text('12 November 2026 –'));
    final end = tester.getRect(find.text('28 Desember 2026'));
    expect(end.top, greaterThanOrEqualTo(start.bottom));
    expect(end.left, start.left);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the request detail on tap', (tester) async {
    await _pumpList(tester);
    await tester.tap(_card('LR-20261110-0001'));
    await tester.pumpAndSettle();
    expect(find.text('Detail 1'), findsOneWidget);
  });

  testWidgets('keeps the loading, empty and error states', (tester) async {
    await _pumpList(
      tester,
      load: () => Completer<LeaveListState>().future,
      settle: false,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    for (final (filter, message) in [
      (
        LeaveListFilter.pending,
        'Belum ada pengajuan yang menunggu persetujuan.',
      ),
      (LeaveListFilter.history, 'Belum ada riwayat pengajuan.'),
    ]) {
      await _pumpList(tester, filter: filter, load: () async => _page([]));
      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    }

    final notifier = await _pumpList(
      tester,
      load: () async =>
          throw const NetworkException(message: 'Tidak ada koneksi.'),
    );
    expect(find.text('Tidak ada koneksi.'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pump();
    expect(notifier.refreshes, 1);

    await _pumpList(tester, load: () async => throw StateError('boom'));
    expect(find.text('Gagal memuat data pengajuan.'), findsOneWidget);
  });

  testWidgets('keeps the offline notice and the list footer', (tester) async {
    await _pumpList(tester, load: () async => _page(_pending, isOffline: true));
    expect(
      find.text(
        'Anda sedang offline. Menampilkan data terakhir yang tersimpan.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tidak ada data lagi'), findsOneWidget);

    await _pumpList(
      tester,
      load: () async => _page(_pending, hasMore: true, isLoadingMore: true),
      settle: false,
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Tidak ada data lagi'), findsNothing);

    await _pumpList(tester, load: () async => _page(_pending, hasMore: true));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Tidak ada data lagi'), findsNothing);
  });

  testWidgets('loads more near the end and refreshes on pull', (tester) async {
    final many = [for (var id = 20; id > 0; id--) _request(id)];
    var notifier = await _pumpList(
      tester,
      load: () async => _page(many, hasMore: true),
    );
    expect(notifier.loadMores, 0);
    await tester.drag(find.byType(ListView), const Offset(0, -6000));
    await tester.pumpAndSettle();
    expect(notifier.loadMores, greaterThan(0));

    // Back to the top without overscrolling, then pull down.
    tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    expect(notifier.refreshes, 0);
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(notifier.refreshes, 1);

    // The last page never asks for more.
    notifier = await _pumpList(tester, load: () async => _page(many));
    await tester.drag(find.byType(ListView), const Offset(0, -6000));
    await tester.pumpAndSettle();
    expect(notifier.loadMores, 0);
  });

  testWidgets('captures previews of both lists', (tester) async {
    await _pumpList(tester);
    await _capturePreview(tester, 'list_pending_393');
    await _pumpList(
      tester,
      filter: LeaveListFilter.history,
      load: () async => _page([
        _request(4, type: 'sakit', status: 'approved', totalDays: 2),
        _request(3, status: 'rejected', end: '2026-11-03', start: '2026-11-03'),
        _request(2, type: 'sakit', status: 'cancelled', totalDays: null),
      ]),
    );
    await _capturePreview(tester, 'list_history_393');
    await _pumpList(tester, load: () async => _page([]));
    await _capturePreview(tester, 'list_empty_393');
    await _pumpList(
      tester,
      load: () async =>
          throw const NetworkException(message: 'Tidak ada koneksi internet.'),
    );
    await _capturePreview(tester, 'list_error_393');
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
          final requests = [
            _request(3, type: 'sakit', end: '2026-12-28', totalDays: 34),
            _request(2, status: 'approved', start: '2026-09-28'),
            _request(1, type: 'dinas', status: 'cancelled'),
          ];
          await _pumpList(
            tester,
            filter: LeaveListFilter.history,
            load: () async => _page(requests),
            width: viewport.width,
            height: viewport.height,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          await _capturePreview(
            tester,
            'list_${viewport.width.round()}x${viewport.height.round()}'
            '@$scale',
          );

          for (final request in requests) {
            final number = find.text(request.requestNumber);
            await tester.ensureVisible(number);
            await tester.pumpAndSettle();
            // Inside the page gutters, at most Home's content width.
            final card = tester.getRect(_card(request.requestNumber));
            expect(card.left, greaterThanOrEqualTo(16));
            expect(card.right, lessThanOrEqualTo(viewport.width - 16));
            expect(card.width, lessThanOrEqualTo(680));
            // The badge never covers the type or the number.
            final badge = tester.getRect(find.text(request.statusLabel));
            for (final text in [request.typeLabel, request.requestNumber]) {
              expect(badge.overlaps(tester.getRect(find.text(text))), isFalse);
            }
            expect(badge.right, lessThanOrEqualTo(card.right));
            // The number stays on one line whenever the card is wide enough.
            final paragraph = tester.renderObject<RenderParagraph>(number);
            if (paragraph.getMaxIntrinsicWidth(double.infinity) <=
                card.width - 32) {
              expect(
                paragraph.size.height,
                moreOrLessEquals(
                  paragraph.getMinIntrinsicHeight(double.infinity),
                ),
              );
            }
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
