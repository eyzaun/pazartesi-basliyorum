import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/achievement.dart';
import '../models/achievement_model.dart';

/// Service for managing achievements and badges.
class AchievementService {
  AchievementService(this._firestore, this._uuid);

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  CollectionReference get _achievementsCollection =>
      _firestore.collection('achievements');

  /// Get all achievements for a user.
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final querySnapshot = await _achievementsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('unlockedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AchievementModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch achievements: $e');
    }
  }

  /// Check if user has a specific achievement.
  Future<bool> hasAchievement(String userId, BadgeType badgeType) async {
    try {
      final querySnapshot = await _achievementsCollection
          .where('userId', isEqualTo: userId)
          .where('badgeType', isEqualTo: badgeType.value)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Unlock a new achievement.
  Future<Achievement?> unlockAchievement({
    required String userId,
    required BadgeType badgeType,
    String? habitId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if already unlocked
      final hasIt = await hasAchievement(userId, badgeType);
      if (hasIt) return null;

      final achievement = Achievement(
        id: _uuid.v4(),
        userId: userId,
        badgeType: badgeType,
        unlockedAt: DateTime.now(),
        habitId: habitId,
        metadata: metadata,
      );

      final model = AchievementModel.fromEntity(achievement);
      await _achievementsCollection
          .doc(achievement.id)
          .set(model.toFirestore());

      return achievement;
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  /// Check and unlock achievements based on completion.
  /// Returns list of newly unlocked achievements.
  Future<List<Achievement>> checkAndUnlockAchievements({
    required String userId,
    required int totalCompletions,
    required int currentStreak,
    required int longestStreak,
    required bool isFirstCompletion,
    DateTime? completionTime,
    String? habitId,
  }) async {
    final newAchievements = <Achievement>[];

    try {
      // First Step - First completion ever
      if (isFirstCompletion) {
        final achievement = await unlockAchievement(
          userId: userId,
          badgeType: BadgeType.firstStep,
          habitId: habitId,
        );
        if (achievement != null) newAchievements.add(achievement);
      }

      // Streak-based achievements
      if (currentStreak >= 7) {
        final achievement = await unlockAchievement(
          userId: userId,
          badgeType: BadgeType.weekWarrior,
          habitId: habitId,
          metadata: {'streak': currentStreak},
        );
        if (achievement != null) newAchievements.add(achievement);
      }

      if (currentStreak >= 14) {
        final achievement = await unlockAchievement(
          userId: userId,
          badgeType: BadgeType.consistent,
          habitId: habitId,
          metadata: {'streak': currentStreak},
        );
        if (achievement != null) newAchievements.add(achievement);
      }

      if (currentStreak >= 30) {
        final achievement = await unlockAchievement(
          userId: userId,
          badgeType: BadgeType.monthMaster,
          habitId: habitId,
          metadata: {'streak': currentStreak},
        );
        if (achievement != null) newAchievements.add(achievement);
      }

      if (currentStreak >= 50) {
        final achievement = await unlockAchievement(
          userId: userId,
          badgeType: BadgeType.dedicated,
          habitId: habitId,
          metadata: {'streak': currentStreak},
        );
        if (achievement != null) newAchievements.add(achievement);
      }

      if (longestStreak >= 100) {
        final achievement = await unlockAchievement(
          userId: userId,
          badgeType: BadgeType.streakKing,
          habitId: habitId,
          metadata: {'streak': longestStreak},
        );
        if (achievement != null) newAchievements.add(achievement);
      }

      // Total completions
      if (totalCompletions >= 100) {
        final achievement = await unlockAchievement(
          userId: userId,
          badgeType: BadgeType.centurion,
          metadata: {'completions': totalCompletions},
        );
        if (achievement != null) newAchievements.add(achievement);
      }

      // Time-based achievements
      if (completionTime != null) {
        final hour = completionTime.hour;

        if (hour < 8) {
          final achievement = await unlockAchievement(
            userId: userId,
            badgeType: BadgeType.earlyBird,
            habitId: habitId,
            metadata: {'time': completionTime.toIso8601String()},
          );
          if (achievement != null) newAchievements.add(achievement);
        }

        if (hour >= 20) {
          final achievement = await unlockAchievement(
            userId: userId,
            badgeType: BadgeType.nightOwl,
            habitId: habitId,
            metadata: {'time': completionTime.toIso8601String()},
          );
          if (achievement != null) newAchievements.add(achievement);
        }
      }
    } catch (e) {
      // Fail silently, don't block habit completion
      // ignore: avoid_print
      print('Achievement check failed: $e');
    }

    return newAchievements;
  }

  /// Stream of user achievements for real-time updates.
  Stream<List<Achievement>> watchUserAchievements(String userId) {
    return _achievementsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AchievementModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }
}
