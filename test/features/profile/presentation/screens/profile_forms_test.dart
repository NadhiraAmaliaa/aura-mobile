import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/auth/data/models/auth_models.dart';
import 'package:aura_mobile/features/auth/data/models/user_model.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:aura_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:aura_mobile/features/profile/presentation/providers/change_password_notifier.dart';
import 'package:aura_mobile/features/profile/presentation/providers/profile_edit_notifier.dart';
import 'package:aura_mobile/features/profile/presentation/screens/change_password_screen.dart';
import 'package:aura_mobile/features/profile/presentation/screens/contact_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _navy = Color(0xFF0B2559);
const _muted = Color(0xFF58636A);
const _fieldBorder = Color(0xFFD5DEE8);
const _note = 'Pastikan email dan nomor HP yang kamu masukkan sudah benar.';

/// An intern with an email but no phone number yet.
const _user = UserModel(
  id: 1,
  name: 'Aurelia Safanisa',
  email: 'aurelia@aura.test',
  role: 'intern',
  intern: InternModel(id: 1, nim: '20304444', status: 'active'),
);

class _FakeAuth extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState.authenticated(_user);
}

/// Records contact saves; [gate] holds the response back.
class _FakeContact extends ProfileEditNotifier {
  _FakeContact({this.result = const Success(_user)});

  final ApiResult<UserModel> result;
  final requests = <ContactUpdateRequest>[];
  Completer<void>? gate;

  @override
  Future<ApiResult<UserModel>> updateContact(
    ContactUpdateRequest request,
  ) async {
    requests.add(request);
    await gate?.future;
    return result;
  }
}

/// Records password changes; [gate] holds the response back.
class _FakePassword extends ChangePasswordNotifier {
  _FakePassword({this.result = const Success<void>(null)});

  final ApiResult<void> result;
  final requests = <PasswordUpdateRequest>[];
  Completer<void>? gate;

  @override
  Future<ApiResult<void>> submit(PasswordUpdateRequest request) async {
    requests.add(request);
    await gate?.future;
    return result;
  }
}

const _pixelRatio = bool.fromEnvironment('PROFILE_PREVIEW') ? 2.0 : 1.0;

/// Sizes the view, with a keyboard [keyboard] dp tall when non-zero.
void _setViewport(
  WidgetTester tester,
  double width,
  double height, {
  double keyboard = 0,
}) {
  tester.view.physicalSize = Size(width * _pixelRatio, height * _pixelRatio);
  tester.view.devicePixelRatio = _pixelRatio;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard * _pixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
}

