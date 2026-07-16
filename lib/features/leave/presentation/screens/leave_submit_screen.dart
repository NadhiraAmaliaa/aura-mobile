import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../data/models/leave_submission.dart';
import '../providers/leave_submit_notifier.dart';

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
    final theme = Theme.of(context);
    final startError = _startDateError ?? _serverError('start_date');
    final endError = _endDateError ?? _serverError('end_date');
    final evidenceError = _evidenceError ?? _serverError('evidence');
    final typeError = _serverError('type');

    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Izin / Sakit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Jenis Pengajuan', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'izin', label: Text('Izin')),
                ButtonSegment(value: 'sakit', label: Text('Sakit')),
              ],
              selected: {_type},
              onSelectionChanged: _isSubmitting
                  ? null
                  : (selection) => _onTypeChanged(selection.first),
            ),
            if (typeError != null) _FieldError(message: typeError),
            const SizedBox(height: 20),

            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              maxLines: 4,
              maxLength: 1000,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Alasan',
                hintText: 'Jelaskan alasan pengajuan Anda',
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
            const SizedBox(height: 12),

            _DateField(
              label: 'Tanggal Mulai',
              value: _startDate,
              errorText: startError,
              enabled: !_isSubmitting,
              onTap: () => _pickDate(isStart: true),
            ),
            const SizedBox(height: 12),

            _DateField(
              label: 'Tanggal Selesai',
              value: _endDate,
              errorText: endError,
              enabled: !_isSubmitting,
              onTap: () => _pickDate(isStart: false),
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),

            TextFormField(
              controller: _contactController,
              enabled: !_isSubmitting,
              maxLength: 30,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Kontak (opsional)',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 12),

            TextFormField(
              controller: _addressController,
              enabled: !_isSubmitting,
              maxLines: 2,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Alamat Selama Izin (opsional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
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
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kirim Pengajuan'),
            ),
          ],
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
      mimeTypes: [
        'application/pdf',
        'image/jpeg',
        'image/png',
        'image/webp',
      ],
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

    final manualValid = _startDateError == null &&
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
      final result =
          await ref.read(leaveSubmitProvider.notifier).submit(submission);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value != null
                ? formatIndoDate(
                    '${value!.year.toString().padLeft(4, '0')}-'
                    '${value!.month.toString().padLeft(2, '0')}-'
                    '${value!.day.toString().padLeft(2, '0')}',
                  )
                : 'Pilih tanggal',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Lampiran Bukti', style: theme.textTheme.labelLarge),
            const SizedBox(width: 4),
            if (isRequired)
              Text('*', style: TextStyle(color: scheme.error)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'PDF atau gambar (jpg, jpeg, png, webp), maksimal 5 MB.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (fileName != null)
          Card(
            elevation: 0,
            color: scheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(
                fileName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(formatBytes(fileSize)),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: enabled ? onRemove : null,
                tooltip: 'Hapus lampiran',
              ),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: enabled ? onPick : null,
            icon: const Icon(Icons.attach_file),
            label: const Text('Pilih Berkas'),
          ),
        if (errorText != null) _FieldError(message: errorText!),
      ],
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
      ),
    );
  }
}
