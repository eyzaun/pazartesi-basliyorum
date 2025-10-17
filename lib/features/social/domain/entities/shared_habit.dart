/// Shared habit entity for social features.
class SharedHabit {
  const SharedHabit({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.ownerId,
    required this.ownerUsername,
    required this.sharedWithId,
    required this.sharedWithUsername,
    required this.createdAt,
    this.habitDescription,
    this.habitIcon,
    this.habitColor,
    this.canEdit,
    this.habitCategory,
    this.habitFrequencyLabel,
    this.habitGoalLabel,
  });

  final String id;
  final String habitId;
  final String habitName;
  final String? habitDescription;
  final String? habitIcon;
  final int? habitColor;
  final String? habitCategory;
  final String? habitFrequencyLabel;
  final String? habitGoalLabel;
  final String ownerId;
  final String ownerUsername;
  final String sharedWithId;
  final String sharedWithUsername;
  final bool? canEdit; // Can shared user edit the habit
  final DateTime createdAt;

  SharedHabit copyWith({
    String? id,
    String? habitId,
    String? habitName,
    String? habitDescription,
    String? habitIcon,
    int? habitColor,
    String? habitCategory,
    String? habitFrequencyLabel,
    String? habitGoalLabel,
    String? ownerId,
    String? ownerUsername,
    String? sharedWithId,
    String? sharedWithUsername,
    bool? canEdit,
    DateTime? createdAt,
  }) {
    return SharedHabit(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      habitIcon: habitIcon ?? this.habitIcon,
      habitColor: habitColor ?? this.habitColor,
      habitCategory: habitCategory ?? this.habitCategory,
      habitFrequencyLabel: habitFrequencyLabel ?? this.habitFrequencyLabel,
      habitGoalLabel: habitGoalLabel ?? this.habitGoalLabel,
      ownerId: ownerId ?? this.ownerId,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      sharedWithId: sharedWithId ?? this.sharedWithId,
      sharedWithUsername: sharedWithUsername ?? this.sharedWithUsername,
      canEdit: canEdit ?? this.canEdit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
