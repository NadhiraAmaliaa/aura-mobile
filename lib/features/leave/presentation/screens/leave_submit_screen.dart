import 'dart:io';
import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/widgets/aura_form.dart';
import '../../data/models/leave_submission.dart';
import '../providers/leave_submit_notifier.dart';

// Accents of the type selector and the upload panel, which only this form
// has; the look it shares with the Surat form is in `AuraForm`.
const _segmentSelected = Color(0xFFFFEBC4);
const _lavenderFill = Color(0xFFF7F6FE);
const _lavenderDash = Color(0xFFB4AEE8);
const _lavenderTint = Color(0xFFE6E5FB);

/// Same breakpoint as `HomeLayout.largeText` (body text measured at 14sp):
/// side-by-side compositions stack.
bool _largeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14 > 1.35;

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
          ? AuraForm.heading.withValues(alpha: 0.5)
          : AuraForm.heading,
    ),
    iconColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? AuraForm.heading.withValues(alpha: 0.5)
          : AuraForm.heading,
    ),
    side: const WidgetStatePropertyAll(BorderSide(color: AuraForm.fieldBorder)),
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
    final startError = _startDateError ?? _serverError('start_date');
    final endError = _endDateError ?? _serverError('end_date');
    final evidenceError = _evidenceError ?? _serverError('evidence');
    final typeError = _serverError('type');

    return AuraFormPage(
      title: 'Ajukan Izin / Sakit',
      formKey: _formKey,
      children: [
        const AuraFieldLabel('Jenis Pengajuan'),
        const SizedBox(height: AuraForm.labelGap),
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
        if (typeError != null) AuraFieldError(message: typeError),
        const SizedBox(height: AuraForm.sectionGap),

        AuraLabeledField(
          label: 'Alasan',
          isRequired: true,
          child: TextFormField(
            controller: _reasonController,
            enabled: !_isSubmitting,
            maxLines: 4,
            maxLength: 1000,
            textInputAction: TextInputAction.newline,
            style: AuraForm.inputStyle,
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
        const SizedBox(height: AuraForm.counterGap),

        AuraPickerField.date(
          label: 'Tanggal Mulai',
          isRequired: true,
          date: _startDate,
          errorText: startError,
          enabled: !_isSubmitting,
          onTap: () => _pickDate(isStart: true),
        ),
        const SizedBox(height: AuraForm.pairGap),

        AuraPickerField.date(
          label: 'Tanggal Selesai',
          isRequired: true,
          date: _endDate,
          errorText: endError,
          enabled: !_isSubmitting,
          onTap: () => _pickDate(isStart: false),
        ),
        const SizedBox(height: AuraForm.sectionGap),

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
        const SizedBox(height: AuraForm.sectionGap),

        AuraLabeledField(
          label: 'Nomor Kontak',
          child: TextFormField(
            controller: _contactController,
            enabled: !_isSubmitting,
            maxLength: 30,
            buildCounter: _noCounter,
            keyboardType: TextInputType.phone,
            style: AuraForm.inputStyle,
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
        const SizedBox(height: AuraForm.sectionGap),

        AuraLabeledField(
          label: 'Alamat Selama Izin',
          child: TextFormField(
            controller: _addressController,
            enabled: !_isSubmitting,
            maxLines: 2,
            maxLength: 500,
            buildCounter: _noCounter,
            style: AuraForm.inputStyle,
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
        const SizedBox(height: AuraForm.sectionGap),

        AuraSubmitButton(
          label: 'Kirim Pengajuan',
          onPressed: _submit,
          isBusy: _isSubmitting,
        ),
      ],
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
      builder: AuraForm.pickerBuilder,
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
            // A copy: entries are removed as fields change, and a 422
            // without field errors carries an unmodifiable empty map.
            setState(() => _serverErrors = Map.of(error.errors));
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
    color: AuraForm.heading,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );
  static const _descriptionStyle = TextStyle(
    color: AuraForm.bodyMuted,
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
        if (errorText != null) AuraFieldError(message: errorText!),
      ],
    );
  }

  Widget _content(BuildContext context, double maxWidth, Color errorColor) {
    final copyWidth = maxWidth - _badgeSize - _gap;
    final pickWidth =
        AuraForm.textSize(context, 'Pilih Berkas', _actionStyle).width +
        _actionChrome;
    final besideWidth = copyWidth - _gap - pickWidth;
    final lineHeight = AuraForm.textSize(
      context,
      'M',
      _descriptionStyle,
    ).height;
    final beside =
        fileName == null &&
        !_largeText(context) &&
        besideWidth > 0 &&
        AuraForm.textSize(context, 'Lampiran Bukti *', _titleStyle).width <=
            besideWidth &&
        AuraForm.textSize(
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
        child: Icon(Icons.attach_file_rounded, size: 22, color: AuraForm.navy),
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
        foregroundColor: AuraForm.navy,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AuraForm.navy),
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
                color: AuraForm.navy,
              ),
              title: Text(
                fileName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AuraForm.heading,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                formatBytes(fileSize),
                style: const TextStyle(color: AuraForm.bodyMuted, fontSize: 12),
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
