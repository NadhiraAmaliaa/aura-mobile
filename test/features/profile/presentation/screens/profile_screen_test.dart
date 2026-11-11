import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/config/env.dart';
import 'package:aura_mobile/core/providers/core_providers.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:aura_mobile/features/profile/presentation/providers/avatar_notifier.dart';
import 'package:aura_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _navy = Color(0xFF0B2559);

/// The reference design's intern: no contact details yet, no photo.
const _intern = UserModel(
  id: 1,
  name: 'Aurelia Safanisa',
  role: 'intern',
  intern: InternModel(id: 1, nim: '20304444', status: 'active'),
);

const _withContact = UserModel(
  id: 2,
  name: 'Bima Sakti Pratama',
  email: 'bima.pratama@student.aura.test',
  role: 'intern',
  intern: InternModel(
    id: 2,
    nim: '1301223344',
    phone: '081234567890',
    status: 'active',
  ),
);

/// Serves [load]'s session and records logouts instead of calling the API.
class _FakeAuth extends AuthNotifier {
  _FakeAuth(this.load);

  final Future<AuthState> Function() load;
  int logouts = 0;

  @override
  Future<AuthState> build() => load();

  @override
  Future<void> logout() async {
    logouts++;
    state = const AsyncData(AuthState.unauthenticated());
  }
}

/// Stays loading while [busy], as during a photo upload.
class _FakeAvatar extends AvatarNotifier {
  _FakeAvatar({this.busy = false});

  final bool busy;

  @override
  Future<void> build() async {
    if (busy) await Completer<void>().future;
  }
}

const _pixelRatio = bool.fromEnvironment('PROFILE_PREVIEW') ? 2.0 : 1.0;

void _setViewport(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width * _pixelRatio, height * _pixelRatio);
  tester.view.devicePixelRatio = _pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Pumps the profile at `/profile`, above a stub Home, with stub pages for
