import 'package:equatable/equatable.dart';

/// Streak recovery usage record.
/// Tracks when a user uses their weekly streak recovery for a habit.
class StreakRecovery extends Equatable {
  const StreakRecovery({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.recoveredDate,
    required this.usedAt,
  });

  final String id;
  final String habitId;
  final String userId;
  final DateTime recoveredDate; // The date that was recovered
  final DateTime usedAt; // When the recovery was used

  /// Check if this recovery is still within the weekly window.
  bool isWithinWeek(DateTime now) {
    final daysSince = now.difference(usedAt).inDays;
    return daysSince < 7;
  }

  StreakRecovery copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? recoveredDate,
    DateTime? usedAt,
  }) {
    return StreakRecovery(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      recoveredDate: recoveredDate ?? this.recoveredDate,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  @override
  List<Object?> get props => [id, habitId, userId, recoveredDate, usedAt];
}

/// Helper class to check recovery eligibility.
class StreakRecoveryChecker {
  /// Check if recovery is available for a habit.
  ///
  /// Rules:
  /// - Must be within 24 hours of missed day
  /// - Can only be used once per week per habit
  static StreakRecoveryEligibility checkEligibility({
    required DateTime missedDate,
    required List<StreakRecovery> recentRecoveries,
  }) {
    final now = DateTime.now();
    final missedDay =
        DateTime(missedDate.year, missedDate.month, missedDate.day);
    final today = DateTime(now.year, now.month, now.day);

    // Check 24-hour window
    final hoursSinceMissed = today.difference(missedDay).inHours;
    if (hoursSinceMissed > 24) {
      return const StreakRecoveryEligibility(
        canRecover: false,
        reason: '24 saatlik kurtarma penceresi geçti. '
            'Seriyi kurtarmak için 24 saat içinde işlem yapmalısın.',
      );
    }

    // Check weekly usage
    final usedThisWeek = recentRecoveries.any((r) => r.isWithinWeek(now));
    if (usedThisWeek) {
      final lastRecovery = recentRecoveries.first;
      final daysUntilReset = 7 - now.difference(lastRecovery.usedAt).inDays;
      return StreakRecoveryEligibility(
        canRecover: false,
        reason: 'Bu hafta seri kurtarma hakkını kullandın. '
            '$daysUntilReset gün sonra tekrar kullanabilirsin.',
      );
    }

    return const StreakRecoveryEligibility(
      canRecover: true,
      reason: '',
    );
  }
}

/// Result of recovery eligibility check.
class StreakRecoveryEligibility {
  const StreakRecoveryEligibility({
    required this.canRecover,
    required this.reason,
  });

  final bool canRecover;
  final String reason;
}
