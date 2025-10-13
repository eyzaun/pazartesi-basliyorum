import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';

/// Custom email input field with validation.
class EmailInputField extends StatelessWidget {
  const EmailInputField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText ?? l10n.email,
        hintText: hintText ?? 'ornek@email.com',
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction ?? TextInputAction.next,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: false,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validator: validator ??
          (value) => Validators.email(
                value,
                errorMessage: l10n.emailRequired,
              ),
    );
  }
}