/// its menu destinations.
Future<_FakeAuth> _pumpProfile(
  WidgetTester tester, {
  UserModel user = _intern,
  Future<AuthState> Function()? load,
  bool avatarBusy = false,
  double width = 393,
  double height = 852,
  double textScale = 1,
  bool settle = true,
}) async {
  _setViewport(tester, width, height);
  late _FakeAuth auth;
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('Home')),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (_, _) => const ProfileScreen(),
        routes: [
          for (final (path, name, label) in [
            (
              RoutePaths.profileInternship,
              RouteNames.profileInternship,
              'Halaman Informasi Magang',
            ),
            (
              RoutePaths.profileContact,
              RouteNames.profileContact,
              'Halaman Ubah Kontak',
            ),
            (
              RoutePaths.profilePassword,
              RouteNames.profilePassword,
              'Halaman Ganti Password',
            ),
          ])
            GoRoute(
              path: path,
              name: name,
              builder: (_, _) => Scaffold(appBar: AppBar(), body: Text(label)),
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
        authProvider.overrideWith(
          () => auth = _FakeAuth(
            load ?? () async => AuthState.authenticated(user),
          ),
        ),
        avatarProvider.overrideWith(() => _FakeAvatar(busy: avatarBusy)),
        appEnvProvider.overrideWithValue(
          const AppEnv(
            flavor: Flavor.dev,
            baseUrl: 'https://aura.test/api/v1',
            sentryDsn: '',
          ),
        ),
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
            key: const ValueKey('profile-preview'),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  // Opened from Home, as the app does, so the back button shows.
  unawaited(router.push(RoutePaths.profile));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // Past the push transition, while a spinner keeps the frames coming.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }
  return auth;
}

/// Writes `build/profile-preview/<name>.png` when run with PROFILE_PREVIEW.
Future<void> _capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('PROFILE_PREVIEW')) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('profile-preview')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/profile-preview').create(recursive: true);
    await File(
      'build/profile-preview/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

/// The white card holding [text].
Finder _cardOf(String text) => find
    .ancestor(
      of: find.text(text, skipOffstage: false),
      matching: find.byType(Material),
    )
    .first;

/// The coloured box nearest [finder]: a tile, pill or card surface.
BoxDecoration _boxAround(WidgetTester tester, Finder finder) =>
    tester
            .widget<DecoratedBox>(
              find
                  .ancestor(of: finder, matching: find.byType(DecoratedBox))
                  .first,
            )
            .decoration
        as BoxDecoration;

/// Scrolls the page down until [finder] is on screen.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

final _cameraButton = find.bySemanticsLabel('Ubah foto profil');

void main() {
  setUpAll(() async {
    // Real Roboto weights for previews; the test font is used otherwise.
    final fontDir = Platform.environment['PROFILE_PREVIEW_FONT_DIR'];
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

  testWidgets('follows the reference: AURA app bar and profile card', (
    tester,
  ) async {
    await _pumpProfile(tester);

    // Transparent app bar with a centred navy title and back button.
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(appBar.centerTitle, isTrue);
    expect(appBar.foregroundColor, _navy);
    expect(appBar.titleTextStyle!.color, _navy);
    expect(find.byType(BackButton), findsOneWidget);
    final title = tester.getRect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Profil')),
    );
    expect(title.center.dx, moreOrLessEquals(393 / 2, epsilon: 1));

    // One white rounded card: photo, name and NIM pill beside it.
    final card = tester.widget<Material>(_cardOf('Aurelia Safanisa'));
    expect(card.color, Colors.white);
    expect(card.borderRadius, BorderRadius.circular(20));
    expect(card.clipBehavior, Clip.antiAlias);
    expect(
      _boxAround(tester, _cardOf('Aurelia Safanisa')).boxShadow,
      isNotEmpty,
    );
    expect(
      tester.widget<Text>(find.text('Aurelia Safanisa')).style!.color,
      _navy,
    );
    expect(
      _boxAround(tester, find.text('20304444 (NIM)')).color,
      const Color(0xFFE3EEFF),
    );
    expect(
      tester.getRect(find.text('20304444 (NIM)')).top,
      greaterThan(tester.getRect(find.text('Aurelia Safanisa')).bottom),
    );

    // No photo yet: the placeholder inside a soft green ring.
    expect(find.byIcon(Icons.person), findsOneWidget);
    final ring = _boxAround(tester, find.byType(CircleAvatar));
    expect(ring.shape, BoxShape.circle);
    expect(ring.border!.top.color, const Color(0xFFB9E0AB));

    // The waves are painted behind the content, inside the clipped card.
    final waves = find.descendant(
      of: _cardOf('Aurelia Safanisa'),
      matching: find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter != null,
      ),
    );
    expect(waves, findsOneWidget);
    expect(tester.getRect(waves), tester.getRect(_cardOf('Aurelia Safanisa')));
    expect(find.byType(Image), findsNothing);
  });

  // The 1em-wide test font fits the NIM pill beside the photo only on a wide
  // page; phone widths are covered by the PROFILE_PREVIEW captures with
  // Roboto, where it fits at 360dp and up.
  testWidgets('puts the name beside the photo, or under it when narrow', (
    tester,
  ) async {
    await _pumpProfile(tester, width: 768, height: 1024);
    var avatar = tester.getRect(find.byType(CircleAvatar));
    var name = tester.getRect(find.text('Aurelia Safanisa'));
    expect(name.left, greaterThan(avatar.right));
    expect(name.center.dy, lessThan(avatar.bottom));

    await _pumpProfile(tester, width: 320, height: 568, textScale: 2);
    avatar = tester.getRect(find.byType(CircleAvatar));
    name = tester.getRect(find.text('Aurelia Safanisa'));
    expect(name.top, greaterThan(avatar.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups both contacts in one card under the gold title', (
    tester,
  ) async {
    await _pumpProfile(tester, user: _withContact);
    expect(
      tester.widget<Text>(find.text('Informasi Kontak')).style!.color,
      _navy,
    );
    // The gold accent bar starts the title row.
    final accent = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          (widget.decoration as BoxDecoration?)?.color ==
              const Color(0xFFF2C94C),
    );
    expect(accent, findsNWidgets(2));

    for (final (label, value) in [
      // May wrap after the "@" (a zero-width space), never mid-word...
      ('Email', 'bima.pratama@​student.aura.test'),
      ('Nomor HP', '081234567890'),
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(find.text(value), findsOneWidget);
    }
    // ...while screen readers hear the address as is.
    expect(
      tester
          .widget<Text>(find.text('bima.pratama@​student.aura.test'))
          .semanticsLabel,
      'bima.pratama@student.aura.test',
    );
    final card = tester.element(_cardOf('Email'));
    expect(identical(card, tester.element(_cardOf('Nomor HP'))), isTrue);
    expect(
      find.descendant(of: _cardOf('Email'), matching: find.byType(Divider)),
      findsOneWidget,
    );
    expect(
      _boxAround(tester, find.byIcon(Icons.mail_outline)).color,
      const Color(0xFFE3EEFF),
    );
    expect(
      _boxAround(tester, find.byIcon(Icons.call_outlined)).color,
      const Color(0xFFE3F4DC),
    );
  });

  testWidgets('shows "-" for missing contacts and hides a missing NIM', (
    tester,
  ) async {
    await _pumpProfile(tester);
    expect(find.text('-'), findsNWidgets(2));

    await _pumpProfile(
      tester,
      user: const UserModel(id: 3, name: 'Admin AURA', role: 'admin'),
    );
    expect(find.textContaining('(NIM)'), findsNothing);
    expect(find.text('Admin AURA'), findsOneWidget);
  });

  testWidgets('the pastel edit button opens the contact editor', (
    tester,
  ) async {
    await _pumpProfile(tester);
    final edit = find.byTooltip('Ubah kontak');
    final buttonFinder = find.ancestor(
      of: edit,
      matching: find.byType(IconButton),
    );
    final button = tester.widget<IconButton>(buttonFinder);
    expect(button.style!.backgroundColor!.resolve({}), const Color(0xFFE3EEFF));
    expect(button.style!.foregroundColor!.resolve({}), _navy);
    // A 44dp rounded square inside the 48dp tap target.
    expect(button.style!.fixedSize!.resolve({}), const Size.square(44));
    expect(tester.getSize(buttonFinder), const Size.square(48));

    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(find.text('Halaman Ubah Kontak'), findsOneWidget);
  });

  testWidgets('menu: one card, pastel tiles, chevrons and navigation', (
    tester,
  ) async {
    await _pumpProfile(tester);
    await _reveal(tester, find.text('Logout'));
    final card = tester.element(_cardOf('Informasi Magang'));
    for (final title in ['Ganti Password', 'Logout']) {
      expect(identical(card, tester.element(_cardOf(title))), isTrue);
    }
    expect(
      find.descendant(
        of: _cardOf('Informasi Magang'),
        matching: find.byType(Divider),
      ),
      findsNWidgets(2),
    );
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    for (final (icon, tint) in [
      (Icons.description_outlined, 0xFFE3EEFF),
      (Icons.lock_outline, 0xFFFFF1D6),
      (Icons.logout, 0xFFFDE3E3),
    ]) {
      expect(_boxAround(tester, find.byIcon(icon)).color, Color(tint));
    }
    expect(
      tester.widget<Text>(find.text('Logout')).style!.color,
      const Color(0xFFC62F3B),
    );

    for (final (title, page) in [
      ('Informasi Magang', 'Halaman Informasi Magang'),
      ('Ganti Password', 'Halaman Ganti Password'),
    ]) {
      await _reveal(tester, find.text(title));
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.text(page), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('logout keeps its confirmation dialog', (tester) async {
    final auth = await _pumpProfile(tester);
    await _reveal(tester, find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Apakah Anda yakin ingin keluar dari akun?'), findsOne);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(auth.logouts, 0);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await tester.pump();
    expect(auth.logouts, 1);
  });

  testWidgets('the camera button opens the photo options', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpProfile(tester);
      final camera = find.byIcon(Icons.photo_camera);
      final button = tester.widget<Material>(
        find.ancestor(of: camera, matching: find.byType(Material)).first,
      );
      expect(button.color, _navy);
      // On the photo's lower right.
      final avatar = tester.getRect(find.byType(CircleAvatar));
      final cameraRect = tester.getRect(camera);
      expect(cameraRect.center.dx, greaterThan(avatar.center.dx));
      expect(cameraRect.center.dy, greaterThan(avatar.center.dy));
      expect(_cameraButton, findsOneWidget);

      await tester.tap(camera);
      await tester.pumpAndSettle();
      expect(find.text('Ambil dari kamera'), findsOneWidget);
      expect(find.text('Pilih dari galeri'), findsOneWidget);
      // Nothing to remove without a photo.
      expect(find.text('Hapus foto'), findsNothing);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('a photo change in progress covers the photo and waits', (
    tester,
  ) async {
    await _pumpProfile(tester, avatarBusy: true, settle: false);
    final spinner = find.descendant(
      of: _cardOf('Aurelia Safanisa'),
      matching: find.byType(CircularProgressIndicator),
    );
    expect(spinner, findsOneWidget);
    await tester.tap(find.byIcon(Icons.photo_camera));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Ambil dari kamera'), findsNothing);
  });

  testWidgets('keeps the loading state while the session resolves', (
    tester,
  ) async {
    await _pumpProfile(
      tester,
      load: () => Completer<AuthState>().future,
      settle: false,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Informasi Kontak'), findsNothing);
  });

  testWidgets('captures previews', (tester) async {
    await _pumpProfile(tester);
    await _capturePreview(tester, 'profile_393');
    await _pumpProfile(tester, user: _withContact);
    await _capturePreview(tester, 'profile_393_contact');
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
          await _pumpProfile(
            tester,
            user: _withContact,
            width: viewport.width,
            height: viewport.height,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          final name =
              'profile_${viewport.width.round()}x${viewport.height.round()}'
              '@$scale';
          await _capturePreview(tester, name);

          // The name sits beside the photo while it fits, under it otherwise,
          // and never overlaps it.
          final avatar = tester.getRect(find.byType(CircleAvatar));
          final title = tester.getRect(find.text('Bima Sakti Pratama'));
          expect(
            title.left > avatar.right || title.top > avatar.bottom,
            isTrue,
          );

          // Cards and the edit button stay inside the gutters, at most Home's
          // width, checked top to bottom as the page scrolls.
          for (final (text, target) in [
            ('Bima Sakti Pratama', _cardOf('Bima Sakti Pratama')),
            ('Informasi Kontak', find.byTooltip('Ubah kontak')),
            ('Email', _cardOf('Email')),
            ('Logout', _cardOf('Logout')),
          ]) {
            await _reveal(tester, find.text(text));
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
