import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/indo_date.dart';

/// Look shared by AURA's leave pages, so they read as one design: the request
/// forms (Ajukan Izin / Sakit, Surat Pulang Cepat) and, through
/// [AuraPageScaffold], the request lists (Menunggu Persetujuan, Riwayat
/// Pengajuan). Only what several pages use lives here; controls specific to
/// one page stay with it.
///
/// Heading, body and page tokens match the leave landing page and the
/// attendance dashboard; field and accent colours follow the approved form
/// reference.
abstract final class AuraForm {
  static const heading = Color(0xFF123F69);
  static const bodyMuted = Color(0xFF58636A);
  static const navy = Color(0xFF194875);
  static const fieldBorder = Color(0xFFD5DEE8);

  /// Horizontal page padding for [screenWidth]: Home's gutter, widened to
  /// centre the content at Home's max width on tablets.
  static double pageInset(double screenWidth) =>
      math.max(_gutter(screenWidth), (screenWidth - _maxContentWidth) / 2);

  static const sectionGap = 20.0;
  static const labelGap = 8.0;

  /// Below a field's character counter, whose own line (4dp gap plus 16dp
  /// text) already separates it from the box.
  static const counterGap = 8.0;

  /// Between two stacked pickers that read as one pair.
  static const pairGap = 16.0;

  // 16sp input text on a 24dp line, so single-line fields share one height.
  static const inputStyle = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Light AURA palette with white, softly outlined inputs, for the whole
  /// form and, through [pickerBuilder], its date and time pickers.
  static final theme = _buildTheme();

  /// `builder` for `showDatePicker` / `showTimePicker`: AURA colours only,
  /// the picker's limits and behaviour stay the caller's.
  static Widget pickerBuilder(BuildContext context, Widget? child) =>
      Theme(data: theme, child: child!);

  static ThemeData _buildTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF174B76),
      brightness: Brightness.light,
    );
    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: color, width: width),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F8F8),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white,
        hintStyle: inputStyle.copyWith(color: _hint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _fieldInset - 4,
          vertical: _fieldPadding,
        ),
        border: outline(fieldBorder),
        enabledBorder: outline(fieldBorder),
        disabledBorder: outline(_fieldBorderDisabled),
        focusedBorder: outline(navy, 1.5),
        errorBorder: outline(scheme.error),
        focusedErrorBorder: outline(scheme.error, 1.5),
        counterStyle: const TextStyle(color: bodyMuted, fontSize: 12),
        // Wrap long errors, as the pickers' AuraFieldError does, instead of
        // cutting them off beside a counter on narrow screens or large text.
        // Ten lines fits every message even at the largest text sizes;
        // one-line errors render as before.
        errorMaxLines: 10,
      ),
    );
  }

  /// Size of [text] rendered in [style] at the current text scale, wrapped at
  /// [maxWidth] — what a `Text` with the same style renders here.
  static Size textSize(
    BuildContext context,
    String text,
    TextStyle style, {
    double maxWidth = double.infinity,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    try {
      return painter.size;
    } finally {
      painter.dispose();
    }
  }
}

const _hint = Color(0xFF8B959D);
const _fieldBorderDisabled = Color(0xFFE4E9EF);
const _badgeFill = Color(0xFFE3EEFF);
const _badgeIcon = Color(0xFF0B2559);

const _fieldRadius = 14.0;

/// Where text starts inside every input: M3 adds a 4dp gap to the text
/// fields' content padding, so the pickers and error lines use 16 too.
const _fieldInset = 16.0;

/// Vertical padding inside every input. With the 24dp line below it gives
/// 56dp per single line, 128 for four lines and 80 for two.
const _fieldPadding = 16.0;

// Zero letter spacing overrides the inherited M3 body tracking, as on Home.
const _labelStyle = TextStyle(
  color: AuraForm.heading,
  fontSize: 14,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
);

/// Page gutter and content width, matching Home and the leave landing page.
double _gutter(double screenWidth) => screenWidth < 360 ? 16 : 18;
const _maxContentWidth = 680.0;

