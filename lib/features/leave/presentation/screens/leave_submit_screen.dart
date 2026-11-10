import 'dart:io';
import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../data/models/leave_submission.dart';
import '../providers/leave_submit_notifier.dart';

// Heading, body and page tokens shared with the leave landing page and the
// attendance dashboard; field and accent colours follow the approved form
// reference. Kept local until a shared AURA palette exists.
const _heading = Color(0xFF123F69);
const _bodyMuted = Color(0xFF58636A);
const _navy = Color(0xFF194875);
const _hint = Color(0xFF8B959D);
const _fieldBorder = Color(0xFFD5DEE8);
const _fieldBorderDisabled = Color(0xFFE4E9EF);
const _segmentSelected = Color(0xFFFFEBC4);
const _lavenderFill = Color(0xFFF7F6FE);
const _lavenderDash = Color(0xFFB4AEE8);
const _lavenderTint = Color(0xFFE6E5FB);
const _dateIconFill = Color(0xFFE3EEFF);
const _dateIcon = Color(0xFF0B2559);

const _fieldRadius = 14.0;
const _sectionGap = 20.0;
const _labelGap = 8.0;

/// Below a field's character counter, whose own line (4dp gap plus 16dp
/// text) already separates it from the box.
const _counterGap = 8.0;

/// Between the two stacked date fields, which read as one pair.
const _dateGap = 16.0;

/// Where text starts inside every input: M3 adds a 4dp gap to the text
/// fields' content padding, so the date fields and error lines use 16 too.
const _fieldInset = 16.0;

/// Vertical padding inside every input. With the 24dp line below it gives the
/// original form's boxes: 56dp per single line, 128 for Alasan, 80 for Alamat.
const _fieldPadding = 16.0;

// The original 16sp input text on a 24dp line, so single-line fields share
// one height.
const _inputStyle = TextStyle(fontSize: 16, height: 1.5, letterSpacing: 0);

// Zero letter spacing overrides the inherited M3 body tracking, as on Home.
const _labelStyle = TextStyle(
  color: _heading,
  fontSize: 14,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
);

/// Page gutter and content width, matching Home and the leave landing page.
double _gutter(double screenWidth) => screenWidth < 360 ? 16 : 18;
const _maxContentWidth = 680.0;

/// Same breakpoint as `HomeLayout.largeText` (body text measured at 14sp):
/// side-by-side compositions stack.
bool _largeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14 > 1.35;

