import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/features/attendance/data/models/attendance_models.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_dashboard_notifier.dart';
import 'package:aura_mobile/features/attendance/presentation/providers/attendance_queue_controller.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:aura_mobile/features/home/presentation/screens/home_screen.dart';
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
  double width = 390,
  double textScale = 1,
  bool settle = true,
}) async {
  const pixelRatio = bool.fromEnvironment('HOME_PREVIEW') ? 2.0 : 1.0;
  tester.view.physicalSize = Size(width * pixelRatio, 1000 * pixelRatio);
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
    'shows real identity, dated attendance and Dinas without unsupported UI',
    (tester) async {
      await _pumpHome(tester);
      expect(find.text('Nadhira Amalia'), findsNWidgets(2));
      expect(find.text('NIM: 8005312'), findsOneWidget);
      expect(find.text('Bagian Operasional'), findsOneWidget);
      expect(find.text('Absensi, 22 Juli 2026'), findsOneWidget);
      expect(find.text('07:37'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
      expect(find.text('Dinas'), findsOneWidget);
      expect(find.text('Hadir'), findsOneWidget);
      expect(find.textContaining('Absensi hari ini,'), findsNothing);
      expect(find.text('00:00'), findsNothing);
      expect(find.text('Tepat waktu'), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byIcon(Icons.notifications), findsNothing);
      expect(find.text('SPD'), findsNothing);
      expect(tester.takeException(), isNull);

      if (const bool.fromEnvironment('HOME_PREVIEW')) {
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
            'build/home-preview/home.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    },
  );

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

  testWidgets('leave and non-working days are sourced from the dashboard', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      data: _dashboard.copyWith(
        today: _dashboard.today.copyWith(
          attendance: null,
          isWorkingDay: false,
          leave: const TodayLeaveModel(type: 'sakit', typeLabel: 'Sakit'),
        ),
      ),
    );
    expect(find.text('Sedang Sakit'), findsOneWidget);
    expect(find.text('Hari libur'), findsOneWidget);
    expect(find.text('Hadir'), findsNothing);
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
    (width: 320.0, scale: 1.0),
    (width: 390.0, scale: 1.5),
    (width: 320.0, scale: 2.0),
    (width: 768.0, scale: 1.0),
  ]) {
    testWidgets(
      'fits width ${viewport.width} and text scale ${viewport.scale}',
      (tester) async {
        await _pumpHome(
          tester,
          width: viewport.width,
          textScale: viewport.scale,
          user: _user.copyWith(
            name: 'Nadhira Amalia Putri dengan Nama yang Panjang',
            intern: _user.intern!.copyWith(
              division:
                  'Bagian Optimalisasi dan Pengembangan Operasional Regional',
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Tetap semangat!'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
