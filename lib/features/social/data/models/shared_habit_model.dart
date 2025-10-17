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
    super.habitCategory,
    super.habitFrequencyLabel,
    super.habitGoalLabel,
  });

  /// Create from Firestore document.
  factory SharedHabitModel.fromFirestore(Map<String, dynamic> json) {
    // Handle habitColor which can be String or int
    int? habitColor;
    final colorValue = json['habitColor'];
    if (colorValue != null) {
      if (colorValue is int) {
        habitColor = colorValue;
      } else if (colorValue is String) {
        habitColor = int.tryParse(colorValue);
      }
    }

    return SharedHabitModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      habitDescription: json['habitDescription'] as String?,
      habitIcon: json['habitIcon'] as String?,
      habitColor: habitColor,
      habitCategory: json['habitCategory'] as String?,
      habitFrequencyLabel: json['habitFrequencyLabel'] as String?,
      habitGoalLabel: json['habitGoalLabel'] as String?,
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
    final data = {
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
    if (habitCategory != null) {
      data['habitCategory'] = habitCategory;
    }
    if (habitFrequencyLabel != null) {
      data['habitFrequencyLabel'] = habitFrequencyLabel;
    }
    if (habitGoalLabel != null) {
      data['habitGoalLabel'] = habitGoalLabel;
    }
    return data;
  }

  /// Convert to entity.
  SharedHabit toEntity() => this;
}