/// Size of [text] rendered in [style] at the current text scale, wrapped at
/// [maxWidth] — what a `Text` with the same style renders here.
Size _textSize(
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

/// A picked date as shown in its field, in full through the shared formatter
/// the Surat form uses, e.g. "28 September 2026". Display only: the picked
/// [DateTime] is what gets submitted.
String _fullDate(DateTime date) => formatIndoDate(
  '${date.year.toString().padLeft(4, '0')}-'
  '${date.month.toString().padLeft(2, '0')}-'
  '${date.day.toString().padLeft(2, '0')}',
);

/// The same date with a three-letter month, e.g. "28 Sep 2026", for a field
/// too narrow for [_fullDate].
String _shortDate(DateTime date) =>
    '${date.day} ${indoMonthName(date.month).substring(0, 3)} ${date.year}';

/// Form for submitting a new leave request (izin / sakit).
///
/// Client-side validation mirrors the backend `StoreLeaveRequestRequest` rules
/// for immediate feedback, but the server stays the source of truth: any 422
/// response is mapped back onto the offending fields. Evidence is required for
/// `sakit` and optional for `izin`.
class LeaveSubmitScreen extends ConsumerStatefulWidget {
  const LeaveSubmitScreen({super.key});

  @override
  ConsumerState<LeaveSubmitScreen> createState() => _LeaveSubmitScreenState();
}

class _LeaveSubmitScreenState extends ConsumerState<LeaveSubmitScreen> {
  static const _maxEvidenceBytes = 5 * 1024 * 1024; // 5 MB, matches backend.
  static const _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];

  // Light AURA palette of the leave landing page, plus white, softly outlined
  // inputs. Also applied to the date picker.
  static final _theme = _buildTheme();

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
        hintStyle: _inputStyle.copyWith(color: _hint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _fieldInset - 4,
          vertical: _fieldPadding,
        ),
        border: outline(_fieldBorder),
        enabledBorder: outline(_fieldBorder),
        disabledBorder: outline(_fieldBorderDisabled),
        focusedBorder: outline(_navy, 1.5),
        errorBorder: outline(scheme.error),
        focusedErrorBorder: outline(scheme.error, 1.5),
        counterStyle: const TextStyle(color: _bodyMuted, fontSize: 12),
      ),
    );
  }

  // The existing two-segment control, recoloured: pastel yellow when
  // selected, white otherwise. The selection stays visible while submitting.
  static final _segmentStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? _segmentSelected
          : Colors.white,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? _heading.withValues(alpha: 0.5)
          : _heading,
    ),
    iconColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? _heading.withValues(alpha: 0.5)
          : _heading,
    ),
    side: const WidgetStatePropertyAll(BorderSide(color: _fieldBorder)),
    minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
  );

  // Button labels are styled on their Text rather than through
  // ButtonStyle.textStyle, which replaces the theme's label style (and its
  // font family) instead of merging with it.
  static const _segmentLabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  // Hides the counter of an optional field; its maxLength still applies.
  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  String _type = 'izin';
  DateTime? _startDate;
  DateTime? _endDate;
  XFile? _evidence;
  int _evidenceSize = 0;

  // Client-side errors for the non-text fields (dates, evidence).
  String? _startDateError;
  String? _endDateError;
  String? _evidenceError;

  // Field-keyed messages from a server 422, mirroring Laravel's shape.
  Map<String, List<String>> _serverErrors = {};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Earliest allowed start date: today for sakit, tomorrow (H-1) for izin.
  DateTime _startMinFor(String type) {
    final today = _dateOnly(DateTime.now());
    return type == 'sakit' ? today : today.add(const Duration(days: 1));
  }

  String? _serverError(String field) {
    final messages = _serverErrors[field];
    return (messages == null || messages.isEmpty) ? null : messages.first;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Centres the form at Home's max width on tablets.
    final horizontal = math.max(_gutter(width), (width - _maxContentWidth) / 2);
    final startError = _startDateError ?? _serverError('start_date');
    final endError = _endDateError ?? _serverError('end_date');
    final evidenceError = _evidenceError ?? _serverError('evidence');
    final typeError = _serverError('type');

    return Theme(
      data: _theme,
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
            title: const Text('Ajukan Izin / Sakit'),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            foregroundColor: _heading,
            titleTextStyle: const TextStyle(
              color: _heading,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
          ),
          body: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              // A plain scroll view, not a lazy ListView: the list disposed
              // fields scrolled far out of view, so Form.validate() skipped
              // their validators and an empty Alasan could be submitted.
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('Jenis Pengajuan'),
                    const SizedBox(height: _labelGap),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'izin',
                          label: Text('Izin', style: _segmentLabelStyle),
                        ),
                        ButtonSegment(
                          value: 'sakit',
                          label: Text('Sakit', style: _segmentLabelStyle),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: _isSubmitting
                          ? null
                          : (selection) => _onTypeChanged(selection.first),
                      style: _segmentStyle,
                    ),
                    if (typeError != null) _FieldError(message: typeError),
                    const SizedBox(height: _sectionGap),

                    _LabeledField(
                      label: 'Alasan',
                      isRequired: true,
                      child: TextFormField(
                        controller: _reasonController,
                        enabled: !_isSubmitting,
                        maxLines: 4,
                        maxLength: 1000,
                        textInputAction: TextInputAction.newline,
                        style: _inputStyle,
                        decoration: const InputDecoration(
                          hintText: 'Jelaskan alasan pengajuan Anda',
                        ),
                        onChanged: (_) => _clearServerError('reason'),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Alasan wajib diisi.';
                          if (text.length > 1000) {
                            return 'Alasan maksimal 1000 karakter.';
                          }
                          return _serverError('reason');
                        },
                      ),
                    ),
                    const SizedBox(height: _counterGap),

                    _DateField(
                      label: 'Tanggal Mulai',
                      value: _startDate,
                      errorText: startError,
                      enabled: !_isSubmitting,
                      onTap: () => _pickDate(isStart: true),
                    ),
                    const SizedBox(height: _dateGap),

                    _DateField(
                      label: 'Tanggal Selesai',
                      value: _endDate,
                      errorText: endError,
                      enabled: !_isSubmitting,
                      onTap: () => _pickDate(isStart: false),
                    ),
                    const SizedBox(height: _sectionGap),

                    _EvidenceField(
                      fileName: _evidence?.name,
                      fileSize: _evidenceSize,
                      errorText: evidenceError,
                      isRequired: _type == 'sakit',
                      enabled: !_isSubmitting,
                      onPick: _pickEvidence,
                      onRemove: () => setState(() {
                        _evidence = null;
                        _evidenceSize = 0;
                        _evidenceError = null;
                        _serverErrors.remove('evidence');
                      }),
                      formatBytes: _formatBytes,
                    ),
                    const SizedBox(height: _sectionGap),

                    _LabeledField(
                      label: 'Nomor Kontak',
                      child: TextFormField(
                        controller: _contactController,
                        enabled: !_isSubmitting,
                        maxLength: 30,
                        buildCounter: _noCounter,
                        keyboardType: TextInputType.phone,
                        style: _inputStyle,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nomor kontak',
                        ),
                        onChanged: (_) => _clearServerError('contact_phone'),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.length > 30) {
                            return 'Nomor kontak maksimal 30 karakter.';
                          }
                          return _serverError('contact_phone');
                        },
                      ),
                    ),
                    const SizedBox(height: _sectionGap),

                    _LabeledField(
                      label: 'Alamat Selama Izin',
                      child: TextFormField(
                        controller: _addressController,
                        enabled: !_isSubmitting,
                        maxLines: 2,
                        maxLength: 500,
                        buildCounter: _noCounter,
                        style: _inputStyle,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan alamat selama izin',
                        ),
                        onChanged: (_) => _clearServerError('address'),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.length > 500) {
                            return 'Alamat maksimal 500 karakter.';
                          }
                          return _serverError('address');
                        },
                      ),
                    ),
                    const SizedBox(height: _sectionGap),

                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        // Still navy while sending, so the spinner reads.
                        disabledBackgroundColor: _navy.withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim Pengajuan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTypeChanged(String type) {
    setState(() {
      _type = type;
      _serverErrors.remove('type');
      // A start date picked under the looser sakit rule may be invalid for izin.
      final min = _startMinFor(type);
      if (_startDate != null && _startDate!.isBefore(min)) {
        _startDate = null;
        _endDate = null;
      }
      _startDateError = null;
      _endDateError = null;
      if (type == 'izin') _evidenceError = null;
    });
  }

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors.remove(field));
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final min = _startMinFor(_type);
    final first = isStart ? min : (_startDate ?? min);
    var initial = isStart ? (_startDate ?? min) : (_endDate ?? first);
    if (initial.isBefore(first)) initial = first;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(min.year + 2),
      // AURA colours only; the limits and behaviour above are unchanged.
      builder: (context, child) => Theme(data: _theme, child: child!),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateError = null;
        _serverErrors.remove('start_date');
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
        _endDateError = null;
        _serverErrors.remove('end_date');
      }
    });
  }

  Future<void> _pickEvidence() async {
    const typeGroup = XTypeGroup(
      label: 'Bukti',
      extensions: _allowedExtensions,
      mimeTypes: ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'],
      uniformTypeIdentifiers: [
        'com.adobe.pdf',
        'public.jpeg',
        'public.png',
        'org.webmproject.webp',
      ],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    final size = await file.length();
    if (size > _maxEvidenceBytes) {
      setState(() => _evidenceError = 'Ukuran lampiran maksimal 5 MB.');
      return;
    }
    setState(() {
      _evidence = file;
      _evidenceSize = size;
      _evidenceError = null;
      _serverErrors.remove('evidence');
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _startDateError = _validateStartDate();
      _endDateError = _validateEndDate();
      _evidenceError = _type == 'sakit' && _evidence == null
          ? 'Lampiran bukti wajib untuk pengajuan sakit.'
          : null;
    });

    final manualValid =
        _startDateError == null &&
        _endDateError == null &&
        _evidenceError == null;
    if (!formValid || !manualValid) return;

    final submission = LeaveSubmission(
      type: _type,
      reason: _reasonController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      contactPhone: _emptyToNull(_contactController.text),
      address: _emptyToNull(_addressController.text),
      evidence: _evidence != null ? File(_evidence!.path) : null,
    );

    setState(() => _isSubmitting = true);
    try {
      final result = await ref
          .read(leaveSubmitProvider.notifier)
          .submit(submission);
      if (!mounted) return;

      result.fold(
        onSuccess: (_) {
          _showSnack('Pengajuan berhasil dikirim.');
          context.pop();
        },
        onFailure: (error) {
          if (error is ValidationException) {
            setState(() => _serverErrors = error.errors);
          }
          _showSnack(error.message);
        },
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validateStartDate() {
    if (_startDate == null) return 'Tanggal awal wajib diisi.';
    if (_startDate!.isBefore(_startMinFor(_type))) {
      return _type == 'sakit'
          ? 'Tanggal awal tidak boleh di masa lalu.'
          : 'Pengajuan izin minimal H-1.';
    }
    return null;
  }

  String? _validateEndDate() {
    if (_endDate == null) return 'Tanggal akhir wajib diisi.';
    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      return 'Tanggal akhir harus sama atau setelah tanggal awal.';
    }
    return null;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// A field's title above its input. Required fields add a red "*", the same
/// marker the evidence panel shows for sakit; optional fields add nothing.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.isRequired = false});

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
class _LabeledField extends StatelessWidget {
  const _LabeledField({
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
          _FieldLabel(label, isRequired: isRequired),
          const SizedBox(height: _labelGap),
          child,
        ],
      ),
    );
  }
}

/// Full-width, tappable date input styled like the text fields: its required
/// label above, the picked date (or "Pilih tanggal") and a calendar icon on a
/// light-blue badge inside the outline.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.errorText,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final String? errorText;
  final bool enabled;
  final VoidCallback onTap;

  // The calendar badge matches the evidence panel's attachment badge.
  static const _iconSize = 22.0;
  static const _iconGap = 8.0;
  static const _badgeSize = 40.0;

  /// The calendar badge sits 8dp from the outline at the top, bottom and end.
  /// The text adds 8dp of its own, so it starts 16dp down as in the text
  /// fields: the field stays 56dp (8 + 40 + 8) and grows with large text
  /// exactly as they do (16 + line + 16).
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
    color: _heading,
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
        ? _fieldBorder
        : _fieldBorderDisabled;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
      side: BorderSide(color: borderColor),
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(label, isRequired: true),
          const SizedBox(height: _labelGap),
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
                              ? const Text(
                                  'Pilih tanggal',
                                  style: _placeholderStyle,
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) => _dateText(
                                    context,
                                    value!,
                                    constraints.maxWidth,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: _iconGap),
                      SizedBox.square(
                        dimension: _badgeSize,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: _dateIconFill,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            size: _iconSize,
                            color: enabled ? _dateIcon : _hint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (errorText != null) _FieldError(message: errorText!),
        ],
      ),
    );
  }

  /// [date] in full when it fits on one line in [maxWidth] at the current
  /// text scale, otherwise with a short month. Screen readers always hear the
  /// full date.
  Widget _dateText(BuildContext context, DateTime date, double maxWidth) {
    final full = _fullDate(date);
    final fits = _textSize(context, full, _valueStyle).width <= maxWidth;
    return Text(
      fits ? full : _shortDate(date),
      style: _valueStyle,
      semanticsLabel: fits ? null : full,
    );
  }
}

