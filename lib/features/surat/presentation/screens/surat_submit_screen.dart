import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/widgets/aura_form.dart';
import '../../data/models/surat_submission.dart';
import '../providers/surat_submit_notifier.dart';

/// Form for generating a "Surat Izin Pulang Sebelum Waktunya" (early-leave
/// letter).
///
/// Stateless feature: submitting posts the fields to the backend, which renders
/// the PDF and streams it back for the native print / "Save as PDF" preview.
/// Nothing is persisted. The intern's identity is taken from the authenticated
/// account, so it is not collected here.
///
/// The field set is provisional — it tracks the current backend contract while
/// SDM confirms the final letter structure. When the requirements settle,
/// adjust the fields here together with [SuratSubmission] and the repository's
/// body mapping.
class SuratSubmitScreen extends ConsumerStatefulWidget {
  const SuratSubmitScreen({super.key});

  @override
  ConsumerState<SuratSubmitScreen> createState() => _SuratSubmitScreenState();
}

class _SuratSubmitScreenState extends ConsumerState<SuratSubmitScreen> {
  // The letter's title and intro, sized and coloured like the leave landing
  // page's section heading and body copy.
  static const _titleStyle = TextStyle(
    color: AuraForm.heading,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );
  static const _introStyle = TextStyle(
    color: AuraForm.bodyMuted,
    fontSize: 13,
    height: 1.4,
    letterSpacing: 0,
  );

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;

  // Client-side errors for the non-text fields (date, time).
  String? _dateError;
  String? _timeError;

  // Field-keyed messages from a server 422, mirroring Laravel's shape.
  Map<String, List<String>> _serverErrors = {};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    final messages = _serverErrors[field];
    return (messages == null || messages.isEmpty) ? null : messages.first;
  }

  @override
  Widget build(BuildContext context) {
    final dateError = _dateError ?? _serverError('early_leave_date');
    final timeError = _timeError ?? _serverError('leave_time');

    return AuraFormPage(
      title: 'Surat Pulang Cepat',
      formKey: _formKey,
      children: [
        const Text('Surat Izin Pulang Sebelum Waktunya', style: _titleStyle),
        const SizedBox(height: 4),
        const Text(
          'Identitas Anda diambil otomatis dari akun. Lengkapi rincian '
          'berikut, lalu surat akan dibuat untuk dicetak atau disimpan.',
          style: _introStyle,
        ),
        const SizedBox(height: AuraForm.sectionGap),

        AuraPickerField.date(
          label: 'Tanggal Pulang',
          isRequired: true,
          date: _date,
          errorText: dateError,
          enabled: !_isSubmitting,
          onTap: _pickDate,
        ),
        const SizedBox(height: AuraForm.pairGap),

        AuraPickerField(
          label: 'Jam Meninggalkan Kantor',
          isRequired: true,
          value: _time != null ? _formatTime(_time!) : null,
          placeholder: 'Pilih jam',
          icon: Icons.schedule_outlined,
          errorText: timeError,
          enabled: !_isSubmitting,
          onTap: _pickTime,
        ),
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
              hintText: 'Jelaskan alasan Anda pulang lebih awal',
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
        const SizedBox(height: AuraForm.sectionGap),

        AuraSubmitButton(
          label: 'Buat & Cetak Surat',
          icon: Icons.print_outlined,
          busyLabel: 'Menyiapkan…',
          onPressed: _submit,
          isBusy: _isSubmitting,
        ),
      ],
    );
  }

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors.remove(field));
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final initial = _date ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 2),
      // AURA colours only; the limits and behaviour above are unchanged.
      builder: AuraForm.pickerBuilder,
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateError = null;
      _serverErrors.remove('early_leave_date');
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: AuraForm.pickerBuilder,
    );
    if (picked == null) return;
    setState(() {
      _time = picked;
      _timeError = null;
      _serverErrors.remove('leave_time');
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _dateError = _date == null ? 'Tanggal pulang wajib diisi.' : null;
      _timeError = _time == null ? 'Jam pulang wajib diisi.' : null;
    });

    final manualValid = _dateError == null && _timeError == null;
    if (!formValid || !manualValid) return;

    final submission = SuratSubmission(
      earlyLeaveDate: _date!,
      leaveTime: _formatTime(_time!),
      reason: _reasonController.text.trim(),
    );

    setState(() => _isSubmitting = true);
    _showSnack('Menyiapkan surat…');
    try {
      final result = await ref
          .read(suratSubmitProvider.notifier)
          .generate(submission);
      if (!mounted) return;

      result.fold(
        onSuccess: (_) => _showSnack('Surat siap dicetak atau disimpan.'),
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

  /// 24-hour `HH:mm` for the API and display (matches the backend `H:i` rule).
  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
