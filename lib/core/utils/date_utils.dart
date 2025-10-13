import 'package:intl/intl.dart';

/// Date utility functions for the application.
class AppDateUtils {
  /// Get start of day (00:00:00).
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59).
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of week (Monday).
  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  /// Get end of week (Sunday).
  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToAdd)));
  }

  /// Get start of month.
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Get end of month.
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Check if two dates are the same day.
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Check if date is tomorrow.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Get days between two dates.
  static int daysBetween(DateTime from, DateTime to) {
    final startFrom = startOfDay(from);
    final startTo = startOfDay(to);
    return startTo.difference(startFrom).inDays;
  }

  /// Format date as 'dd/MM/yyyy'.
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date as 'dd MMM yyyy' (e.g., '15 Oca 2025').
  static String formatDateLong(DateTime date, {String locale = 'tr_TR'}) {
    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  /// Format date as 'EEEE, dd MMMM yyyy' (e.g., 'Pazartesi, 15 Ocak 2025').
  static String formatDateFull(DateTime date, {String locale = 'tr_TR'}) {
    return DateFormat('EEEE, dd MMMM yyyy', locale).format(date);
  }

  /// Format time as 'HH:mm'.
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date and time.
  static String formatDateTime(DateTime date, {String locale = 'tr_TR'}) {
    return DateFormat('dd MMM yyyy HH:mm', locale).format(date);
  }

  /// Get relative time string (e.g., 'Just now', '2 hours ago').
  static String getRelativeTime(DateTime date, {String locale = 'tr'}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return locale == 'tr' ? 'Az önce' : 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return locale == 'tr'
          ? '$minutes dakika önce'
          : '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return locale == 'tr'
          ? '$hours saat önce'
          : '$hours hour${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return locale == 'tr'
          ? '$days gün önce'
          : '$days day${days > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return locale == 'tr'
          ? '$weeks hafta önce'
          : '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return locale == 'tr'
          ? '$months ay önce'
          : '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return locale == 'tr'
          ? '$years yıl önce'
          : '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  /// Get day name (e.g., 'Monday').
  static String getDayName(DateTime date, {String locale = 'tr_TR'}) {
    return DateFormat('EEEE', locale).format(date);
  }

  /// Get month name (e.g., 'January').
  static String getMonthName(DateTime date, {String locale = 'tr_TR'}) {
    return DateFormat('MMMM', locale).format(date);
  }

  /// Get week number of the year.
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Get list of dates in a week.
  static List<DateTime> getDatesInWeek(DateTime date) {
    final startDate = startOfWeek(date);
    return List.generate(7, (index) => startDate.add(Duration(days: index)));
  }

  /// Get list of dates in a month.
  static List<DateTime> getDatesInMonth(DateTime date) {
    final start = startOfMonth(date);
    final end = endOfMonth(date);
    final days = daysBetween(start, end) + 1;
    return List.generate(days, (index) => start.add(Duration(days: index)));
  }

  /// Parse date string (dd/MM/yyyy).
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Check if year is leap year.
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get number of days in month.
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
