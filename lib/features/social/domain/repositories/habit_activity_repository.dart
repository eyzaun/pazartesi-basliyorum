import 'dart:io';

import '../../../../shared/models/result.dart';
import '../entities/habit_activity.dart';

/// Repository for managing habit activity sharing.
abstract class HabitActivityRepository {
  /// Share a habit completion activity with friends
  Future<Result<HabitActivity>> shareActivity({
    required String habitId,
    required String habitName,
    required String habitIcon,
    required int habitColor,
    required DateTime completedAt,
    String? habitDescription,
    String? habitCategory,
    String? habitFrequencyLabel,
    String? habitGoalLabel,
    String? quality,
    String? note,
    File? photo,
    int? timerDuration,
  });

  /// Get activity feed for current user (their friends' activities)
  Future<Result<List<HabitActivity>>> getActivityFeed(String userId);

  /// Get user's own shared activities
  Future<Result<List<HabitActivity>>> getUserActivities(String userId);

  /// Delete a shared activity
  Future<Result<void>> deleteActivity(String activityId);
}
