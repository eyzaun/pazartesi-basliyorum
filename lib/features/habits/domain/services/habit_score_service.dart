import 'dart:math';

import '../../../../core/utils/time_override.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';

class HabitScore {
  const HabitScore({
    required this.totalScore,
    required this.maxScore,
    required this.dailyScores,
  });

  final int totalScore;
  final int maxScore;
  final List<HabitDailyScore> dailyScores;

  double get ratio =>
      maxScore == 0 ? 0 : totalScore.toDouble() / maxScore.toDouble();

  int get percentage => max(0, (ratio * 100).round());
}

class HabitDailyScore {
  const HabitDailyScore({
    required this.date,
    required this.weight,
    required this.status,
    required this.dayType,
  });

  final DateTime date;
  final int weight;
  final HabitScoreStatus status;
  final HabitScoreDayType dayType;
}

enum HabitScoreStatus {
  success,
  missed,
}

enum HabitScoreDayType {
  action,
  rest,
  missed,
}

class HabitScoreCalculator {
  static const int _windowDays = 21;

  HabitScore? computeScore({
    required Habit habit,
    required List<HabitLog> logs,
    DateTime? referenceDate,
  }) {
    if (habit.frequency.type != FrequencyType.custom) {
      return null;
    }

    final config = habit.frequency.config;
    final periodDays = config['periodDays'] as int? ?? 0;
    final timesInPeriod = config['timesInPeriod'] as int? ?? 1;

    if (periodDays <= 0 || timesInPeriod <= 0) {
      return null;
    }

    // Use original scoring logic for all custom frequency habits
    // Adapt the period to account for multiple times per period
    final adjustedPeriod = (periodDays / timesInPeriod).ceil();
    
    final now = referenceDate ?? TimeOverride.now();
    final endDate = DateTime(now.year, now.month, now.day);

    final creationDate = _normalize(habit.createdAt);
    if (!creationDate.isBefore(endDate)) {
      return const HabitScore(
        totalScore: 0,
        maxScore: 0,
        dailyScores: [],
      );
    }

    final evaluationDates = <DateTime>[];
    for (var delta = _windowDays; delta >= 1; delta--) {
      final date = endDate.subtract(Duration(days: delta));
      if (date.isBefore(creationDate)) {
        continue;
      }
      evaluationDates.add(date);
    }

    if (evaluationDates.isEmpty) {
      return const HabitScore(
        totalScore: 0,
        maxScore: 0,
        dailyScores: [],
      );
    }

    final completionDates = logs
        .where((log) => log.completed)
        .map((log) => _normalize(log.date))
        .where((date) => date.isBefore(endDate))
        .toSet()
        .toList()
      ..sort();

    // If there are no completions at all, all days should be missed
    final hasAnyCompletion = completionDates.isNotEmpty;
    // Track the first completion date - only days AFTER this can be "rest"
    final firstCompletionDate = hasAnyCompletion ? completionDates.first : null;

    var completionIndex = 0;

    DateTime cycleStart = creationDate;
    DateTime dueDate = creationDate.add(Duration(days: adjustedPeriod));

    final evaluationStart = evaluationDates.first;

    while (completionIndex < completionDates.length &&
        completionDates[completionIndex].isBefore(evaluationStart)) {
      final actionDate = completionDates[completionIndex];
      while (!actionDate.isBefore(dueDate)) {
        cycleStart = dueDate;
        dueDate = cycleStart.add(Duration(days: adjustedPeriod));
      }
      cycleStart = actionDate;
      dueDate = cycleStart.add(Duration(days: adjustedPeriod));
      completionIndex++;
    }

    while (!dueDate.isAfter(evaluationStart)) {
      cycleStart = dueDate;
      dueDate = cycleStart.add(Duration(days: adjustedPeriod));
    }

    final dailyScores = <HabitDailyScore>[];
    var totalScore = 0;
    // MaxScore is always the sum of weights 1..21 = 231
    const fixedMaxScore = 231; // Sum of 1+2+3+...+21

    for (final date in evaluationDates) {
      final weight = _weightForDate(date, endDate);

      // Process any actions that happened before this date
      while (completionIndex < completionDates.length &&
          completionDates[completionIndex].isBefore(date)) {
        final skippedAction = completionDates[completionIndex];
        while (!skippedAction.isBefore(dueDate)) {
          cycleStart = dueDate;
          dueDate = cycleStart.add(Duration(days: adjustedPeriod));
        }
        cycleStart = skippedAction;
        dueDate = cycleStart.add(Duration(days: adjustedPeriod));
        completionIndex++;
      }

      // If this date has an action, record success
      final hasAction = completionIndex < completionDates.length &&
          completionDates[completionIndex].isAtSameMomentAs(date);

      if (hasAction) {
        totalScore += weight;
        dailyScores.add(HabitDailyScore(
          date: date,
          weight: weight,
          status: HabitScoreStatus.success,
          dayType: HabitScoreDayType.action,
        ));
        cycleStart = date;
        dueDate = cycleStart.add(Duration(days: adjustedPeriod));
        completionIndex++;
        continue;
      }

      // Check if we're before the due date
      // BUT: days BEFORE first completion can never be "rest", they are always "missed"
      if (date.isBefore(dueDate) && 
          hasAnyCompletion && 
          firstCompletionDate != null &&
          !date.isBefore(firstCompletionDate)) {
        // We're before the due date AND we've had at least one completion
        // AND this date is after (or on) the first completion
        // This is a rest day (grace period)
        totalScore += weight;
        dailyScores.add(HabitDailyScore(
          date: date,
          weight: weight,
          status: HabitScoreStatus.success,
          dayType: HabitScoreDayType.rest,
        ));
        continue;
      }
      
      // Either we're at/past the due date OR no completions yet
      // This is a missed day - no points
      // Keep missing every day until an action is taken
      dailyScores.add(HabitDailyScore(
        date: date,
        weight: weight,
        status: HabitScoreStatus.missed,
        dayType: HabitScoreDayType.missed,
      ));
      // Don't update dueDate - we keep missing until next action
    }

    final result = HabitScore(
      totalScore: totalScore,
      maxScore: fixedMaxScore,
      dailyScores: dailyScores,
    );

    // Debug log with detailed breakdown
    print('⏰ Score (${habit.name}): $periodDays days -> $timesInPeriod times (adjusted: $adjustedPeriod days)');
    print('   Evaluation: ${evaluationDates.length} days from ${evaluationDates.first} to ${evaluationDates.last}');
    print('   Score: $totalScore/$fixedMaxScore = ${result.percentage}%');
    print('   Breakdown:');
    var actionDays = 0, restDays = 0, missedDays = 0;
    for (final ds in dailyScores) {
      if (ds.dayType == HabitScoreDayType.action) {
        actionDays++;
      } else if (ds.dayType == HabitScoreDayType.rest) {
        restDays++;
      } else if (ds.dayType == HabitScoreDayType.missed) {
        missedDays++;
      }
    }
    print('   Action: $actionDays days, Rest: $restDays days, Missed: $missedDays days');

    return result;
  }

  DateTime _normalize(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  int _weightForDate(DateTime date, DateTime endDate) {
    final delta = endDate.difference(date).inDays;
    return max(1, 22 - delta);
  }
}
