import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/shared_habit.dart';

/// Data model for SharedHabit.
class SharedHabitModel extends SharedHabit {
  const SharedHabitModel({
    required super.id,
    required super.habitId,
    required super.habitName,
    required super.ownerId,
    required super.ownerUsername,
    required super.sharedWithId,
    required super.sharedWithUsername,
    required super.createdAt,
    super.habitDescription,
    super.habitIcon,
    super.habitColor,
    super.canEdit,
  });

  /// Create from Firestore document.
  factory SharedHabitModel.fromFirestore(Map<String, dynamic> json) {
    return SharedHabitModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      habitDescription: json['habitDescription'] as String?,
      habitIcon: json['habitIcon'] as String?,
      habitColor: json['habitColor'] as int?,
      ownerId: json['ownerId'] as String,
      ownerUsername: json['ownerUsername'] as String,
      sharedWithId: json['sharedWithId'] as String,
      sharedWithUsername: json['sharedWithUsername'] as String,
      canEdit: json['canEdit'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Create from DocumentSnapshot.
  factory SharedHabitModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharedHabitModel.fromFirestore({...data, 'id': doc.id});
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'habitId': habitId,
      'habitName': habitName,
      'habitDescription': habitDescription,
      'habitIcon': habitIcon,
      'habitColor': habitColor,
      'ownerId': ownerId,
      'ownerUsername': ownerUsername,
      'sharedWithId': sharedWithId,
      'sharedWithUsername': sharedWithUsername,
      'canEdit': canEdit ?? false,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to entity.
  SharedHabit toEntity() => this;
}