/// Compact upload area: a lavender panel with a dashed outline, the
/// attachment rules and the "Pilih Berkas" action, or the selected file.
///
/// The action sits beside the copy when the description still fits on two
/// lines next to it, and below the copy otherwise.
class _EvidenceField extends StatelessWidget {
  const _EvidenceField({
    required this.fileName,
    required this.fileSize,
    required this.errorText,
    required this.isRequired,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
    required this.formatBytes,
  });

  final String? fileName;
  final int fileSize;
  final String? errorText;
  final bool isRequired;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final String Function(int bytes) formatBytes;

  // A no-break space keeps "5 MB" together instead of orphaning "MB.".
  static const _description =
      'PDF atau gambar (jpg, jpeg, png, webp), maksimal 5 MB.';
  static const _titleStyle = TextStyle(
    color: _heading,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );
  static const _descriptionStyle = TextStyle(
    color: _bodyMuted,
    fontSize: 12,
    height: 1.35,
    letterSpacing: 0,
  );
  static const _actionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const _radius = 18.0;
  static const _badgeSize = 40.0;
  static const _gap = 12.0;

  /// Pill padding, icon and gap around the "Pilih Berkas" label.
  static const _actionChrome = 14 * 2 + 18 + 8.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: errorText != null ? scheme.error : _lavenderDash,
            radius: _radius,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _lavenderFill,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    _content(context, constraints.maxWidth, scheme.error),
              ),
            ),
          ),
        ),
        if (errorText != null) _FieldError(message: errorText!),
      ],
    );
  }

  Widget _content(BuildContext context, double maxWidth, Color errorColor) {
    final copyWidth = maxWidth - _badgeSize - _gap;
    final pickWidth =
        _textSize(context, 'Pilih Berkas', _actionStyle).width + _actionChrome;
    final besideWidth = copyWidth - _gap - pickWidth;
    final lineHeight = _textSize(context, 'M', _descriptionStyle).height;
    final beside =
        fileName == null &&
        !_largeText(context) &&
        besideWidth > 0 &&
        _textSize(context, 'Lampiran Bukti *', _titleStyle).width <=
            besideWidth &&
        _textSize(
              context,
              _description,
              _descriptionStyle,
              maxWidth: besideWidth,
            ).height <=
            lineHeight * 2 + 0.5;

    const badge = SizedBox.square(
      dimension: _badgeSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _lavenderTint,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Icon(Icons.attach_file_rounded, size: 22, color: _navy),
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Lampiran Bukti',
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: errorColor),
                ),
            ],
          ),
          style: _titleStyle,
        ),
        const SizedBox(height: 2),
        const Text(_description, style: _descriptionStyle),
      ],
    );
    final pick = OutlinedButton.icon(
      onPressed: enabled ? onPick : null,
      icon: const Icon(Icons.file_upload_outlined, size: 18),
      label: const Text('Pilih Berkas', style: _actionStyle),
      style: OutlinedButton.styleFrom(
        foregroundColor: _navy,
        backgroundColor: Colors.white,
        side: const BorderSide(color: _navy),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: const Size(0, 40),
      ),
    );

    if (beside) {
      return Row(
        children: [
          badge,
          const SizedBox(width: _gap),
          Expanded(child: copy),
          const SizedBox(width: _gap),
          pick,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            badge,
            const SizedBox(width: _gap),
            Expanded(child: copy),
          ],
        ),
        const SizedBox(height: 12),
        if (fileName != null)
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _lavenderTint),
            ),
            child: ListTile(
              contentPadding: const EdgeInsetsDirectional.only(
                start: 12,
                end: 4,
              ),
              horizontalTitleGap: 12,
              leading: const Icon(
                Icons.insert_drive_file_outlined,
                color: _navy,
              ),
              title: Text(
                fileName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _heading,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                formatBytes(fileSize),
                style: const TextStyle(color: _bodyMuted, fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: enabled ? onRemove : null,
                tooltip: 'Hapus lampiran',
              ),
            ),
          )
        else
          // Indented under the copy when it fits there.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: pickWidth <= copyWidth ? _badgeSize + _gap : 0,
              ),
              child: pick,
            ),
          ),
      ],
    );
  }
}

/// Dashed rounded outline for the upload area, cut from the rounded
/// rectangle's path so no extra package is needed.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 6.0;
  static const _space = 4.0;
  static const _strokeWidth = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_strokeWidth / 2),
          Radius.circular(radius),
        ),
      );
    final dashes = Path();
    for (final metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _space) {
        dashes.addPath(
          metric.extractPath(start, math.min(start + _dash, metric.length)),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(
      dashes,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Error line under a control that is not a text field, aligned with the
/// text fields' own error text.
class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

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