/// Pumps the form at `/profile/[path]`, pushed over a stub Profile page as the
/// app opens it.
Future<void> _pumpForm(
  WidgetTester tester,
  String path, {
  _FakeContact? contact,
  _FakePassword? password,
  double width = 393,
  double height = 852,
  double textScale = 1,
  double keyboard = 0,
}) async {
  _setViewport(tester, width, height, keyboard: keyboard);
  final router = GoRouter(
    initialLocation: RoutePaths.profile,
    routes: [
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (_, _) => const Scaffold(body: Text('Halaman Profil')),
        routes: [
          GoRoute(
            path: RoutePaths.profileContact,
            name: RouteNames.profileContact,
            builder: (_, _) => const ContactEditScreen(),
          ),
          GoRoute(
            path: RoutePaths.profilePassword,
            name: RouteNames.profilePassword,
            builder: (_, _) => const ChangePasswordScreen(),
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
        authProvider.overrideWith(_FakeAuth.new),
        profileEditProvider.overrideWith(() => contact ?? _FakeContact()),
        changePasswordProvider.overrideWith(() => password ?? _FakePassword()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        // The forms keep their light design whatever the app theme.
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
  unawaited(router.push('${RoutePaths.profile}/$path'));
  await tester.pumpAndSettle();
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

/// The text field labelled [label].
Finder _field(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextField));

/// The outlined box of the field labelled [label], without its error line.
Rect _box(WidgetTester tester, String label) {
  final field = tester.getRect(_field(label));
  return Rect.fromLTWH(field.left, field.top, field.width, _boxHeight(tester));
}

/// A single-line field's box: 16dp padding around a 24dp line at the
/// current text scale.
double _boxHeight(WidgetTester tester) =>
    32 +
    MediaQuery.textScalerOf(
          tester.element(find.byType(TextField).first),
        ).scale(16) *
        1.5;

/// Whether the label [label] floats on its field's outline (true) or rests
/// inside it (false); fails if it is in between.
bool _floats(WidgetTester tester, String label) {
  final box = _box(tester, label);
  final text = tester.getRect(find.text(label));
  if ((text.center.dy - box.top).abs() <= 2) return true;
  expect(text.center.dy, moreOrLessEquals(box.center.dy, epsilon: 2));
  return false;
}

/// The colour the label [label] is painted in.
Color? _labelColor(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(find.text(label)).text.style?.color;

InputDecoration _decoration(WidgetTester tester, String label) => tester
    .widget<InputDecorator>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(InputDecorator),
      ),
    )
    .decoration;

/// The page's only filled button, Simpan Perubahan; found by type, as its
/// spinner replaces the label while saving.
Finder get _saveButton => find.byType(FilledButton);

Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(_saveButton);
  await tester.pumpAndSettle();
}

/// The AURA app bar, white rounded fields and navy pill button both forms
/// share.
void _expectAuraForm(WidgetTester tester, String title, List<String> labels) {
  final appBar = tester.widget<AppBar>(find.byType(AppBar));
  expect(appBar.backgroundColor, Colors.transparent);
  expect(appBar.centerTitle, isTrue);
  expect(appBar.foregroundColor, _navy);
  expect(
    find.descendant(of: find.byType(AppBar), matching: find.text(title)),
    findsOneWidget,
  );

  for (final label in labels) {
    final decoration = _decoration(tester, label);
    expect(decoration.labelText, label, reason: 'a floating label');
    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, Colors.white);
    final border = decoration.enabledBorder! as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(14));
    expect(border.borderSide.color, _fieldBorder);
    // Focused in the form theme's navy, as on the Izin and Surat forms.
    expect(
      (decoration.focusedBorder! as OutlineInputBorder).borderSide.color,
      const Color(0xFF194875),
    );
    expect(_box(tester, label).height, 56);
  }

  expect(
    find.descendant(of: _saveButton, matching: find.text('Simpan Perubahan')),
    findsOneWidget,
  );
  final button = tester.widget<FilledButton>(_saveButton);
  expect(button.style!.backgroundColor!.resolve({}), const Color(0xFF194875));
  expect(button.style!.shape!.resolve({}), isA<StadiumBorder>());
  expect(tester.getSize(_saveButton).height, 52);
}

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

  group('Ubah Kontak', () {
    const path = RoutePaths.profileContact;

    testWidgets('keeps its fields and note in the AURA form look', (
      tester,
    ) async {
      await _pumpForm(tester, path);
      _expectAuraForm(tester, 'Ubah Kontak', ['Email', 'Nomor HP']);
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.map((field) => field.maxLength), [255, 30]);
      expect(fields.map((field) => field.decoration!.counterText), ['', '']);

      // The reminder, unchanged, on a soft blue card with an info icon.
      expect(find.text(_note), findsOneWidget);
      final card = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text(_note), matching: find.byType(DecoratedBox))
            .first,
      );
      expect((card.decoration as BoxDecoration).color, const Color(0xFFE8F0FC));
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      await _capturePreview(tester, 'contact_393');
    });

    testWidgets('labels float onto the outline when focused or filled', (
      tester,
    ) async {
      await _pumpForm(tester, path);
      // Prefilled email: floating, muted. Empty phone: resting inside.
      expect(_floats(tester, 'Email'), isTrue);
      expect(_labelColor(tester, 'Email'), _muted);
      expect(_floats(tester, 'Nomor HP'), isFalse);

      await tester.tap(_field('Nomor HP'));
      await tester.pumpAndSettle();
      expect(_floats(tester, 'Nomor HP'), isTrue);
      expect(_labelColor(tester, 'Nomor HP'), _navy);
      // Smaller once floating, and clear of the rounded corner.
      final floating = tester.getRect(find.text('Nomor HP'));
      final box = _box(tester, 'Nomor HP');
      expect(floating.left, greaterThanOrEqualTo(box.left + 14));
      await _capturePreview(tester, 'contact_393_focused');

      // Emptied and left: back inside the field.
      await tester.tap(_field('Email'));
      await tester.pumpAndSettle();
      expect(_floats(tester, 'Nomor HP'), isFalse);
    });

    testWidgets('validates and saves as before', (tester) async {
      final contact = _FakeContact()..gate = Completer<void>();
      await _pumpForm(tester, path, contact: contact);
      await tester.enterText(_field('Email'), 'bukan-email');
      await _tapSave(tester);
      expect(find.text('Format email tidak valid.'), findsOneWidget);
      expect(contact.requests, isEmpty);
      // An error turns the floating label red.
      expect(
        _labelColor(tester, 'Email'),
        ColorScheme.fromSeed(seedColor: const Color(0xFF174B76)).error,
      );

      await tester.enterText(_field('Email'), '  bima@aura.test ');
      await tester.tap(_saveButton);
      await tester.pump();
      expect(contact.requests.single.email, 'bima@aura.test');
      expect(contact.requests.single.phone, isNull);
      // Saving: spinner in the disabled button, fields locked.
      expect(
        find.descendant(
          of: _saveButton,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(_saveButton).onPressed, isNull);
      expect(tester.widget<TextField>(_field('Email')).enabled, isFalse);

      contact.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Kontak berhasil diperbarui.'), findsOneWidget);
      expect(find.text('Halaman Profil'), findsOneWidget);
    });

    testWidgets('maps a 422 onto its field and reports other failures', (
      tester,
    ) async {
      final errors = <String, List<String>>{
        'email': ['Email sudah digunakan.'],
      };
      await _pumpForm(
        tester,
        path,
        contact: _FakeContact(
          result: Failure(
            ValidationException(message: 'Data tidak valid.', errors: errors),
          ),
        ),
      );
      await _tapSave(tester);
      expect(find.text('Email sudah digunakan.'), findsOneWidget);
      await _capturePreview(tester, 'contact_393_error');

      await _pumpForm(
        tester,
        path,
        contact: _FakeContact(
          result: const Failure(
            NetworkException(message: 'Tidak ada koneksi.'),
          ),
        ),
      );
      await _tapSave(tester);
      expect(find.text('Tidak ada koneksi.'), findsOneWidget);
      expect(find.byType(ContactEditScreen), findsOneWidget);
    });
  });

  group('Ganti Password', () {
    const path = RoutePaths.profilePassword;
    const labels = [
      'Password Saat Ini',
      'Password Baru',
      'Konfirmasi Password Baru',
    ];

    testWidgets('keeps its three fields in the AURA form look', (tester) async {
      await _pumpForm(tester, path);
      _expectAuraForm(tester, 'Ganti Password', labels);
      for (final label in labels) {
        expect(_floats(tester, label), isFalse);
        expect(tester.widget<TextField>(_field(label)).obscureText, isTrue);
        expect(_labelColor(tester, label), _muted);
      }
      expect(find.byTooltip('Tampilkan'), findsNWidgets(3));
      await _capturePreview(tester, 'password_393');
    });

    testWidgets('visibility toggles keep working in AURA colours', (
      tester,
    ) async {
      await _pumpForm(tester, path);
      Color? toggleColor(int index) => tester
          .renderObject<RenderParagraph>(
            find
                .descendant(
                  of: find.byTooltip(index == 0 ? 'Sembunyikan' : 'Tampilkan'),
                  matching: find.byType(RichText),
                )
                .first,
          )
          .text
          .style
          ?.color;
      expect(toggleColor(1), _muted);

      await tester.enterText(_field(labels[0]), 'rahasia');
      await tester.tap(find.byTooltip('Tampilkan').first);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(_field(labels[0])).obscureText, isFalse);
      expect(find.byTooltip('Sembunyikan'), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      // Navy on the focused field.
      expect(toggleColor(0), _navy);
      expect(_floats(tester, labels[0]), isTrue);
      await _capturePreview(tester, 'password_393_focused');

      await tester.tap(find.byTooltip('Sembunyikan'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(_field(labels[0])).obscureText, isTrue);
    });

    testWidgets('validates and saves as before', (tester) async {
      final password = _FakePassword()..gate = Completer<void>();
      await _pumpForm(tester, path, password: password);
      await _tapSave(tester);
      for (final message in [
        'Password saat ini wajib diisi.',
        'Password baru wajib diisi.',
        'Konfirmasi password wajib diisi.',
      ]) {
        expect(find.text(message), findsOneWidget);
      }
      await _capturePreview(tester, 'password_393_errors');

      await tester.enterText(_field(labels[0]), 'lama123');
      await tester.enterText(_field(labels[1]), 'ab');
      await tester.enterText(_field(labels[2]), 'abc');
      await _tapSave(tester);
      expect(find.text('Password baru minimal 3 karakter.'), findsOneWidget);
      expect(find.text('Konfirmasi password tidak cocok.'), findsOneWidget);
      expect(password.requests, isEmpty);

      await tester.enterText(_field(labels[1]), 'baru123');
      await tester.enterText(_field(labels[2]), 'baru123');
      await tester.tap(_saveButton);
      await tester.pump();
      final request = password.requests.single;
      expect(
        (
          request.currentPassword,
          request.password,
          request.passwordConfirmation,
        ),
        ('lama123', 'baru123', 'baru123'),
      );
      expect(
        find.descendant(
          of: _saveButton,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(tester.widget<TextField>(_field(labels[0])).enabled, isFalse);

      password.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Kata sandi berhasil diperbarui.'), findsOneWidget);
      expect(find.text('Halaman Profil'), findsOneWidget);
    });

    testWidgets('maps a wrong current password onto its field', (tester) async {
      final errors = <String, List<String>>{
        'current_password': ['Password saat ini salah.'],
      };
      await _pumpForm(
        tester,
        path,
        password: _FakePassword(
          result: Failure(
            ValidationException(message: 'Data tidak valid.', errors: errors),
          ),
        ),
      );
      await tester.enterText(_field(labels[0]), 'salah');
      await tester.enterText(_field(labels[1]), 'baru123');
      await tester.enterText(_field(labels[2]), 'baru123');
      await _tapSave(tester);
      expect(find.text('Password saat ini salah.'), findsOneWidget);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });
  });

  // A small phone with the keyboard up leaves little room: the save button
  // stays above the keyboard and the focused field scrolls into view.
  for (final (path, label) in [
    (RoutePaths.profileContact, 'Nomor HP'),
    (RoutePaths.profilePassword, 'Konfirmasi Password Baru'),
  ]) {
    testWidgets('$path keeps the button and focused field above the keyboard', (
      tester,
    ) async {
      const height = 568.0;
      const keyboard = 260.0;
      await _pumpForm(
        tester,
        path,
        width: 320,
        height: height,
        textScale: 1.3,
        keyboard: keyboard,
      );
      await tester.showKeyboard(_field(label));
      await tester.pumpAndSettle();
      final button = tester.getRect(_saveButton);
      expect(button.bottom, lessThanOrEqualTo(height - keyboard));
      final field = _box(tester, label);
      expect(
        field.top,
        greaterThanOrEqualTo(tester.getRect(find.byType(AppBar)).bottom),
      );
      expect(field.bottom, lessThanOrEqualTo(button.top));
      expect(_floats(tester, label), isTrue);
      expect(tester.takeException(), isNull);
      await _capturePreview(tester, '${path}_keyboard');
    });
  }

  for (final viewport in [
    (width: 320.0, height: 568.0),
    (width: 360.0, height: 640.0),
    (width: 393.0, height: 852.0),
    (width: 430.0, height: 932.0),
    (width: 768.0, height: 1024.0),
  ]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      for (final path in [
        RoutePaths.profileContact,
        RoutePaths.profilePassword,
      ]) {
        testWidgets(
          '$path fits ${viewport.width}x${viewport.height} at scale $scale',
          (tester) async {
            await _pumpForm(
              tester,
              path,
              width: viewport.width,
              height: viewport.height,
              textScale: scale,
            );
            // Errors on screen: a bad email, or every password missing.
            if (path == RoutePaths.profileContact) {
              await tester.enterText(_field('Email'), 'bukan-email');
            }
            await _tapSave(tester);
            expect(tester.takeException(), isNull);
            await _capturePreview(
              tester,
              '${path}_${viewport.width.round()}x${viewport.height.round()}'
              '@$scale',
            );

            // Fields and button inside the gutters, at most Home's width.
            for (final target in [find.byType(TextField).first, _saveButton]) {
              final rect = tester.getRect(target);
              expect(rect.left, greaterThanOrEqualTo(16));
              expect(rect.right, lessThanOrEqualTo(viewport.width - 16));
              expect(rect.width, lessThanOrEqualTo(680));
            }
            // The button stays on screen, below the scrolling fields.
            expect(
              tester.getRect(_saveButton).bottom,
              lessThanOrEqualTo(viewport.height),
            );
            // Errors are shown in full.
            for (final error
                in find
                    .textContaining('wajib diisi')
                    .evaluate()
                    .followedBy(
                      find.text('Format email tidak valid.').evaluate(),
                    )) {
              expect(
                (error.renderObject! as RenderParagraph).didExceedMaxLines,
                isFalse,
              );
            }
          },
        );
      }
    }
  }
}
