import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit.dart' as domain;

/// Data model for Habit that extends the domain entity.
class HabitModel extends domain.Habit {
  const HabitModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.category,
    required super.icon,
    required super.color,
    required super.frequency,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.isShared,
    super.status,
    // Part 4 fields
    super.isStacked,
    super.stackedWithId,
    super.stackOrder,
    super.stackTriggerType,
    super.stackTriggerDelay,
    super.isTimedHabit,
    super.targetDurationMinutes,
    super.allowBackgroundTimer,
    super.timerSound,
    super.vibrateOnComplete,
    super.ambientSound,
  });

  /// Create HabitModel from domain entity.
  factory HabitModel.fromEntity(domain.Habit habit) {
    return HabitModel(
      id: habit.id,
      userId: habit.userId,
      name: habit.name,
      description: habit.description,
      category: habit.category,
      icon: habit.icon,
      color: habit.color,
      frequency: habit.frequency,
      isShared: habit.isShared,
      status: habit.status,
      createdAt: habit.createdAt,
      updatedAt: habit.updatedAt,
      isStacked: habit.isStacked,
      stackedWithId: habit.stackedWithId,
      stackOrder: habit.stackOrder,
      stackTriggerType: habit.stackTriggerType,
      stackTriggerDelay: habit.stackTriggerDelay,
      isTimedHabit: habit.isTimedHabit,
      targetDurationMinutes: habit.targetDurationMinutes,
      allowBackgroundTimer: habit.allowBackgroundTimer,
      timerSound: habit.timerSound,
      vibrateOnComplete: habit.vibrateOnComplete,
      ambientSound: habit.ambientSound,
    );
  }

  /// Create HabitModel from Firestore document.
  factory HabitModel.fromFirestore(Map<String, dynamic> json) {
    final frequencyData = json['frequency'] as Map<String, dynamic>;

    return HabitModel(
      id: json['habitId'] as String,
      userId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      frequency: domain.HabitFrequency(
        type: (frequencyData['type'] as String).toFrequencyType(),
        config: frequencyData['config'] as Map<String, dynamic>,
      ),
      isShared: json['isShared'] as bool? ?? false,
      status: (json['status'] as String).toHabitStatus(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      // Part 4 fields
      isStacked: json['isStacked'] as bool? ?? false,
      stackedWithId: json['stackedWithId'] as String?,
      stackOrder: json['stackOrder'] as int?,
      stackTriggerType: json['stackTriggerType'] as String?,
      stackTriggerDelay: json['stackTriggerDelay'] as int?,
      isTimedHabit: json['isTimedHabit'] as bool? ?? false,
      targetDurationMinutes: json['targetDurationMinutes'] as int?,
      allowBackgroundTimer: json['allowBackgroundTimer'] as bool? ?? true,
      timerSound: json['timerSound'] as String?,
      vibrateOnComplete: json['vibrateOnComplete'] as bool? ?? true,
      ambientSound: json['ambientSound'] as String?,
    );
  }

  /// Convert HabitModel to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'habitId': id,
      'ownerId': userId,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'color': color,
      'frequency': {
        'type': frequency.type.value,
        'config': frequency.config,
      },
      'isShared': isShared,
      'sharedWith': <String>[],
      'status': status.value,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // Part 4 fields
      'isStacked': isStacked,
      if (stackedWithId != null) 'stackedWithId': stackedWithId,
      if (stackOrder != null) 'stackOrder': stackOrder,
      if (stackTriggerType != null) 'stackTriggerType': stackTriggerType,
      if (stackTriggerDelay != null) 'stackTriggerDelay': stackTriggerDelay,
      'isTimedHabit': isTimedHabit,
      if (targetDurationMinutes != null) 'targetDurationMinutes': targetDurationMinutes,
      'allowBackgroundTimer': allowBackgroundTimer,
      if (timerSound != null) 'timerSound': timerSound,
      'vibrateOnComplete': vibrateOnComplete,
      if (ambientSound != null) 'ambientSound': ambientSound,
    };
  }

  /// Convert to domain entity.
  domain.Habit toEntity() {
    return domain.Habit(
      id: id,
      userId: userId,
      name: name,
      description: description,
      category: category,
      icon: icon,
      color: color,
      frequency: frequency,
      isShared: isShared,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isStacked: isStacked,
      stackedWithId: stackedWithId,
      stackOrder: stackOrder,
      stackTriggerType: stackTriggerType,
      stackTriggerDelay: stackTriggerDelay,
      isTimedHabit: isTimedHabit,
      targetDurationMinutes: targetDurationMinutes,
      allowBackgroundTimer: allowBackgroundTimer,
      timerSound: timerSound,
      vibrateOnComplete: vibrateOnComplete,
      ambientSound: ambientSound,
    );
  }

  @override
  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? icon,
    String? color,
    domain.HabitFrequency? frequency,
    bool? isShared,
    domain.HabitStatus? status,
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
    return HabitModel(
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
}
