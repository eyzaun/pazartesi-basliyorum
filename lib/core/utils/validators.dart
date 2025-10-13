/// Validation utilities for forms.
class Validators {
  /// Validate email address.
  static String? email(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'E-posta gerekli';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }

    return null;
  }

  /// Validate password.
  static String? password(String? value,
      {int minLength = 6, String? errorMessage,}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Şifre gerekli';
    }

    if (value.length < minLength) {
      return 'Şifre en az $minLength karakter olmalı';
    }

    return null;
  }

  /// Validate username.
  static String? username(String? value,
      {int minLength = 3, String? errorMessage,}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Kullanıcı adı gerekli';
    }

    if (value.length < minLength) {
      return 'Kullanıcı adı en az $minLength karakter olmalı';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Sadece harf, rakam ve alt çizgi kullanabilirsiniz';
    }

    return null;
  }

  /// Validate required field.
  static String? required(String? value,
      {String? fieldName, String? errorMessage,}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? '${fieldName ?? "Bu alan"} gerekli';
    }
    return null;
  }

  /// Validate minimum length.
  static String? minLength(String? value, int length, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle this
    }

    if (value.length < length) {
      return errorMessage ?? 'En az $length karakter olmalı';
    }

    return null;
  }

  /// Validate maximum length.
  static String? maxLength(String? value, int length, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > length) {
      return errorMessage ?? 'En fazla $length karakter olabilir';
    }

    return null;
  }

  /// Validate that two values match (e.g., password confirmation).
  static String? match(String? value, String? otherValue,
      {String? errorMessage,}) {
    if (value != otherValue) {
      return errorMessage ?? 'Değerler eşleşmiyor';
    }
    return null;
  }

  /// Combine multiple validators.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
