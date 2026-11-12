import 'package:flutter/material.dart';

import '../../../../shared/widgets/aura_form.dart';

/// The AURA navy of the profile pages' app bars and focused labels.
const _navy = Color(0xFF0B2559);

/// A profile form page (Ubah Kontak, Ganti Password): the AURA page shell,
/// [children] scrolling inside the page gutters, and the navy "Simpan
/// Perubahan" button pinned below them, so it stays above the keyboard.
///
/// The fields sit in a plain scroll view, not a lazy ListView, so
/// `Form.validate()` reaches every field even when one is scrolled far out of
/// view.
class ProfileFormPage extends StatelessWidget {
  const ProfileFormPage({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSubmit;

  /// Disables the button and shows its spinner while the save runs.
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final horizontal = AuraForm.pageInset(MediaQuery.sizeOf(context).width);

    return AuraPageScaffold(
      title: title,
      foregroundColor: _navy,
      centerTitle: true,
      body: SafeArea(
        top: false,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Room above the first field for its floating label.
                  padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 16),
                child: AuraSubmitButton(
                  label: 'Simpan Perubahan',
                  onPressed: onSubmit,
                  isBusy: isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Between two fields, leaving room for the next one's floating label.
const profileFieldGap = 20.0;

// Zero letter spacing overrides the inherited M3 body tracking, as on Home.
const _restingLabelStyle = TextStyle(
  color: AuraForm.bodyMuted,
  fontSize: 16,
  letterSpacing: 0,
);

/// The decoration of a profile form field: the AURA input look (white fill,
/// rounded outline, navy focus) from the page theme, with a floating [label]
/// in AURA colours.
///
/// The label rests inside the empty, unfocused field and floats, smaller, onto
/// the outline once the field is focused or filled: muted, navy while
/// focused, red on an error. A [suffixIcon] is muted, and navy while the field
/// is focused.
InputDecoration profileFieldDecoration({
  required String label,
  String? errorText,
  Widget? suffixIcon,
  String? counterText,
}) {
  final error = AuraForm.theme.colorScheme.error;
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    counterText: counterText,
    suffixIcon: suffixIcon,
    labelStyle: _restingLabelStyle,
    floatingLabelStyle: WidgetStateTextStyle.resolveWith(
      (states) => _restingLabelStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: states.contains(WidgetState.error)
            ? error
            : states.contains(WidgetState.focused)
            ? _navy
            : AuraForm.bodyMuted,
      ),
    ),
    suffixIconColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? AuraForm.bodyMuted.withValues(alpha: 0.5)
          : states.contains(WidgetState.focused)
          ? _navy
          : AuraForm.bodyMuted,
    ),
  );
}
