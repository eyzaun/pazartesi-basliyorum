class AppConstants {
  // App Information
  static const String appName = 'Pazartesi Başlıyorum';
  static const String packageName = 'com.loncagames.pazartesibasliyorum';
  
  // Limits
  static const int maxHabitsFreeTier = 7;
  static const int maxSharedHabits = 3;
  static const int maxHabitNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Categories with Turkish names
  static const List<String> categories = [
    'Sağlık',
    'Spor',
    'Üretkenlik',
    'Sosyal',
    'Öğrenme',
    'Mali',
    'Kişisel Gelişim',
    'Yaratıcılık',
    'Diğer',
  ];
  
  static const Map<String, String> categoryIcons = {
    'Sağlık': '🏥',
    'Spor': '💪',
    'Üretkenlik': '📈',
    'Sosyal': '👥',
    'Öğrenme': '📚',
    'Mali': '💰',
    'Kişisel Gelişim': '🌱',
    'Yaratıcılık': '🎨',
    'Diğer': '📌',
  };
  
  // Frequency types
  static const String freqDaily = 'daily';
  static const String freqWeekly = 'weekly';
  static const String freqMonthly = 'monthly';
  static const String freqFlexible = 'flexible';
  
  // Quality levels
  static const String qualityMinimal = 'minimal';
  static const String qualityGood = 'good';
  static const String qualityExcellent = 'excellent';
  
  // Skip reasons
  static const List<String> skipReasons = [
    'Meşguldüm',
    'Hasta',
    'Unutdum',
    'Planlı dinlenme',
    'Diğer',
  ];
  
  // Status
  static const String statusActive = 'active';
  static const String statusPaused = 'paused';
  static const String statusArchived = 'archived';
}