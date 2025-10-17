import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit_activity.dart';

/// Model for HabitActivity with Firestore serialization.
class HabitActivityModel {
  const HabitActivityModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.habitId,
    required this.habitName,
    required this.habitIcon,
    required this.habitColor,
    required this.completedAt,
    required this.createdAt,
    this.habitDescription,
    this.habitCategory,
    this.habitFrequencyLabel,
    this.habitGoalLabel,
    this.quality,
    this.note,
    this.photoUrl,
    this.timerDuration,
  });

  factory HabitActivityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return HabitActivityModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      username: data['username'] as String,
      habitId: data['habitId'] as String,
      habitName: data['habitName'] as String,
      habitIcon: data['habitIcon'] as String,
      habitColor: data['habitColor'] as int,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      habitDescription: data['habitDescription'] as String?,
      habitCategory: data['habitCategory'] as String?,
      habitFrequencyLabel: data['habitFrequencyLabel'] as String?,
      habitGoalLabel: data['habitGoalLabel'] as String?,
      quality: data['quality'] as String?,
      note: data['note'] as String?,
      photoUrl: data['photoUrl'] as String?,
      timerDuration: data['timerDuration'] as int?,
    );
  }

  final String id;
  final String userId;
  final String username;
  final String habitId;
  final String habitName;
  final String habitIcon;
  final int habitColor;
  final DateTime completedAt;
  final DateTime createdAt;
  final String? habitDescription;
  final String? habitCategory;
  final String? habitFrequencyLabel;
  final String? habitGoalLabel;
  final String? quality;
  final String? note;
  final String? photoUrl;
  final int? timerDuration;

  Map<String, dynamic> toFirestore() {
    final data = {
      'userId': userId,
      'username': username,
      'habitId': habitId,
      'habitName': habitName,
      'habitIcon': habitIcon,
      'habitColor': habitColor,
      'completedAt': Timestamp.fromDate(completedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      if (quality != null) 'quality': quality,
      if (note != null) 'note': note,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (timerDuration != null) 'timerDuration': timerDuration,
    };
    if (habitDescription != null && habitDescription!.isNotEmpty) {
      data['habitDescription'] = habitDescription;
    }
    if (habitCategory != null && habitCategory!.isNotEmpty) {
      data['habitCategory'] = habitCategory;
    }
    if (habitFrequencyLabel != null && habitFrequencyLabel!.isNotEmpty) {
      data['habitFrequencyLabel'] = habitFrequencyLabel;
    }
    if (habitGoalLabel != null && habitGoalLabel!.isNotEmpty) {
      data['habitGoalLabel'] = habitGoalLabel;
    }
    return data;
  }

  HabitActivity toEntity() {
    return HabitActivity(
      id: id,
      userId: userId,
      username: username,
      habitId: habitId,
      habitName: habitName,
      habitIcon: habitIcon,
      habitColor: habitColor,
      completedAt: completedAt,
      createdAt: createdAt,
      habitDescription: habitDescription,
      habitCategory: habitCategory,
      habitFrequencyLabel: habitFrequencyLabel,
      habitGoalLabel: habitGoalLabel,
      quality: quality,
      note: note,
      photoUrl: photoUrl,
      timerDuration: timerDuration,
    );
  }
}
