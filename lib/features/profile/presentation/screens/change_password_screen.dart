import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../auth/data/models/auth_models.dart';
import '../providers/change_password_notifier.dart';

/// Form for changing the account password ("Ganti Password").
///
/// Reuses the auth repository's `updatePassword` endpoint. Client-side checks
/// mirror the backend rules (current password required, new password confirmed
/// and at least 3 characters); a wrong current password comes back as a 422 and
/// is mapped onto the field.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Map<String, List<String>> _serverErrors = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Password'), centerTitle: true),
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
                      controller: _currentController,
                      enabled: !_isSubmitting,
                      obscureText: _obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'Password Saat Ini',
                        border: const OutlineInputBorder(),
                        errorText: _serverError('current_password'),
                        suffixIcon: _VisibilityToggle(
                          obscured: _obscureCurrent,
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                        ),
                      ),
                      onChanged: (_) => _clearServerError('current_password'),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Password saat ini wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newController,
                      enabled: !_isSubmitting,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        border: const OutlineInputBorder(),
                        errorText: _serverError('password'),
                        suffixIcon: _VisibilityToggle(
                          obscured: _obscureNew,
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      onChanged: (_) => _clearServerError('password'),
                      validator: (value) {
                        final text = value ?? '';
                        if (text.isEmpty) {
                          return 'Password baru wajib diisi.';
                        }
                        if (text.length < 3) {
                          return 'Password baru minimal 3 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      enabled: !_isSubmitting,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        border: const OutlineInputBorder(),
                        suffixIcon: _VisibilityToggle(
                          obscured: _obscureConfirm,
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Konfirmasi password wajib diisi.';
                        }
                        if (value != _newController.text) {
                          return 'Konfirmasi password tidak cocok.';
                        }
                        return null;
                      },
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _serverErrors = {});

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(changePasswordProvider.notifier)
        .submit(
          PasswordUpdateRequest(
            currentPassword: _currentController.text,
            password: _newController.text,
            passwordConfirmation: _confirmController.text,
          ),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success<void>():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Kata sandi berhasil diperbarui.')),
          );
        context.pop();
      case Failure<void>(:final exception):
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

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: obscured ? 'Tampilkan' : 'Sembunyikan',
      icon: Icon(obscured ? Icons.visibility_off : Icons.visibility),
      onPressed: onPressed,
    );
  }
}
