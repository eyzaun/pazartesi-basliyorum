import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/streak_recovery.dart';

/// Firestore model for streak recovery records.
class StreakRecoveryModel {
  const StreakRecoveryModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.recoveredDate,
    required this.usedAt,
  });

  /// Convert Firestore document to model.
  factory StreakRecoveryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakRecoveryModel(
      id: doc.id,
      habitId: data['habitId'] as String,
      userId: data['userId'] as String,
      recoveredDate: (data['recoveredDate'] as Timestamp).toDate(),
      usedAt: (data['usedAt'] as Timestamp).toDate(),
    );
  }

  /// Create model from domain entity.
  factory StreakRecoveryModel.fromEntity(StreakRecovery entity) {
    return StreakRecoveryModel(
      id: entity.id,
      habitId: entity.habitId,
      userId: entity.userId,
      recoveredDate: entity.recoveredDate,
      usedAt: entity.usedAt,
    );
  }

  final String id;
  final String habitId;
  final String userId;
  final DateTime recoveredDate;
  final DateTime usedAt;

  /// Convert model to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'habitId': habitId,
      'userId': userId,
      'recoveredDate': Timestamp.fromDate(recoveredDate),
      'usedAt': Timestamp.fromDate(usedAt),
    };
  }

  /// Convert model to domain entity.
  StreakRecovery toEntity() {
    return StreakRecovery(
      id: id,
      habitId: habitId,
      userId: userId,
      recoveredDate: recoveredDate,
      usedAt: usedAt,
    );
  }
}