/// A picked date in full through the shared formatter, e.g. "28 September
/// 2026".
String _fullDate(DateTime date) => formatIndoDate(
  '${date.year.toString().padLeft(4, '0')}-'
  '${date.month.toString().padLeft(2, '0')}-'
  '${date.day.toString().padLeft(2, '0')}',
);

/// The same date with a three-letter month, e.g. "28 Sep 2026".
String _shortDate(DateTime date) =>
    '${date.day} ${indoMonthName(date.month).substring(0, 3)} ${date.year}';

/// An AURA page: the AURA theme and light gradient under a transparent app
/// bar titled [title], with [body] below it.
class AuraPageScaffold extends StatelessWidget {
  const AuraPageScaffold({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuraForm.theme,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE5EFFB), Color(0xFFF5F8F8)],
            stops: [0, 0.7],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            foregroundColor: AuraForm.heading,
            titleTextStyle: const TextStyle(
              color: AuraForm.heading,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
          ),
          body: body,
        ),
      ),
    );
  }
}

/// An AURA form page: [children] in one scrolling column inside the page
/// gutters of an [AuraPageScaffold], centred at Home's max width on tablets.
class AuraFormPage extends StatelessWidget {
  const AuraFormPage({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final horizontal = AuraForm.pageInset(MediaQuery.sizeOf(context).width);

    return AuraPageScaffold(
      title: title,
      body: SafeArea(
        top: false,
        child: Form(
          key: formKey,
          // A plain scroll view, not a lazy ListView: the list disposed
          // fields scrolled far out of view, so Form.validate() skipped
          // their validators and an empty Alasan could be submitted.
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// A field's title above its input. Required fields add a red "*";
/// optional fields add nothing.
class AuraFieldLabel extends StatelessWidget {
  const AuraFieldLabel(this.text, {super.key, this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      style: _labelStyle,
    );
  }
}

/// A text input under its label. The label sits outside the outline, so the
/// two are merged for screen readers, which read it as the field's name.
class AuraLabeledField extends StatelessWidget {
  const AuraLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuraFieldLabel(label, isRequired: isRequired),
          const SizedBox(height: AuraForm.labelGap),
          child,
        ],
      ),
    );
  }
}

/// Full-width, tappable picker input styled like the text fields: its label
/// above, the picked [value] (or [placeholder]) and [icon] on a light-blue
/// badge inside the outline.
class AuraPickerField extends StatelessWidget {
  const AuraPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.errorText,
    required this.enabled,
    required this.onTap,
    this.compactValue,
    this.isRequired = false,
  });

  /// A date picker showing [date] in full through the shared formatter, or
  /// with a three-letter month ("28 Sep 2026") when the full date does not
  /// fit. Display only: callers submit the picked [DateTime] itself.
  AuraPickerField.date({
    super.key,
    required this.label,
    required DateTime? date,
    required this.errorText,
    required this.enabled,
    required this.onTap,
    this.isRequired = false,
  }) : value = date == null ? null : _fullDate(date),
       compactValue = date == null ? null : _shortDate(date),
       placeholder = 'Pilih tanggal',
       icon = Icons.calendar_today_outlined;

  final String label;
  final String? value;

  /// Shown instead of [value] when that does not fit on one line; screen
  /// readers still hear [value].
  final String? compactValue;

  final String placeholder;
  final IconData icon;
  final String? errorText;
  final bool enabled;
  final bool isRequired;
  final VoidCallback onTap;

  // The badge matches the leave form's attachment badge.
  static const _iconSize = 22.0;
  static const _iconGap = 8.0;
  static const _badgeSize = 40.0;

  /// The badge sits 8dp from the outline at the top, bottom and end. The text
  /// adds 8dp of its own, so it starts 16dp down as in the text fields: the
  /// field stays 56dp (8 + 40 + 8) and grows with large text exactly as they
  /// do (16 + line + 16).
  static const _badgeInset = 8.0;
  static const _padding = EdgeInsetsDirectional.fromSTEB(
    _fieldInset,
    _badgeInset,
    _badgeInset,
    _badgeInset,
  );
  static const _textPadding = EdgeInsets.symmetric(
    vertical: _fieldPadding - _badgeInset,
  );

