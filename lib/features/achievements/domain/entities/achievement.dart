import 'package:equatable/equatable.dart';

/// Achievement badge earned by user.
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.userId,
    required this.badgeType,
    required this.unlockedAt,
    this.habitId,
    this.metadata,
  });

  final String id;
  final String userId;
  final BadgeType badgeType;
  final DateTime unlockedAt;
  final String? habitId; // For habit-specific achievements
  final Map<String, dynamic>? metadata; // Extra data (streak count, etc)

  @override
  List<Object?> get props =>
      [id, userId, badgeType, unlockedAt, habitId, metadata];
}

/// Badge types with their display information.
enum BadgeType {
  firstStep, // Complete first habit
  weekWarrior, // 7-day streak
  monthMaster, // 30-day streak
  perfectWeek, // Complete all habits for 7 days
  streakKing, // 100-day streak
  centurion, // 100 total completions
  earlyBird, // Complete morning habit before 8am
  nightOwl, // Complete evening habit after 8pm
  consistent, // 14-day streak
  dedicated, // 50-day streak
}

/// Extension for badge display information.
extension BadgeTypeExtension on BadgeType {
  String get title {
    switch (this) {
      case BadgeType.firstStep:
        return 'İlk Adım';
      case BadgeType.weekWarrior:
        return 'Hafta Savaşçısı';
      case BadgeType.monthMaster:
        return 'Ay Ustası';
      case BadgeType.perfectWeek:
        return 'Mükemmel Hafta';
      case BadgeType.streakKing:
        return 'Seri Kralı';
      case BadgeType.centurion:
        return 'Yüzbaşı';
      case BadgeType.earlyBird:
        return 'Erken Kuş';
      case BadgeType.nightOwl:
        return 'Gece Baykuşu';
      case BadgeType.consistent:
        return 'Tutarlı';
      case BadgeType.dedicated:
        return 'Kararlı';
    }
  }

  String get description {
    switch (this) {
      case BadgeType.firstStep:
        return 'İlk alışkanlığını tamamladın! 🎉';
      case BadgeType.weekWarrior:
        return '7 günlük seri oluşturdun';
      case BadgeType.monthMaster:
        return '30 günlük seri oluşturdun';
      case BadgeType.perfectWeek:
        return 'Bir hafta boyunca tüm alışkanlıkları tamamladın';
      case BadgeType.streakKing:
        return '100 günlük seri! İnanılmaz!';
      case BadgeType.centurion:
        return '100 alışkanlık tamamladın';
      case BadgeType.earlyBird:
        return 'Sabah 8\'den önce tamamladın';
      case BadgeType.nightOwl:
        return 'Akşam 8\'den sonra tamamladın';
      case BadgeType.consistent:
        return '14 günlük seri oluşturdun';
      case BadgeType.dedicated:
        return '50 günlük seri oluşturdun';
    }
  }

  String get icon {
    switch (this) {
      case BadgeType.firstStep:
        return '🎯';
      case BadgeType.weekWarrior:
        return '⚔️';
      case BadgeType.monthMaster:
        return '👑';
      case BadgeType.perfectWeek:
        return '💯';
      case BadgeType.streakKing:
        return '🔥';
      case BadgeType.centurion:
        return '🏆';
      case BadgeType.earlyBird:
        return '🌅';
      case BadgeType.nightOwl:
        return '🌙';
      case BadgeType.consistent:
        return '⭐';
      case BadgeType.dedicated:
        return '💪';
    }
  }

  String get value {
    return name;
  }

  static BadgeType fromString(String value) {
    return BadgeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BadgeType.firstStep,
    );
  }
}
