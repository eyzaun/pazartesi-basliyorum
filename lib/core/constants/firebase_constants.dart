/// Firebase collection and field name constants.
/// Centralizes all Firebase-related string constants to avoid typos.
class FirebaseConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String habitLogsCollection = 'habit_logs';
  static const String sharedHabitsCollection = 'shared_habits';
  static const String notificationsCollection = 'notifications';
  
  // User fields
  static const String userIdField = 'userId';
  static const String emailField = 'email';
  static const String usernameField = 'username';
  static const String displayNameField = 'displayName';
  static const String photoURLField = 'photoURL';
  static const String createdAtField = 'createdAt';
  static const String statsField = 'stats';
  static const String privacyField = 'privacy';
  
  // Habit fields
  static const String habitIdField = 'habitId';
  static const String ownerIdField = 'ownerId';
  static const String nameField = 'name';
  static const String descriptionField = 'description';
  static const String categoryField = 'category';
  static const String iconField = 'icon';
  static const String colorField = 'color';
  static const String frequencyField = 'frequency';
  static const String isSharedField = 'isShared';
  static const String sharedWithField = 'sharedWith';
  static const String statusField = 'status';
  static const String updatedAtField = 'updatedAt';
  
  // Habit log fields
  static const String logIdField = 'logId';
  static const String dateField = 'date';
  static const String completedField = 'completed';
  static const String skippedField = 'skipped';
  static const String skipReasonField = 'skipReason';
  static const String qualityField = 'quality';
  static const String noteField = 'note';
  static const String moodField = 'mood';
  
  // Frequency fields
  static const String frequencyTypeField = 'type';
  static const String frequencyConfigField = 'config';
  
  // Stats fields
  static const String totalCompletionsField = 'totalCompletions';
  static const String currentStreakField = 'currentStreak';
  static const String longestStreakField = 'longestStreak';
  
  // Privacy fields
  static const String profileVisibilityField = 'profileVisibility';
  static const String allowFriendRequestsField = 'allowFriendRequests';
  
  // Status values
  static const String activeStatus = 'active';
  static const String pausedStatus = 'paused';
  static const String archivedStatus = 'archived';
  
  // Privacy values
  static const String publicVisibility = 'public';
  static const String privateVisibility = 'private';
  
  // Quality values
  static const String minimalQuality = 'minimal';
  static const String goodQuality = 'good';
  static const String excellentQuality = 'excellent';
}