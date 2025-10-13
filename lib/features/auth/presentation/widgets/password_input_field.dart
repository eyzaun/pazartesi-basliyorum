import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';

/// Custom password input field with visibility toggle.
class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
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
    this.minLength = 6,
    this.showStrengthIndicator = false,
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
  final int minLength;
  final bool showStrengthIndicator;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;
  PasswordStrength _strength = PasswordStrength.none;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_updateStrength);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateStrength);
    super.dispose();
  }

  void _updateStrength() {
    if (widget.showStrengthIndicator) {
      setState(() {
        _strength = _calculateStrength(widget.controller?.text ?? '');
      });
    }
  }

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;

    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.labelText ?? l10n.password,
            hintText: widget.hintText ?? '••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          obscureText: _obscureText,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          autocorrect: false,
          enableSuggestions: false,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: widget.onChanged,
          validator: widget.validator ??
              (value) => Validators.password(
                    value,
                    minLength: widget.minLength,
                    errorMessage: l10n.passwordRequired,
                  ),
        ),

        // Password strength indicator
        if (widget.showStrengthIndicator &&
            _strength != PasswordStrength.none) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _strength.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_strength.color),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _strength.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _strength.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Password strength enum.
enum PasswordStrength {
  none(0, Colors.grey, 'Yok'),
  weak(0.33, Colors.red, 'Zayıf'),
  medium(0.66, Colors.orange, 'Orta'),
  strong(1, Colors.green, 'Güçlü');

  const PasswordStrength(this.value, this.color, this.label);

  final double value;
  final Color color;
  final String label;
}
