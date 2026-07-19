import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/utils/indo_date.dart';
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
    final theme = Theme.of(context);
    final dateError = _dateError ?? _serverError('early_leave_date');
    final timeError = _timeError ?? _serverError('leave_time');

    return Scaffold(
      appBar: AppBar(title: const Text('Surat Pulang Cepat')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Surat Izin Pulang Sebelum Waktunya',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Identitas Anda diambil otomatis dari akun. Lengkapi rincian '
              'berikut, lalu surat akan dibuat untuk dicetak atau disimpan.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            _PickerField(
              label: 'Tanggal Pulang',
              value: _date != null ? formatIndoDate(_isoDate(_date!)) : null,
              placeholder: 'Pilih tanggal',
              icon: Icons.calendar_today_outlined,
              errorText: dateError,
              enabled: !_isSubmitting,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),

            _PickerField(
              label: 'Jam Meninggalkan Kantor',
              value: _time != null ? _formatTime(_time!) : null,
              placeholder: 'Pilih jam',
              icon: Icons.schedule_outlined,
              errorText: timeError,
              enabled: !_isSubmitting,
              onTap: _pickTime,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              maxLines: 4,
              maxLength: 1000,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Alasan',
                hintText: 'Jelaskan alasan Anda pulang lebih awal',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
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
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print_outlined),
              label: Text(_isSubmitting ? 'Menyiapkan…' : 'Buat & Cetak Surat'),
            ),
          ],
        ),
      ),
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

  /// Machine-readable `yyyy-MM-dd` for [formatIndoDate] and the API.
  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

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

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.errorText,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final String? errorText;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
        suffixIcon: Icon(icon),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value ?? placeholder,
            style: value != null
                ? theme.textTheme.bodyLarge
                : theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}
