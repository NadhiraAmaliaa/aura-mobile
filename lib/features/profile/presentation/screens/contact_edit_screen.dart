import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/profile_edit_notifier.dart';

/// Form for editing the intern's contact details ("Ubah Kontak").
///
/// Reuses the auth repository's `updateContact` endpoint. Client-side checks
/// mirror the backend `UpdateContactRequest` rules for immediate feedback, but
/// the server stays the source of truth: any 422 is mapped back onto the
/// offending fields (e.g. a duplicate email).
class ContactEditScreen extends ConsumerStatefulWidget {
  const ContactEditScreen({super.key});

  @override
  ConsumerState<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends ConsumerState<ContactEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  Map<String, List<String>> _serverErrors = {};
  bool _isSubmitting = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _prefill(UserModel user) {
    if (_prefilled) return;
    _emailController.text = user.email ?? '';
    _phoneController.text = user.intern?.phone ?? '';
    _prefilled = true;
  }

  String? _serverError(String field) {
    final messages = _serverErrors[field];
    return (messages == null || messages.isEmpty) ? null : messages.first;
  }

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors.remove(field));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final user = switch (ref.watch(authProvider)) {
      AsyncData(value: Authenticated(:final user)) => user,
      _ => null,
    };
    if (user != null) _prefill(user);

    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Kontak'), centerTitle: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      maxLength: 255,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        counterText: '',
                        errorText: _serverError('email'),
                      ),
                      onChanged: (_) => _clearServerError('email'),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: 'Nomor HP',
                        border: const OutlineInputBorder(),
                        counterText: '',
                        errorText: _serverError('phone'),
                      ),
                      onChanged: (_) => _clearServerError('phone'),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pastikan email dan nomor HP yang kamu masukkan '
                              'sudah benar.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null; // Email is optional, matching the backend.
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(text)) {
      return 'Format email tidak valid.';
    }
    if (text.length > 255) return 'Email maksimal 255 karakter.';
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 30) return 'Nomor HP maksimal 30 karakter.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _serverErrors = {});

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final result = await ref
        .read(profileEditProvider.notifier)
        .updateContact(
          ContactUpdateRequest(
            email: email.isEmpty ? null : email,
            phone: phone.isEmpty ? null : phone,
          ),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success<UserModel>():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Kontak berhasil diperbarui.')),
          );
        context.pop();
      case Failure<UserModel>(:final exception):
        _handleFailure(exception);
    }
  }

  void _handleFailure(AppException exception) {
    if (exception is ValidationException && exception.errors.isNotEmpty) {
      setState(() => _serverErrors = exception.errors);
      _formKey.currentState?.validate();
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(exception.message)));
  }
}
