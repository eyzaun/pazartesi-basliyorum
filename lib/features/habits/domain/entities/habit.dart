import 'package:equatable/equatable.dart';

/// Domain entity representing a habit.
class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.isShared = false,
    this.status = HabitStatus.active,
    // Part 4: Habit Stacking
    this.isStacked = false,
    this.stackedWithId,
    this.stackOrder,
    this.stackTriggerType,
    this.stackTriggerDelay,
    // Part 4: Timed Habits
    this.isTimedHabit = false,
    this.targetDurationMinutes,
    this.allowBackgroundTimer = true,
    this.timerSound,
    this.vibrateOnComplete = true,
    this.ambientSound,
  });
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String category;
  final String icon;
  final String color;
  final HabitFrequency frequency;
  final bool isShared;
  final HabitStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Part 4: Habit Stacking fields
  final bool isStacked;
  final String? stackedWithId; // parent stack ID
  final int? stackOrder; // order in stack (0, 1, 2...)
  final String? stackTriggerType; // 'after_completion', 'after_time'
  final int? stackTriggerDelay; // minutes to wait before next habit
  
  // Part 4: Timed Habit fields
  final bool isTimedHabit;
  final int? targetDurationMinutes; // target duration in minutes
  final bool allowBackgroundTimer; // allow timer to run in background
  final String? timerSound; // completion sound file name
  final bool vibrateOnComplete; // vibrate when timer completes
  final String? ambientSound; // ambient sound during timer (e.g., 'nature', 'rain')

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? icon,
    String? color,
    HabitFrequency? frequency,
    bool? isShared,
    HabitStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isStacked,
    String? stackedWithId,
    int? stackOrder,
    String? stackTriggerType,
    int? stackTriggerDelay,
    bool? isTimedHabit,
    int? targetDurationMinutes,
    bool? allowBackgroundTimer,
    String? timerSound,
    bool? vibrateOnComplete,
    String? ambientSound,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      isShared: isShared ?? this.isShared,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isStacked: isStacked ?? this.isStacked,
      stackedWithId: stackedWithId ?? this.stackedWithId,
      stackOrder: stackOrder ?? this.stackOrder,
      stackTriggerType: stackTriggerType ?? this.stackTriggerType,
      stackTriggerDelay: stackTriggerDelay ?? this.stackTriggerDelay,
      isTimedHabit: isTimedHabit ?? this.isTimedHabit,
      targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
      allowBackgroundTimer: allowBackgroundTimer ?? this.allowBackgroundTimer,
      timerSound: timerSound ?? this.timerSound,
      vibrateOnComplete: vibrateOnComplete ?? this.vibrateOnComplete,
      ambientSound: ambientSound ?? this.ambientSound,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        category,
        icon,
        color,
        frequency,
        isShared,
        status,
        createdAt,
        updatedAt,
        isStacked,
        stackedWithId,
        stackOrder,
        stackTriggerType,
        stackTriggerDelay,
        isTimedHabit,
        targetDurationMinutes,
        allowBackgroundTimer,
        timerSound,
        vibrateOnComplete,
        ambientSound,
      ];
}

/// Habit frequency configuration.
class HabitFrequency extends Equatable {
  const HabitFrequency({
    required this.type,
    required this.config,
  });

  /// Create daily frequency (every day).
  factory HabitFrequency.daily() {
    return const HabitFrequency(
      type: FrequencyType.daily,
      config: {'everyDay': true},
    );
  }

  /// Create daily frequency (specific days).
  factory HabitFrequency.dailySpecific(List<String> days) {
    return HabitFrequency(
      type: FrequencyType.daily,
      config: {'specificDays': days},
    );
  }

  /// Create weekly frequency.
  factory HabitFrequency.weekly(int timesPerWeek) {
    return HabitFrequency(
      type: FrequencyType.weekly,
      config: {'timesPerWeek': timesPerWeek},
    );
  }

  /// Create flexible frequency.
  factory HabitFrequency.flexible({
    required int minPerWeek,
    required int targetPerWeek,
  }) {
    return HabitFrequency(
      type: FrequencyType.flexible,
      config: {
        'minPerWeek': minPerWeek,
        'targetPerWeek': targetPerWeek,
      },
    );
  }

  /// Create custom frequency (X times in Y days).
  /// Example: 3 times in 7 days, 2 times in 10 days
  factory HabitFrequency.custom({
    required int timesInPeriod, // Y kere
    required int periodDays,    // X günde
  }) {
    return HabitFrequency(
      type: FrequencyType.custom,
      config: {
        'timesInPeriod': timesInPeriod,
        'periodDays': periodDays,
      },
    );
  }

  final FrequencyType type;
  final Map<String, dynamic> config;

  /// Check if this habit should be active today
  bool isScheduledForToday(DateTime date) {
    switch (type) {
      case FrequencyType.daily:
        // Check if everyDay or if today is in specificDays
        if (config['everyDay'] == true) {
          return true;
        }
        final specificDays = config['specificDays'] as List<dynamic>?;
        if (specificDays != null) {
          final weekdayNames = [
            '',
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday',
          ];
          final todayName = weekdayNames[date.weekday];
          return specificDays.contains(todayName);
        }
        return true;

      case FrequencyType.weekly:
      case FrequencyType.flexible:
      case FrequencyType.custom:
        // These types are always "scheduled" - completion is tracked differently
        return true;

      case FrequencyType.monthly:
        // Monthly habits are always shown (for now)
        return true;
    }
  }

  @override
  List<Object?> get props => [type, config];
}

/// Frequency type enum.
enum FrequencyType {
  daily,
  weekly,
  monthly,
  flexible,
  custom, // X günde Y kere
}

/// Habit status enum.
enum HabitStatus {
  active,
  paused,
  archived,
}

/// Extension to convert string to FrequencyType.
extension FrequencyTypeExtension on String {
  FrequencyType toFrequencyType() {
    switch (this) {
      case 'daily':
        return FrequencyType.daily;
      case 'weekly':
        return FrequencyType.weekly;
      case 'monthly':
        return FrequencyType.monthly;
      case 'flexible':
        return FrequencyType.flexible;
      case 'custom':
        return FrequencyType.custom;
      default:
        return FrequencyType.daily;
    }
  }
}

/// Extension to convert string to HabitStatus.
extension HabitStatusExtension on String {
  HabitStatus toHabitStatus() {
    switch (this) {
      case 'active':
        return HabitStatus.active;
      case 'paused':
        return HabitStatus.paused;
      case 'archived':
        return HabitStatus.archived;
      default:
        return HabitStatus.active;
    }
  }
}

/// Extension to convert enum to string.
extension FrequencyTypeString on FrequencyType {
  String get value {
    switch (this) {
      case FrequencyType.daily:
        return 'daily';
      case FrequencyType.weekly:
        return 'weekly';
      case FrequencyType.monthly:
        return 'monthly';
      case FrequencyType.flexible:
        return 'flexible';
      case FrequencyType.custom:
        return 'custom';
    }
  }
}

/// Extension to convert enum to string.
extension HabitStatusString on HabitStatus {
  String get value {
    switch (this) {
      case HabitStatus.active:
        return 'active';
      case HabitStatus.paused:
        return 'paused';
      case HabitStatus.archived:
        return 'archived';
    }
  }
}
