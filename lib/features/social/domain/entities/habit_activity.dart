/// Entity representing a habit completion activity shared with friends.
class HabitActivity {
  const HabitActivity({
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
  final String? quality; // 'poor', 'fair', 'good', 'excellent'
  final String? note;
  final String? photoUrl;
  final int? timerDuration; // in seconds
}
