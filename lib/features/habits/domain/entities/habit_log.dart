import 'package:equatable/equatable.dart';

/// Domain entity representing a habit check-in log.
class HabitLog extends Equatable {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.completed,
    required this.createdAt,
    this.skipped = false,
    this.skipReason,
    this.quality,
    this.note,
    this.mood,
    this.durationSeconds, // Part 4: Timer duration
  });
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  final bool completed;
  final bool skipped;
  final String? skipReason;
  final LogQuality? quality;
  final String? note;
  final String? mood;
  final int? durationSeconds; // Part 4: Duration in seconds for timed habits
  final DateTime createdAt;

  HabitLog copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? date,
    bool? completed,
    bool? skipped,
    String? skipReason,
    LogQuality? quality,
    String? note,
    String? mood,
    int? durationSeconds,
    DateTime? createdAt,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      skipped: skipped ?? this.skipped,
      skipReason: skipReason ?? this.skipReason,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      mood: mood ?? this.mood,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        userId,
        date,
        completed,
        skipped,
        skipReason,
        quality,
        note,
        mood,
        durationSeconds,
        createdAt,
      ];
}

/// Log quality enum.
enum LogQuality {
  minimal,
  good,
  excellent,
}

/// Extension to convert string to LogQuality.
extension LogQualityExtension on String {
  LogQuality? toLogQuality() {
    switch (this) {
      case 'minimal':
        return LogQuality.minimal;
      case 'good':
        return LogQuality.good;
      case 'excellent':
        return LogQuality.excellent;
      default:
        return null;
    }
  }
}

/// Extension to convert enum to string.
extension LogQualityString on LogQuality {
  String get value {
    switch (this) {
      case LogQuality.minimal:
        return 'minimal';
      case LogQuality.good:
        return 'good';
      case LogQuality.excellent:
        return 'excellent';
    }
  }
}

/// Habit statistics entity.
class HabitStatistics extends Equatable {
  const HabitStatistics({
    required this.habitId,
    required this.totalCompletions,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    this.lastCompletedDate,
  });
  final String habitId;
  final int totalCompletions;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final DateTime? lastCompletedDate;

  @override
  List<Object?> get props => [
        habitId,
        totalCompletions,
        currentStreak,
        longestStreak,
        completionRate,
        lastCompletedDate,
      ];
}
