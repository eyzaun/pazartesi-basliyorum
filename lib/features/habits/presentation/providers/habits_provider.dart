import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/time_override.dart';
import '../../../../shared/models/result.dart';
import '../../../achievements/domain/entities/achievement.dart';
import '../../../achievements/presentation/providers/achievement_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/habit_remote_datasource.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart' as domain;
import '../../domain/entities/habit_log.dart' as domain;
import '../../domain/entities/streak_recovery.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habit_score_service.dart';

// ============================================================================
// Dependencies
// ============================================================================

/// Provider for UUID generator.
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// ============================================================================
// Data Sources
// ============================================================================

/// Provider for habit remote data source.
final habitRemoteDataSourceProvider = Provider<HabitRemoteDataSource>((ref) {
  return HabitRemoteDataSource(ref.watch(firestoreProvider));
});

// ============================================================================
// Repository
// ============================================================================

/// Provider for habit repository.
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(
    remoteDataSource: ref.watch(habitRemoteDataSourceProvider),
    uuid: ref.watch(uuidProvider),
  );
});

// ============================================================================
// State Providers
// ============================================================================

/// Date refresh notifier - increment this to force refresh of date-dependent providers
final dateRefreshProvider = StateProvider<int>((ref) => 0);

/// Provider for habits list.
final habitsProvider =
    FutureProvider.family<List<domain.Habit>, String>((ref, userId) async {
  // Watch date refresh to rebuild when time override changes
  ref.watch(dateRefreshProvider);
  
  final result =
      await ref.watch(habitRepositoryProvider).getActiveHabits(userId);
  return result is Success<List<domain.Habit>> ? result.data : [];
});

/// Provider for a single habit.
final habitProvider =
    FutureProvider.family<domain.Habit?, String>((ref, habitId) async {
  final result = await ref.watch(habitRepositoryProvider).getHabitById(habitId);
  return result is Success<domain.Habit> ? result.data : null;
});

/// Provider for today's logs.
final todayLogsProvider =
    StreamProvider.family<List<domain.HabitLog>, String>((ref, userId) {
  // Watch date refresh to rebuild stream when time override changes
  ref.watch(dateRefreshProvider);
  
  return ref.watch(habitRepositoryProvider).watchTodayLogs(userId);
});

/// Time-weighted score provider for custom frequency habits.
final habitScoreProvider =
    FutureProvider.family<HabitScore?, String>((ref, habitId) async {
  // Watch date refresh to rebuild when time override changes
  ref.watch(dateRefreshProvider);
  
  // Get habit from habitProvider
  final habitAsync = ref.watch(habitProvider(habitId));
  final habit = habitAsync.value;
  
  if (habit == null || habit.frequency.type != domain.FrequencyType.custom) {
    return null;
  }

  final config = habit.frequency.config;
  final periodDays = config['periodDays'] as int? ?? 0;
  final timesInPeriod = config['timesInPeriod'] as int? ?? 1;

  if (periodDays <= 0 || timesInPeriod <= 0) {
    return null;
  }

  final repository = ref.watch(habitRepositoryProvider);
  final logsResult = await repository.getLogsForHabit(habit.id);
  if (logsResult is! Success<List<domain.HabitLog>>) {
    return null;
  }

  final calculator = HabitScoreCalculator();
  return calculator.computeScore(
    habit: habit,
    logs: logsResult.data,
  );
});

/// Provider for habit statistics.
final habitStatisticsProvider =
    FutureProvider.family<domain.HabitStatistics, String>(
  (ref, habitId) async {
    final result =
        await ref.watch(habitRepositoryProvider).getHabitStatistics(habitId);
    return result is Success<domain.HabitStatistics>
        ? result.data
        : domain.HabitStatistics(
            habitId: habitId,
            totalCompletions: 0,
            currentStreak: 0,
            longestStreak: 0,
            completionRate: 0,
          );
  },
);

/// Provider to check streak recovery eligibility.
final streakRecoveryEligibilityProvider = FutureProvider.family<
    StreakRecoveryEligibility,
    ({String habitId, String userId, DateTime missedDate})>(
  (ref, params) async {
    final result =
        await ref.watch(habitRepositoryProvider).checkRecoveryEligibility(
              habitId: params.habitId,
              userId: params.userId,
              missedDate: params.missedDate,
            );

    return result is Success<StreakRecoveryEligibility>
        ? result.data
        : const StreakRecoveryEligibility(
            canRecover: false,
            reason: 'Kontrol edilemedi',
          );
  },
);

// ============================================================================
// Action Providers (State Notifiers)
// ============================================================================

