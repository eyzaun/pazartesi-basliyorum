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
  final FrequencyType type;
  final Map<String, dynamic> config;

  @override
  List<Object?> get props => [type, config];
}

/// Frequency type enum.
enum FrequencyType {
  daily,
  weekly,
  monthly,
  flexible,
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
