import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_queue_controller.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/trusted_attendance_date_provider.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:aura_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:aura_mobile/features/home/presentation/widgets/home_header.dart';
import 'package:aura_mobile/features/home/presentation/widgets/home_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _user = UserModel(
  id: 7,
  name: 'Nadhira Amalia',
  role: 'intern',
  intern: InternModel(
    id: 2,
    nim: '8005312',
    status: 'active',
    division: 'Bagian Operasional',
    program: 'Program Magang',
  ),
);

const _dashboard = AttendanceDashboardModel(
  today: AttendanceTodayModel(
    date: '2026-07-22',
    isWorkingDay: true,
    workHours: WorkHoursModel(start: '08:00', end: '17:00'),
    attendance: AttendanceModel(
      id: 4,
      checkInTime: '07:37',
      status: 'present',
      statusLabel: 'Hadir',
      workMode: 'dinas',
      workModeLabel: 'Dinas',
    ),
  ),
  summary: MonthlySummaryModel(month: '2026-07'),
);

class _Auth extends AuthNotifier {
  _Auth(this.user);

  final UserModel user;
  bool loggedOut = false;

  @override
  Future<AuthState> build() async => AuthState.authenticated(user);

  @override
  Future<void> logout() async {
    loggedOut = true;
    state = const AsyncData(AuthState.unauthenticated());
  }
}

class _Dashboard extends AttendanceDashboardNotifier {
  _Dashboard(this.load);

  final Future<AttendanceDashboardModel> Function() load;
  int loads = 0;

  @override
  Future<AttendanceDashboardModel> build() {
    loads++;
    return load();
  }

  @override
  Future<void> refresh() async {
    loads++;
    state = const AsyncLoading();
    state = await AsyncValue.guard(load);
  }
}

Future<
  ({
    ProviderContainer container,
    GoRouter router,
    _Auth auth,
    _Dashboard dashboard,
  })
>
_pumpHome(
  WidgetTester tester, {
  UserModel user = _user,
  AttendanceDashboardModel data = _dashboard,
  Future<AttendanceDashboardModel> Function()? load,
  int pending = 0,
  AsyncValue<String?> currentDate = const AsyncData('2026-07-22'),
  double width = 390,
  double height = 1000,
  double textScale = 1,
  bool settle = true,
}) async {
  const pixelRatio = bool.fromEnvironment('HOME_PREVIEW') ? 2.0 : 1.0;
  tester.view.physicalSize = Size(width * pixelRatio, height * pixelRatio);
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final auth = _Auth(user);
  final dashboard = _Dashboard(load ?? () async => data);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      authProvider.overrideWith(() => auth),
      attendanceDashboardProvider.overrideWith(() => dashboard),
      pendingAttendanceCountProvider.overrideWith((ref) => pending),
      trustedAttendanceDateProvider.overrideWithValue(currentDate),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (_, _) => const HomeScreen(),
      ),
      for (final path in [
        RoutePaths.profile,
        RoutePaths.attendance,
        RoutePaths.leave,
      ])
        GoRoute(
          path: path,
          builder: (_, _) => Scaffold(body: Text('Destination $path')),
        ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: RepaintBoundary(
            key: const ValueKey('home-preview'),
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
    await tester.pump(const Duration(milliseconds: 100));
  }
  return (
    container: container,
    router: router,
    auth: auth,
    dashboard: dashboard,
  );
}

