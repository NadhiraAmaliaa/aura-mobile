import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../data/models/university_model.dart';
import '../providers/login_notifier.dart';
import '../providers/university_providers.dart';

/// The login form: university dropdown + NIM + password, wired to
/// [LoginNotifier]. Stateful so it can own the text controllers, the selected
/// university, and the password-visibility toggle.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  int? _universityId;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(loginProvider.notifier)
        .submit(
          universityId: _universityId!,
          nim: _nimController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final universitiesAsync = ref.watch(universitiesProvider);
    final loginState = ref.watch(loginProvider);
    final isSubmitting = loginState.isLoading;

    // Surface login failures as a SnackBar without rebuilding into an error UI.
    ref.listen<AsyncValue<void>>(loginProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        final message = error is AppException
            ? error.message
            : 'An unexpected error occurred.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UniversityField(
            universitiesAsync: universitiesAsync,
            value: _universityId,
            enabled: !isSubmitting,
            onChanged: (id) => setState(() => _universityId = id),
            onRetry: () => ref.invalidate(universitiesProvider),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nimController,
            enabled: !isSubmitting,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Username (NIM)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Please enter your NIM.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            enabled: !isSubmitting,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => isSubmitting ? null : _submit(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Please enter your password.'
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Log in'),
          ),
        ],
      ),
    );
  }
}

/// University dropdown that reflects the loading/error/data states of
/// [universitiesProvider].
class _UniversityField extends StatelessWidget {
  const _UniversityField({
    required this.universitiesAsync,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onRetry,
  });

  final AsyncValue<List<University>> universitiesAsync;
  final int? value;
  final bool enabled;
  final ValueChanged<int?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return universitiesAsync.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'University',
          prefixIcon: Icon(Icons.school_outlined),
        ),
        child: SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (_, _) => InputDecorator(
        decoration: const InputDecoration(
          labelText: 'University',
          prefixIcon: Icon(Icons.school_outlined),
          errorText: 'Could not load universities.',
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ),
      data: (universities) => DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'University',
          prefixIcon: Icon(Icons.school_outlined),
        ),
        items: [
          for (final university in universities)
            DropdownMenuItem<int>(
              value: university.id,
              child: Text(university.name, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: enabled ? onChanged : null,
        validator: (selected) =>
            selected == null ? 'Please select your university.' : null,
      ),
    );
  }
}
