import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit_log.dart' as domain;

/// Data model for HabitLog that extends the domain entity.
class HabitLogModel extends domain.HabitLog {
  const HabitLogModel({
    required super.id,
    required super.habitId,
    required super.userId,
    required super.date,
    required super.completed,
    required super.createdAt,
    super.skipped,
    super.skipReason,
    super.quality,
    super.note,
    super.mood,
    super.durationSeconds, // Part 4
  });

  /// Create HabitLogModel from domain entity.
  factory HabitLogModel.fromEntity(domain.HabitLog log) {
    return HabitLogModel(
      id: log.id,
      habitId: log.habitId,
      userId: log.userId,
      date: log.date,
      completed: log.completed,
      skipped: log.skipped,
      skipReason: log.skipReason,
      quality: log.quality,
      note: log.note,
      mood: log.mood,
      durationSeconds: log.durationSeconds,
      createdAt: log.createdAt,
    );
  }

  /// Create HabitLogModel from Firestore document.
  factory HabitLogModel.fromFirestore(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['logId'] as String,
      habitId: json['habitId'] as String,
      userId: json['userId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      completed: json['completed'] as bool,
      skipped: json['skipped'] as bool? ?? false,
      skipReason: json['skipReason'] as String?,
      quality: (json['quality'] as String?)?.toLogQuality(),
      note: json['note'] as String?,
      mood: json['mood'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert HabitLogModel to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'logId': id,
      'habitId': habitId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'completed': completed,
      'skipped': skipped,
      'skipReason': skipReason,
      'quality': quality?.value,
      'note': note,
      'mood': mood,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to domain entity.
  domain.HabitLog toEntity() {
    return domain.HabitLog(
      id: id,
      habitId: habitId,
      userId: userId,
      date: date,
      completed: completed,
      skipped: skipped,
      skipReason: skipReason,
      quality: quality,
      note: note,
      mood: mood,
      durationSeconds: durationSeconds,
      createdAt: createdAt,
    );
  }

  @override
  HabitLogModel copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? date,
    bool? completed,
    bool? skipped,
    String? skipReason,
    domain.LogQuality? quality,
    String? note,
    String? mood,
    int? durationSeconds,
    DateTime? createdAt,
  }) {
    return HabitLogModel(
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
}