/// Writes `build/home-preview/<name>.png` when run with HOME_PREVIEW, for
/// visual comparison against the design reference.
Future<void> _capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('HOME_PREVIEW')) return;
  await tester.runAsync(() async {
    final context = tester.element(find.byType(HomeScreen));
    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      await precacheImage(image.image, context);
    }
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('home-preview')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/home-preview').create(recursive: true);
    await File(
      'build/home-preview/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

/// Images decoded from the asset at [path].
Finder _asset(String path) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is ResizeImage &&
      (widget.image as ResizeImage).imageProvider == AssetImage(path),
);

/// Rect of the tappable surface around a menu entry's title.
Rect _menuRect(WidgetTester tester, String title) => tester.getRect(
  find.ancestor(of: find.text(title), matching: find.byType(InkWell)).first,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fontPath = Platform.environment['HOME_PREVIEW_FONT'];
    if (fontPath == null) return;
    final loader = FontLoader('Roboto')
      ..addFont(File(fontPath).readAsBytes().then(ByteData.sublistView));
    await loader.load();
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${File(fontPath).parent.path}/materialicons-regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await iconLoader.load();
  });
  testWidgets(
    'shows real identity, dated attendance and times without unsupported UI',
    (tester) async {
      final harness = await _pumpHome(tester);
      expect(find.text('Nadhira Amalia'), findsNWidgets(2));
      expect(find.text('NIM: 8005312'), findsOneWidget);
      expect(find.text('Bagian Operasional'), findsOneWidget);
      expect(find.text('Absensi, 22 Juli 2026'), findsOneWidget);
      expect(find.text('07:37'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
      // Home is a compact summary: status and work mode are not shown here,
      // but the Dinas attendance itself is untouched in the dashboard state.
      expect(find.text('Dinas'), findsNothing);
      expect(find.text('Hadir'), findsNothing);
      final attendance = harness.container
          .read(attendanceDashboardProvider)
          .value!
          .today
          .attendance!;
      expect(attendance.workMode, 'dinas');
      expect(attendance.statusLabel, 'Hadir');
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.textContaining('Absensi hari ini,'), findsNothing);
      expect(find.text('00:00'), findsNothing);
      expect(find.text('Tepat waktu'), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byIcon(Icons.notifications), findsNothing);
      expect(find.text('SPD'), findsNothing);
      expect(tester.takeException(), isNull);
      await _capturePreview(tester, 'home');
    },
  );

  testWidgets(
    'a snapshot cached on an earlier day shows the trusted date, empty times',
    (tester) async {
      final harness = await _pumpHome(
        tester,
        pending: 1,
        currentDate: const AsyncData('2026-07-23'),
      );
      expect(find.text('Absensi, 23 Juli 2026'), findsOneWidget);
      expect(find.text('Absensi, 22 Juli 2026'), findsNothing);
      expect(find.text('--:--'), findsNWidgets(2));
      expect(find.text('07:37'), findsNothing);
      // A pending capture stays a separate notice, never a confirmed time.
      expect(
        find.textContaining('1 absensi menunggu sinkronisasi'),
        findsOneWidget,
      );
      // Presentation only: the cached snapshot itself is left intact.
      expect(
        harness.container
            .read(attendanceDashboardProvider)
            .value!
            .today
            .attendance!
            .checkInTime,
        '07:37',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('without a trusted date the snapshot keeps its date and times', (
    tester,
  ) async {
    await _pumpHome(tester, currentDate: const AsyncData(null));
    expect(find.text('Absensi, 22 Juli 2026'), findsOneWidget);
    expect(find.text('07:37'), findsOneWidget);
    expect(find.text('--:--'), findsOneWidget);
  });

  testWidgets('missing identity and attendance never become invented values', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      user: const UserModel(id: 8, name: 'Peserta Magang', role: 'intern'),
      data: _dashboard.copyWith(
        today: _dashboard.today.copyWith(attendance: null),
      ),
    );
    expect(find.textContaining('NIM:'), findsNothing);
    expect(find.text('--:--'), findsNWidgets(2));
    expect(find.text('null'), findsNothing);
    expect(find.text('Hadir'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending captures stay distinct from confirmed times', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      pending: 2,
      data: _dashboard.copyWith(
        today: _dashboard.today.copyWith(attendance: null),
      ),
    );
    expect(
      find.textContaining('2 absensi menunggu sinkronisasi'),
      findsOneWidget,
    );
    expect(find.text('--:--'), findsNWidgets(2));
    expect(find.text('Hadir'), findsNothing);
    expect(find.text('07:37'), findsNothing);
  });

  testWidgets('leave and non-working days keep Home to the date and times', (
    tester,
  ) async {
    final harness = await _pumpHome(
      tester,
      data: _dashboard.copyWith(
        today: _dashboard.today.copyWith(
          attendance: null,
          isWorkingDay: false,
          leave: const TodayLeaveModel(type: 'sakit', typeLabel: 'Sakit'),
        ),
      ),
    );
    expect(find.text('Absensi, 22 Juli 2026'), findsOneWidget);
    expect(find.text('--:--'), findsNWidgets(2));
    expect(find.text('Sedang Sakit'), findsNothing);
    expect(find.text('Hari libur'), findsNothing);
    expect(find.text('Hadir'), findsNothing);
    // Presentation only: the leave and holiday data are still loaded.
    final today = harness.container
        .read(attendanceDashboardProvider)
        .value!
        .today;
    expect(today.leave?.typeLabel, 'Sakit');
    expect(today.isWorkingDay, isFalse);
  });

  for (final destination in [
    (label: 'Profil', path: RoutePaths.profile),
    (label: 'Absensi', path: RoutePaths.attendance),
    (label: 'Izin', path: RoutePaths.leave),
  ]) {
    testWidgets('${destination.label} preserves push navigation and back', (
      tester,
    ) async {
      final harness = await _pumpHome(tester);
      await tester.ensureVisible(find.text(destination.label));
      await tester.tap(find.text(destination.label));
      await tester.pumpAndSettle();
      expect(find.text('Destination ${destination.path}'), findsOneWidget);
      harness.router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(harness.dashboard.loads, 1);
    });

    testWidgets('${destination.label} card navigates from anywhere on it', (
      tester,
    ) async {
      await _pumpHome(tester);
      await tester.ensureVisible(find.text(destination.label));
      await tester.pumpAndSettle();
      // Bottom-right corner, where the removed arrow button used to be.
      final card = _menuRect(tester, destination.label);
      await tester.tapAt(card.bottomRight - const Offset(14, 14));
      await tester.pumpAndSettle();
      expect(find.text('Destination ${destination.path}'), findsOneWidget);
    });
  }

  testWidgets('logout calls the existing authentication notifier', (
    tester,
  ) async {
    final harness = await _pumpHome(tester);
    await tester.tap(find.byTooltip('Keluar'));
    await tester.pump();
    expect(harness.auth.loggedOut, isTrue);
    expect(harness.container.read(authProvider).value, isA<Unauthenticated>());
  });

  testWidgets('loading attendance leaves navigation available', (tester) async {
    final response = Completer<AttendanceDashboardModel>();
    await _pumpHome(tester, load: () => response.future, settle: false);
    expect(find.bySemanticsLabel('Memuat absensi'), findsOneWidget);
    await tester.ensureVisible(find.text('Profil'));
    await tester.tap(find.text('Profil'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Destination /profile'), findsOneWidget);
    response.complete(_dashboard);
    await tester.pumpAndSettle();
  });

  testWidgets('attendance errors are local and retry can recover', (
    tester,
  ) async {
    var calls = 0;
    await _pumpHome(
      tester,
      load: () async {
        if (calls++ == 0) throw StateError('Unavailable');
        return _dashboard;
      },
    );
    expect(find.text('Data absensi belum tersedia.'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('07:37'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('profile changes update Home without reloading attendance', (
    tester,
  ) async {
    final harness = await _pumpHome(tester);
    harness.auth.updateUser(_user.copyWith(name: 'Nama Diperbarui'));
    await tester.pumpAndSettle();
    expect(find.text('Nama Diperbarui'), findsNWidgets(2));
    expect(find.text('Nadhira Amalia'), findsNothing);
    expect(harness.dashboard.loads, 1);
  });

  testWidgets('menu exposes an accessible tap action', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpHome(tester);
      const label = 'Profil. Lihat dan kelola informasi profil Anda';
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(label: label, isButton: true, hasTapAction: true),
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets('pull to refresh uses the existing dashboard notifier', (
    tester,
  ) async {
    final harness = await _pumpHome(tester);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(harness.dashboard.loads, 2);
    expect(find.text('07:37'), findsOneWidget);
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
          await _pumpHome(
            tester,
            width: viewport.width,
            height: viewport.height,
            textScale: scale,
            user: _user.copyWith(
              name: 'Nadhira Amalia Putri dengan Nama yang Panjang',
              intern: _user.intern!.copyWith(
                division:
                    'Bagian Optimalisasi dan Pengembangan Operasional Regional',
              ),
            ),
          );
          expect(tester.takeException(), isNull);

          final logo = find.byWidgetPredicate(
            (widget) => widget is Image && widget.semanticLabel == 'AURA',
          );
          expect(tester.getSize(logo).height, lessThanOrEqualTo(48));

          // Menu is either one row of equal cards or one column — never 2 + 1.
          final menu = [
            for (final title in ['Profil', 'Absensi', 'Izin'])
              _menuRect(tester, title),
          ];
          final oneRow = menu.every(
            (rect) =>
                rect.top == menu.first.top && rect.height == menu.first.height,
          );
          final oneColumn = menu.every(
            (rect) =>
                rect.left == menu.first.left && rect.width == menu.first.width,
          );
          expect(oneRow || oneColumn, isTrue, reason: '$menu');

          // The building's visible art never reaches the logout button.
          final building = _asset('assets/images/home/ptpn_building.png');
          final buildingRect = tester.getRect(building.first);
          // The scene runs to the screen edge, with no hard cut-off.
          expect(buildingRect.right, closeTo(viewport.width, 0.5));
          expect(
            // Roofline: the artwork's top 116 of 730 rows are empty canvas.
            buildingRect.top + buildingRect.height * 116 / 730,
            greaterThanOrEqualTo(
              tester.getRect(find.byTooltip('Keluar')).bottom,
            ),
          );

          // Only the lawn edge tucks under the card; the greeting, however
          // long, ends above it.
          final cardTop = tester.getRect(find.byType(HomeOverviewCard)).top;
          expect(
            cardTop - buildingRect.top,
            greaterThanOrEqualTo(buildingRect.height * 0.8),
          );
          expect(
            tester
                .getRect(
                  find
                      .text('Nadhira Amalia Putri dengan Nama yang Panjang')
                      .first,
                )
                .bottom,
            lessThanOrEqualTo(cardTop - 16),
          );

          // Decoration never sizes the header: only its content column does.
          final header = find.byType(HomeHeader);
          expect(
            tester.getSize(header).height,
            tester
                .getSize(
                  find
                      .descendant(of: header, matching: find.byType(Column))
                      .first,
                )
                .height,
          );

          // Two clouds, on screen; the upper one sits in the logo row between
          // the logo and the logout button.
          final clouds = _asset('assets/images/home/cloud.png');
          expect(clouds, findsNWidgets(2));
          for (final cloud in tester.widgetList(clouds)) {
            final rect = tester.getRect(find.byWidget(cloud));
            expect(rect.left, greaterThanOrEqualTo(0), reason: '$rect');
            expect(rect.right, lessThanOrEqualTo(viewport.width));
          }
          final upperCloud = tester.getRect(clouds.first);
          final logoRect = tester.getRect(logo);
          final logoutRect = tester.getRect(find.byTooltip('Keluar'));
          expect(upperCloud.left, greaterThan(logoRect.right));
          expect(upperCloud.right, lessThan(logoutRect.left));
          // The visible cloud fills rows 219–768 of the 887-row canvas.
          final cloudTop = upperCloud.top + upperCloud.height * 219 / 887;
          final cloudBottom = upperCloud.top + upperCloud.height * 768 / 887;
          final logoRow = tester.getRect(
            find.ancestor(of: logo, matching: find.byType(Row)).first,
          );
          expect(
            (cloudTop + cloudBottom) / 2,
            inInclusiveRange(logoRow.top, logoRow.bottom),
          );
          // It stays above the greeting.
          expect(
            cloudBottom,
            lessThan(tester.getRect(find.text('Selamat datang,')).top),
          );

          // Every decorative layer ignores taps.
          for (final decor in [clouds, building]) {
            for (final element in decor.evaluate()) {
              final ignore = find.ancestor(
                of: find.byWidget(element.widget),
                matching: find.byType(IgnorePointer),
              );
              expect(tester.widget<IgnorePointer>(ignore.first).ignoring, true);
            }
          }

          // The building is tinted, except one untinted copy for the sign.
          expect(building, findsNWidgets(2));
          expect(
            find.ancestor(of: building, matching: find.byType(ColorFiltered)),
            findsOneWidget,
          );

          // Truncation depends on real glyph widths: the default test font
          // draws every glyph as a full em square, so check only with Roboto.
          for (final description in [
            if (Platform.environment['HOME_PREVIEW_FONT'] != null) ...[
              'Lihat dan kelola informasi profil Anda',
              'Lakukan absensi kehadiran harian',
              'Ajukan izin, sakit, atau pulang cepat',
            ],
          ]) {
            final paragraph = tester.renderObject<RenderParagraph>(
              find.text(description),
            );
            expect(paragraph.didExceedMaxLines, isFalse, reason: description);
          }

          // Capture the first screen the user sees, before scrolling.
          await _capturePreview(
            tester,
            'home_${viewport.width.toInt()}x${viewport.height.toInt()}'
            '@$scale',
          );
          await tester.ensureVisible(find.text('Tetap semangat!'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'taller screens give the header more room, shorter stay compact',
    (tester) async {
      await _pumpHome(tester, width: 393, height: 640);
      final short = tester.getRect(find.byType(HomeOverviewCard)).top;
      tester.view.physicalSize =
          const Size(393, 852) * tester.view.devicePixelRatio;
      await tester.pumpAndSettle();
      final tall = tester.getRect(find.byType(HomeOverviewCard)).top;
      expect(tall, greaterThan(short));
      // Growth is bounded: the header never stretches to fill the viewport.
      expect(tall - short, lessThanOrEqualTo(40));
    },
  );

  for (final width in [360.0, 393.0, 430.0]) {
    testWidgets('normal phone width $width keeps three cards in one row', (
      tester,
    ) async {
      await _pumpHome(tester, width: width);
      final profile = _menuRect(tester, 'Profil');
      final attendance = _menuRect(tester, 'Absensi');
      final leave = _menuRect(tester, 'Izin');
      expect(attendance.top, profile.top);
      expect(leave.top, profile.top);
      expect(attendance.height, profile.height);
      expect(leave.height, profile.height);
      expect(profile.right, lessThan(attendance.left));
    });
  }

  testWidgets('narrow width stacks the menu as single-column tiles', (
    tester,
  ) async {
    await _pumpHome(tester, width: 320);
    final profile = _menuRect(tester, 'Profil');
    final attendance = _menuRect(tester, 'Absensi');
    expect(attendance.left, profile.left);
    expect(attendance.top, greaterThan(profile.bottom));
  });

  testWidgets('check-out mirrors check-in with its icon trailing', (
    tester,
  ) async {
    await _pumpHome(tester);
    final card = find.byType(HomeOverviewCard);
    final checkInIcon = find.descendant(
      of: card,
      matching: find.byIcon(Icons.login_rounded),
    );
    final checkOutIcon = find.descendant(
      of: card,
      matching: find.byIcon(Icons.logout_rounded),
    );
    expect(
      tester.getRect(checkInIcon).right,
      lessThan(tester.getRect(find.text('07:37')).left),
    );
    expect(
      tester.getRect(checkOutIcon).left,
      greaterThan(tester.getRect(find.text('--:--')).right),
    );
  });
}
