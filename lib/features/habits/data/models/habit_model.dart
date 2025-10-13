import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit.dart' as domain;

/// Data model for Habit that extends the domain entity.
class HabitModel extends domain.Habit {
  const HabitModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.category, required super.icon, required super.color, required super.frequency, required super.createdAt, required super.updatedAt, super.description,
    super.isShared,
    super.status,
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
    );
  }
}