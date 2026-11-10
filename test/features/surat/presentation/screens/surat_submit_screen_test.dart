import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aura_mobile/app/router/routes.dart';
import 'package:aura_mobile/core/error/app_exception.dart';
import 'package:aura_mobile/core/network/api_result.dart';
import 'package:aura_mobile/features/surat/data/models/surat_submission.dart';
import 'package:aura_mobile/features/surat/presentation/providers/surat_submit_notifier.dart';
import 'package:aura_mobile/features/surat/presentation/screens/surat_submit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _title = 'Surat Izin Pulang Sebelum Waktunya';
const _intro =
    'Identitas Anda diambil otomatis dari akun. Lengkapi rincian berikut, '
    'lalu surat akan dibuat untuk dicetak atau disimpan.';
const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String _fullDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

String _shortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1].substring(0, 3)} ${date.year}';

String _hhmm(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

/// The longest month name, so the full date is as wide as it gets.
DateTime _september28() => DateTime(_today().year, 9, 28);

/// Records generate calls instead of calling the repository. [gate] holds
/// the response back so the in-flight state can be inspected.
class _FakeSuratNotifier extends SuratSubmitNotifier {
  _FakeSuratNotifier({this.result = const Success<void>(null)});

  final ApiResult<void> result;
  final submissions = <SuratSubmission>[];
  Completer<void>? gate;

  @override
  Future<ApiResult<void>> generate(SuratSubmission submission) async {
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

/// Pumps the form at `/leave/surat-pulang-cepat`, above a stub landing page.
Future<_FakeSuratNotifier> _pumpForm(
  WidgetTester tester, {
  double width = 393,
  double height = 852,
  double textScale = 1,
  _FakeSuratNotifier? notifier,
}) async {
  _setViewport(tester, width, height);
  final fake = notifier ?? _FakeSuratNotifier();
  final router = GoRouter(
    initialLocation: '${RoutePaths.leave}/${RoutePaths.leaveSurat}',
    routes: [
      GoRoute(
        path: RoutePaths.leave,
        name: RouteNames.leave,
        builder: (_, _) => const Scaffold(body: Text('Landing')),
        routes: [
          GoRoute(
            path: RoutePaths.leaveSurat,
            name: RouteNames.leaveSurat,
            builder: (_, _) => const SuratSubmitScreen(),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [suratSubmitProvider.overrideWith(() => fake)],
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
            key: const ValueKey('surat-preview'),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

/// Writes `build/leave-preview/<name>.png` when run with LEAVE_PREVIEW, next
/// to the leave form's captures for side-by-side comparison.
Future<void> _capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('LEAVE_PREVIEW')) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('surat-preview')),
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

/// Tappable surface of a picker, found through its badge icon.
Finder _pickerBox(IconData icon) =>
    find.ancestor(of: find.byIcon(icon), matching: find.byType(InkWell)).first;
final _dateBox = _pickerBox(Icons.calendar_today_outlined);
final _timeBox = _pickerBox(Icons.schedule_outlined);

final _primary = ColorScheme.fromSeed(
  seedColor: const Color(0xFF174B76),
).primary;

Future<void> _openPicker(WidgetTester tester, Finder box) async {
  await tester.ensureVisible(box);
  await tester.pumpAndSettle();
  await tester.tap(box);
  await tester.pumpAndSettle();
}

/// Accepts the date picker's initial date: today, or the picked date.
Future<void> _pickInitialDate(WidgetTester tester) async {
  await _openPicker(tester, _dateBox);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// Types [date] into the date picker's input mode and accepts it.
Future<void> _enterDate(WidgetTester tester, DateTime date) async {
  await _openPicker(tester, _dateBox);
  await tester.tap(find.byIcon(Icons.edit_outlined));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.byType(TextField),
    ),
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.day.toString().padLeft(2, '0')}/${date.year}',
  );
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// Accepts the time picker's initial time and returns it as `HH:mm`.
Future<String> _pickInitialTime(WidgetTester tester) async {
  await _openPicker(tester, _timeBox);
  final initial = tester
      .widget<TimePickerDialog>(find.byType(TimePickerDialog))
      .initialTime;
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  return _hhmm(initial);
}

Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Buat & Cetak Surat'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Buat & Cetak Surat'));
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

  testWidgets('keeps the title and intro under the AURA app bar', (
    tester,
  ) async {
    await _pumpForm(tester);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Surat Pulang Cepat'),
      ),
      findsOneWidget,
    );

    final title = find.text(_title);
    final intro = find.text(_intro);
    expect(tester.widget<Text>(title).style!.color, const Color(0xFF123F69));
    expect(tester.widget<Text>(intro).style!.color, const Color(0xFF58636A));
    expect(tester.getRect(intro).top, greaterThan(tester.getRect(title).top));
    expect(
      tester.getRect(find.text('Tanggal Pulang *')).top,
      greaterThan(tester.getRect(intro).bottom),
    );

    // One plain scroll view, as on the leave form, rather than a lazy list.
    final screen = find.byType(SuratSubmitScreen);
    expect(
      find.descendant(of: screen, matching: find.byType(ListView)),
      findsNothing,
    );
    expect(
      find.descendant(of: screen, matching: find.byType(SingleChildScrollView)),
      findsOneWidget,
    );
  });

  testWidgets('labels every required field above its input', (tester) async {
    await _pumpForm(tester);
    final error = ColorScheme.fromSeed(
      seedColor: const Color(0xFF174B76),
    ).error;
    for (final label in [
      'Tanggal Pulang *',
      'Jam Meninggalkan Kantor *',
      'Alasan *',
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(InputDecorator),
          matching: find.text(label),
        ),
        findsNothing,
      );
      final span = tester.widget<Text>(find.text(label)).textSpan! as TextSpan;
      final marker = span.children!.single as TextSpan;
      expect(marker.text, ' *');
      expect(marker.style!.color, error);
    }
    expect(find.text('Pilih tanggal'), findsOneWidget);
    expect(find.text('Pilih jam'), findsOneWidget);
    expect(find.text('Jelaskan alasan Anda pulang lebih awal'), findsOneWidget);
  });

  testWidgets('outside labels still name the inputs for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpForm(tester);
      final reason = tester.getSemantics(find.byType(TextField));
      expect(reason, isSemantics(isTextField: true));
      expect(reason.label, contains('Alasan'));
      for (final (label, placeholder) in [
        ('Tanggal Pulang', 'Pilih tanggal'),
        ('Jam Meninggalkan Kantor', 'Pilih jam'),
      ]) {
        final node = tester.getSemantics(find.text('$label *'));
        expect(node, isSemantics(isButton: true, hasTapAction: true));
        expect(node.label, contains(label));
        expect(node.label, contains(placeholder));
      }
    } finally {
      handle.dispose();
    }
  });

  testWidgets('uses the leave form fields: badges, heights and widths', (
    tester,
  ) async {
    await _pumpForm(tester);
    for (final (icon, box) in [
      (Icons.calendar_today_outlined, _dateBox),
      (Icons.schedule_outlined, _timeBox),
    ]) {
      final iconFinder = find.byIcon(icon);
      expect(iconFinder, findsOneWidget);
      expect(tester.widget<Icon>(iconFinder).color, const Color(0xFF0B2559));
      expect(tester.widget<Icon>(iconFinder).size, 22);
      final badge = find
          .ancestor(of: iconFinder, matching: find.byType(DecoratedBox))
          .first;
      expect(
        (tester.widget<DecoratedBox>(badge).decoration as BoxDecoration).color,
        const Color(0xFFE3EEFF),
      );
      // A 40dp badge 8dp from the 56dp field's top, bottom and end, with the
      // icon centred on it.
      final badgeRect = tester.getRect(badge);
      final field = tester.getRect(box);
      expect(field.height, 56);
      expect(badgeRect.size, const Size.square(40));
      expect(badgeRect.top - field.top, 8);
      expect(field.bottom - badgeRect.bottom, 8);
      expect(field.right - badgeRect.right, 8);
      expect(tester.getCenter(iconFinder), badgeRect.center);
    }

    // Alasan is the leave form's 128dp textarea; M3 leaves a 4dp gap between
    // its outline and the counter.
    final reason = tester.getRect(find.byType(TextField));
    expect(tester.getRect(find.text('0/1000')).top - 4 - reason.top, 128);

    // The time stacks under the date, both as wide as Alasan.
    final date = tester.getRect(_dateBox);
    final time = tester.getRect(_timeBox);
    expect(time.top, greaterThan(date.bottom));
    for (final box in [date, time]) {
      expect(box.left, reason.left);
      expect(box.right, reason.right);
    }
  });

  testWidgets('puts the navy submit button and printer icon at the end', (
    tester,
  ) async {
    await _pumpForm(tester);
    final button = find.byType(FilledButton);
    expect(
      find.descendant(of: button, matching: find.byIcon(Icons.print_outlined)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: button, matching: find.text('Buat & Cetak Surat')),
      findsOneWidget,
    );
    final style = tester.widget<FilledButton>(button).style!;
    expect(style.backgroundColor!.resolve({}), const Color(0xFF194875));
    expect(style.foregroundColor!.resolve({}), Colors.white);
    expect(style.shape!.resolve({}), isA<StadiumBorder>());
    expect(tester.getSize(button).height, 52);
    expect(
      tester.getRect(button).top,
      greaterThan(tester.getRect(find.text('0/1000')).bottom),
    );
  });

  testWidgets('keeps the Alasan limit and its counter', (tester) async {
    await _pumpForm(tester);
    final field = find.byType(TextField);
    final widget = tester.widget<TextField>(field);
    expect((widget.maxLength, widget.maxLines), (1000, 4));
    expect(find.text('0/1000'), findsOneWidget);

    await tester.enterText(field, '1' * 1010);
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, hasLength(1000));
    expect(find.text('1000/1000'), findsOneWidget);
  });

  testWidgets('empty submission shows the existing errors', (tester) async {
    final notifier = await _pumpForm(tester);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.text('Tanggal pulang wajib diisi.'), findsOneWidget);
    expect(find.text('Jam pulang wajib diisi.'), findsOneWidget);
    expect(find.text('Alasan wajib diisi.'), findsOneWidget);

    // Picking clears each picker's error; a blank Alasan alone still blocks.
    await _pickInitialDate(tester);
    await _pickInitialTime(tester);
    expect(find.text('Tanggal pulang wajib diisi.'), findsNothing);
    expect(find.text('Jam pulang wajib diisi.'), findsNothing);
    await tester.enterText(find.byType(TextFormField), '   ');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.text('Alasan wajib diisi.'), findsOneWidget);
    expect(notifier.submissions, isEmpty);
  });

  testWidgets('date picker keeps its limits in AURA colours', (tester) async {
    await _pumpForm(tester);
    final today = _today();
    await _openPicker(tester, _dateBox);
    final dialog = find.byType(DatePickerDialog);
    final picker = tester.widget<DatePickerDialog>(dialog);
    expect(picker.firstDate, DateTime(today.year - 1));
    expect(picker.lastDate, DateTime(today.year + 2));
    expect(picker.initialDate, today);
    expect(Theme.of(tester.element(dialog)).colorScheme.primary, _primary);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // In full through the shared Indonesian formatter.
    expect(find.text(_fullDate(today)), findsOneWidget);
    expect(find.text('Pilih tanggal'), findsNothing);
  });

  testWidgets('time picker starts now in AURA colours, shows HH:mm', (
    tester,
  ) async {
    await _pumpForm(tester);
    final before = TimeOfDay.now();
    await _openPicker(tester, _timeBox);
    final dialog = find.byType(TimePickerDialog);
    final initial = tester.widget<TimePickerDialog>(dialog).initialTime;
    expect(initial == before || initial == TimeOfDay.now(), isTrue);
    expect(Theme.of(tester.element(dialog)).colorScheme.primary, _primary);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(_hhmm(initial)), findsOneWidget);
    expect(find.text('Pilih jam'), findsNothing);
  });

  // At 320dp with 2x text "28 September 2026" does not fit on one line, with
  // Roboto or the 1em-wide test font.
  testWidgets('shortens the month only when the full date does not fit', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpForm(tester, width: 320, height: 568, textScale: 2);
      final date = _september28();
      await _enterDate(tester, date);
      expect(find.text(_shortDate(date)), findsOneWidget);
      expect(find.text(_fullDate(date)), findsNothing);
      expect(tester.takeException(), isNull);
      // Screen readers still hear the full date.
      expect(
        tester.getSemantics(find.text('Tanggal Pulang *')).label,
        contains(_fullDate(date)),
      );
    } finally {
      handle.dispose();
    }
  });

  // At 320dp with 2x text the Alasan error shares its line with the counter,
  // and "Buat & Cetak Surat" wraps beside its icon, with Roboto or the
  // 1em-wide test font.
  testWidgets('wraps errors and the button label readably at 320dp, 2x', (
    tester,
  ) async {
    await _pumpForm(tester, width: 320, height: 568, textScale: 2);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    final error = find.text('Alasan wajib diisi.');
    await tester.ensureVisible(error);
    await tester.pumpAndSettle();
    expect(
      tester.renderObject<RenderParagraph>(error).didExceedMaxLines,
      isFalse,
    );
    expect(
      tester.getRect(error).right,
      lessThanOrEqualTo(tester.getRect(find.text('0/1000')).left),
    );

    final label = find.text('Buat & Cetak Surat');
    await tester.ensureVisible(label);
    await tester.pumpAndSettle();
    await _capturePreview(tester, 'surat_320x568@2.0_button');
    expect(tester.widget<Text>(label).textAlign, TextAlign.center);
    // Two lines, and the pill grows past its 52dp minimum around both.
    final text = tester.getRect(label);
    final button = tester.getRect(find.byType(FilledButton));
    final icon = tester.getRect(find.byIcon(Icons.print_outlined));
    expect(text.height, greaterThan(52));
    expect(text.top, greaterThanOrEqualTo(button.top));
    expect(text.bottom, lessThanOrEqualTo(button.bottom));
    // The icon stays beside the wrapped lines, centred on them.
    expect(icon.right, lessThan(text.left));
    expect(icon.center.dy, moreOrLessEquals(text.center.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('submits the same payload, shows progress, stays on the form', (
    tester,
  ) async {
    final notifier = _FakeSuratNotifier()..gate = Completer<void>();
    await _pumpForm(tester, notifier: notifier);
    final date = _september28();
    await _enterDate(tester, date);
    expect(find.text(_fullDate(date)), findsOneWidget);
    final time = await _pickInitialTime(tester);
    await tester.enterText(
      find.byType(TextFormField),
      '  Ada keperluan keluarga  ',
    );
    await _tapSubmit(tester);
    await tester.pump();

    final submission = notifier.submissions.single;
    expect(submission.earlyLeaveDate, date);
    expect(submission.leaveTime, time);
    expect(submission.reason, 'Ada keperluan keluarga');

    // In flight: the spinner takes the icon's place beside "Menyiapkan…",
    // and the button and inputs are disabled.
    final button = find.byType(FilledButton);
    expect(find.text('Menyiapkan surat…'), findsOneWidget);
    expect(
      find.descendant(of: button, matching: find.text('Menyiapkan…')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: button,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.print_outlined), findsNothing);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    for (final box in [_dateBox, _timeBox]) {
      expect(tester.widget<InkWell>(box).onTap, isNull);
    }

    notifier.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Surat siap dicetak atau disimpan.'), findsOneWidget);
    expect(find.text('Buat & Cetak Surat'), findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    expect(find.byType(SuratSubmitScreen), findsOneWidget);
  });

  testWidgets('maps a 422 back onto its fields', (tester) async {
    // Const, so picking again also proves the form never edits the
    // exception's own map.
    final notifier = _FakeSuratNotifier(
      result: const Failure(
        ValidationException(
          message: 'Data tidak valid.',
          errors: {
            'early_leave_date': ['Tanggal pulang tidak valid.'],
            'leave_time': ['Format jam tidak valid.'],
          },
        ),
      ),
    );
    await _pumpForm(tester, notifier: notifier);
    await _pickInitialDate(tester);
    await _pickInitialTime(tester);
    await tester.enterText(find.byType(TextFormField), 'Kontrol ke dokter');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(notifier.submissions, hasLength(1));
    expect(find.text('Tanggal pulang tidak valid.'), findsOneWidget);
    expect(find.text('Format jam tidak valid.'), findsOneWidget);
    expect(find.text('Data tidak valid.'), findsOneWidget);

    // Picking again clears only that field's message.
    await _pickInitialTime(tester);
    expect(find.text('Format jam tidak valid.'), findsNothing);
    expect(find.text('Tanggal pulang tidak valid.'), findsOneWidget);
  });

  // The error mapper gives a 422 without an "errors" map a const empty map;
  // changing the date or time afterwards used to throw while clearing its
  // entry.
  testWidgets('keeps taking input after a 422 without field errors', (
    tester,
  ) async {
    final notifier = _FakeSuratNotifier(
      result: const Failure(ValidationException(message: 'Data tidak valid.')),
    );
    await _pumpForm(tester, notifier: notifier);
    await _pickInitialDate(tester);
    await _pickInitialTime(tester);
    await tester.enterText(find.byType(TextFormField), 'Kontrol ke dokter');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(notifier.submissions, hasLength(1));
    expect(find.text('Data tidak valid.'), findsOneWidget);

    final date = _september28();
    await _enterDate(tester, date);
    expect(find.text(_fullDate(date)), findsOneWidget);
    final time = await _pickInitialTime(tester);
    expect(find.text(time), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField),
      'Kontrol ke dokter gigi',
    );
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(notifier.submissions, hasLength(2));
    expect(notifier.submissions.last.earlyLeaveDate, date);
    expect(notifier.submissions.last.leaveTime, time);
    expect(notifier.submissions.last.reason, 'Kontrol ke dokter gigi');
    expect(tester.takeException(), isNull);
  });

  testWidgets('captures previews of the form, pickers and states', (
    tester,
  ) async {
    final notifier = _FakeSuratNotifier()..gate = Completer<void>();
    await _pumpForm(tester, notifier: notifier);
    await _capturePreview(tester, 'surat_393');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    await _capturePreview(tester, 'surat_393_errors');

    await _openPicker(tester, _dateBox);
    await _capturePreview(tester, 'surat_393_date_picker');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await _openPicker(tester, _timeBox);
    await _capturePreview(tester, 'surat_393_time_picker');
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    await _capturePreview(tester, 'surat_393_time_input');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'Kontrol ke dokter gigi.',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await _capturePreview(tester, 'surat_393_filled');

    await _tapSubmit(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _capturePreview(tester, 'surat_393_busy');
    notifier.gate!.complete();
    await tester.pumpAndSettle();
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
              'surat_${viewport.width.round()}x${viewport.height.round()}'
              '@$scale';
          await _capturePreview(tester, name);

          // Nothing filled in: every error on screen at once.
          await _tapSubmit(tester);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          // Shown in full, never cut off beside its counter.
          expect(
            tester
                .renderObject<RenderParagraph>(
                  find.text('Alasan wajib diisi.', skipOffstage: false),
                )
                .didExceedMaxLines,
            isFalse,
          );
          await _capturePreview(tester, '${name}_errors');

          // Everything stays inside the page gutters.
          for (final control in [
            find.text(_title),
            find.text(_intro),
            _dateBox,
            _timeBox,
            find.byType(TextField),
            find.byType(FilledButton),
          ]) {
            final rect = tester.getRect(control);
            expect(rect.left, greaterThanOrEqualTo(16));
            expect(rect.right, lessThanOrEqualTo(viewport.width - 16));
          }

          // The time stacks under the date, both as wide as Alasan.
          final reason = tester.getRect(find.byType(TextField));
          final date = tester.getRect(_dateBox);
          final time = tester.getRect(_timeBox);
          expect(time.top, greaterThan(date.bottom));
          for (final box in [date, time]) {
            expect(box.left, reason.left);
            expect(box.right, reason.right);
          }

          // A picked date, in full or shortened, and time never overflow.
          await _pickInitialDate(tester);
          await _pickInitialTime(tester);
          expect(find.text('Pilih tanggal'), findsNothing);
          expect(find.text('Pilih jam'), findsNothing);
          expect(tester.takeException(), isNull);
          await _capturePreview(tester, '${name}_filled');
        },
      );
    }
  }
}