/// State for habit actions.
class HabitActionState {
  const HabitActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.lastUnlockedAchievements = const [],
  });
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final List<Achievement> lastUnlockedAchievements;

  HabitActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<Achievement>? lastUnlockedAchievements,
  }) {
    return HabitActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      lastUnlockedAchievements:
          lastUnlockedAchievements ?? this.lastUnlockedAchievements,
    );
  }
}

/// Notifier for habit actions.
class HabitActionNotifier extends StateNotifier<HabitActionState> {
  HabitActionNotifier(this._repository, this._ref)
      : super(const HabitActionState());
  final HabitRepository _repository;
  final Ref _ref;

  /// Create a new habit.
  Future<bool> createHabit(domain.Habit habit) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.createHabit(habit);

    if (result is Success<domain.Habit>) {
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Alışkanlık oluşturuldu',
      );
      return true;
    } else if (result is Failure<domain.Habit>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
      return false;
    }

    return false;
  }

  /// Update a habit.
  Future<bool> updateHabit(domain.Habit habit) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.updateHabit(habit);

    if (result is Success<domain.Habit>) {
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Alışkanlık güncellendi',
      );
      return true;
    } else if (result is Failure<domain.Habit>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
      return false;
    }

    return false;
  }

  /// Delete a habit.
  Future<bool> deleteHabit(String habitId) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deleteHabit(habitId);

    if (result is Success<void>) {
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Alışkanlık silindi',
      );
      return true;
    } else if (result is Failure<void>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
      return false;
    }

    return false;
  }

  /// Complete a habit.
  Future<bool> completeHabit({
    required String habitId,
    required String userId,
    domain.LogQuality? quality,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true);

    // First, get current statistics to check for first completion
    final statsResult = await _repository.getHabitStatistics(habitId);
    final isFirstCompletion = statsResult is Success<domain.HabitStatistics> &&
        statsResult.data.totalCompletions == 0;

    final result = await _repository.completeHabit(
      habitId: habitId,
      userId: userId,
      quality: quality,
      note: note,
    );

    if (result is Success<domain.HabitLog>) {
      // Get updated statistics after completion
      final updatedStatsResult = await _repository.getHabitStatistics(habitId);

      if (updatedStatsResult is Success<domain.HabitStatistics>) {
        final stats = updatedStatsResult.data;

        // Check for achievements
        final achievementService = _ref.read(achievementServiceProvider);
        final newAchievements =
            await achievementService.checkAndUnlockAchievements(
          userId: userId,
          totalCompletions: stats.totalCompletions,
          currentStreak: stats.currentStreak,
          longestStreak: stats.longestStreak,
          isFirstCompletion: isFirstCompletion,
          completionTime: TimeOverride.now(),
          habitId: habitId,
        );

        state = state.copyWith(
          isLoading: false,
          successMessage: 'Tamamlandı! 🎉',
          lastUnlockedAchievements: newAchievements,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Tamamlandı! 🎉',
        );
      }

      return true;
    } else if (result is Failure<domain.HabitLog>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
      return false;
    }

    return false;
  }

  /// Skip a habit.
  Future<bool> skipHabit({
    required String habitId,
    required String userId,
    required String skipReason,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.skipHabit(
      habitId: habitId,
      userId: userId,
      skipReason: skipReason,
      note: note,
    );

    if (result is Success<domain.HabitLog>) {
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Atlandı',
      );
      return true;
    } else if (result is Failure<domain.HabitLog>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
      return false;
    }

    return false;
  }

  /// Use streak recovery to restore a broken streak.
  Future<bool> useStreakRecovery({
    required String habitId,
    required String userId,
    required DateTime missedDate,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.useStreakRecovery(
      habitId: habitId,
      userId: userId,
      missedDate: missedDate,
    );

    if (result is Success<void>) {
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Seri kurtarıldı! 🔥',
      );
      return true;
    } else if (result is Failure<void>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
      return false;
    }

    return false;
  }

  /// Sync with Firebase.
  Future<void> syncWithFirebase() async {
    await _repository.syncWithFirebase();
  }

  /// Clear messages.
  void clearMessages() {
    state = state.copyWith();
  }
}

/// Provider for habit actions.
final habitActionProvider =
    StateNotifierProvider<HabitActionNotifier, HabitActionState>((ref) {
  return HabitActionNotifier(ref.watch(habitRepositoryProvider), ref);
});

// ============================================================================
// Helper extension for Result handling
// ============================================================================

/// Extension to handle Result types.
extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }

  String? get errorOrNull {
    if (this is Failure<T>) {
      return (this as Failure<T>).message;
    }
    return null;
  }
}
