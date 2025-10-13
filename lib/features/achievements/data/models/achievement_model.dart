import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/achievement.dart';

/// Firestore model for achievements.
class AchievementModel {

  /// Convert Firestore document to model.
  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AchievementModel(
      id: doc.id,
      userId: data['userId'] as String,
      badgeType: data['badgeType'] as String,
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
      habitId: data['habitId'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create model from domain entity.
  factory AchievementModel.fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      userId: entity.userId,
      badgeType: entity.badgeType.value,
      unlockedAt: entity.unlockedAt,
      habitId: entity.habitId,
      metadata: entity.metadata,
    );
  }
  const AchievementModel({
    required this.id,
    required this.userId,
    required this.badgeType,
    required this.unlockedAt,
    this.habitId,
    this.metadata,
  });

  final String id;
  final String userId;
  final String badgeType;
  final DateTime unlockedAt;
  final String? habitId;
  final Map<String, dynamic>? metadata;

  /// Convert model to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'badgeType': badgeType,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      if (habitId != null) 'habitId': habitId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Convert model to domain entity.
  Achievement toEntity() {
    return Achievement(
      id: id,
      userId: userId,
      badgeType: BadgeTypeExtension.fromString(badgeType),
      unlockedAt: unlockedAt,
      habitId: habitId,
      metadata: metadata,
    );
  }
}