  // The text fields' 16sp, 24dp line, so all single-line inputs share one
  // height.
  static const _valueStyle = TextStyle(
    color: AuraForm.heading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );
  static const _placeholderStyle = TextStyle(
    color: _hint,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = errorText != null
        ? scheme.error
        : enabled
        ? AuraForm.fieldBorder
        : _fieldBorderDisabled;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
      side: BorderSide(color: borderColor),
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuraFieldLabel(label, isRequired: isRequired),
          const SizedBox(height: AuraForm.labelGap),
          Semantics(
            button: true,
            child: Material(
              color: Colors.white,
              shape: shape,
              child: InkWell(
                onTap: enabled ? onTap : null,
                customBorder: shape,
                child: Padding(
                  padding: _padding,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: _textPadding,
                          child: value == null
                              ? Text(placeholder, style: _placeholderStyle)
                              : LayoutBuilder(
                                  builder: (context, constraints) =>
                                      _valueText(context, constraints.maxWidth),
                                ),
                        ),
                      ),
                      const SizedBox(width: _iconGap),
                      SizedBox.square(
                        dimension: _badgeSize,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: _badgeFill,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Icon(
                            icon,
                            size: _iconSize,
                            color: enabled ? _badgeIcon : _hint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (errorText != null) AuraFieldError(message: errorText!),
        ],
      ),
    );
  }

  /// [value] when it fits on one line in [maxWidth] at the current text
  /// scale or has no [compactValue], otherwise [compactValue].
  Widget _valueText(BuildContext context, double maxWidth) {
    final full = value!;
    final compact = compactValue;
    final fits =
        compact == null ||
        AuraForm.textSize(context, full, _valueStyle).width <= maxWidth;
    return Text(
      fits ? full : compact,
      style: _valueStyle,
      semanticsLabel: fits ? null : full,
    );
  }
}

/// Error line under a control that is not a text field, aligned with the
/// text fields' own error text.
class AuraFieldError extends StatelessWidget {
  const AuraFieldError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 6, start: _fieldInset),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

/// The forms' navy, pill-shaped submit button, with an optional [icon]
/// before [label]. While [isBusy] it is disabled, stays navy and shows a
/// white spinner: on its own, or in the icon's place before [busyLabel]
/// when one is given. A null [onPressed] disables it without the spinner.
class AuraSubmitButton extends StatelessWidget {
  const AuraSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isBusy = false,
    this.busyLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isBusy;
  final String? busyLabel;

  static final _style = FilledButton.styleFrom(
    backgroundColor: AuraForm.navy,
    foregroundColor: Colors.white,
    // Still navy while busy, so the spinner reads.
    disabledBackgroundColor: AuraForm.navy.withValues(alpha: 0.6),
    disabledForegroundColor: Colors.white,
    elevation: 0,
    shape: const StadiumBorder(),
    minimumSize: const Size.fromHeight(52),
    // The spinner's size, beside the 16sp label.
    iconSize: 20,
  );

  // Styled on the Text rather than through ButtonStyle.textStyle, which
  // replaces the theme's label style (and its font family) instead of
  // merging with it.
  static const _labelTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const _spinner = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  // Centred, so a label that wraps at large text keeps its lines balanced
  // and clear of the pill's rounded ends; one line renders as before.
  static Widget _text(String text) =>
      Text(text, style: _labelTextStyle, textAlign: TextAlign.center);

  @override
  Widget build(BuildContext context) {
    final Widget? leading;
    final Widget content;
    if (!isBusy) {
      leading = icon == null ? null : Icon(icon);
      content = _text(label);
    } else if (busyLabel == null) {
      leading = null;
      content = _spinner;
    } else {
      leading = _spinner;
      content = _text(busyLabel!);
    }
    // Without an icon this is the plain FilledButton with [content] as child.
    return FilledButton.icon(
      onPressed: isBusy ? null : onPressed,
      style: _style,
      icon: leading,
      label: content,
    );
  }
}
