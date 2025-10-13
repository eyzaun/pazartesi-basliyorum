import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension methods for String.
extension StringExtensions on String {
  /// Capitalize first letter.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case.
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Check if string is a valid email.
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Truncate string to a specific length.
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}

/// Extension methods for DateTime.
extension DateTimeExtensions on DateTime {
  /// Format date as 'dd/MM/yyyy'.
  String toDateString() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format time as 'HH:mm'.
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format as 'dd MMM yyyy' (e.g., '15 Oca 2025').
  String toFormattedDate({String locale = 'tr_TR'}) {
    return DateFormat('dd MMM yyyy', locale).format(this);
  }

  /// Format as full date and time.
  String toFullDateTime({String locale = 'tr_TR'}) {
    return DateFormat('dd MMMM yyyy HH:mm', locale).format(this);
  }

  /// Check if date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get start of day (00:00:00).
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59).
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Get difference in days from now.
  int get daysFromNow {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }

  /// Get relative time string (e.g., '2 days ago', 'just now').
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? "yıl" : "yıl"} önce';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "ay" : "ay"} önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? "gün" : "gün"} önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? "saat" : "saat"} önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? "dakika" : "dakika"} önce';
    } else {
      return 'az önce';
    }
  }
}

/// Extension methods for BuildContext.
extension BuildContextExtensions on BuildContext {
  /// Get screen size.
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width.
  double get screenWidth => screenSize.width;

  /// Get screen height.
  double get screenHeight => screenSize.height;

  /// Get theme.
  ThemeData get theme => Theme.of(this);

  /// Get color scheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Check if in dark mode.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Show snackbar.
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show error snackbar.
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  /// Show success snackbar.
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}

/// Extension methods for List.
extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty.
  bool get isNullOrEmpty => isEmpty;

  /// Check if list is not null and not empty.
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Get first element or null if empty.
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if empty.
  T? get lastOrNull => isEmpty ? null : last;
}
