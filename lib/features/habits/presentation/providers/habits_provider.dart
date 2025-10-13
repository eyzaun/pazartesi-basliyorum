import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/habit_remote_datasource.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart' as domain;
import '../../domain/entities/habit_log.dart' as domain;
import '../../domain/repositories/habit_repository.dart';

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

/// Provider for habits list.
final habitsProvider = FutureProvider.family<List<domain.Habit>, String>((ref, userId) async {
  final result = await ref.watch(habitRepositoryProvider).getActiveHabits(userId);
  return result is Success<List<domain.Habit>> ? result.data : [];
});

/// Provider for a single habit.
final habitProvider = FutureProvider.family<domain.Habit?, String>((ref, habitId) async {
  final result = await ref.watch(habitRepositoryProvider).getHabitById(habitId);
  return result is Success<domain.Habit> ? result.data : null;
});

/// Provider for today's logs.
final todayLogsProvider = FutureProvider.family<List<domain.HabitLog>, String>((ref, userId) async {
  final result = await ref.watch(habitRepositoryProvider).getTodayLogs(userId);
  return result is Success<List<domain.HabitLog>> ? result.data : [];
});

/// Provider for habit statistics.
final habitStatisticsProvider = FutureProvider.family<domain.HabitStatistics, String>(
  (ref, habitId) async {
    final result = await ref.watch(habitRepositoryProvider).getHabitStatistics(habitId);
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

// ============================================================================
// Action Providers (State Notifiers)
// ============================================================================

/// State for habit actions.
class HabitActionState {
  
  const HabitActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
  final bool isLoading;
  final String? error;
  final String? successMessage;
  
  HabitActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return HabitActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notifier for habit actions.
class HabitActionNotifier extends StateNotifier<HabitActionState> {
  
  HabitActionNotifier(this._repository) : super(const HabitActionState());
  final HabitRepository _repository;
  
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
    
    final result = await _repository.completeHabit(
      habitId: habitId,
      userId: userId,
      quality: quality,
      note: note,
    );
    
    if (result is Success<domain.HabitLog>) {
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tamamlandı! 🎉',
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
  
  /// Skip a habit.
  Future<bool> skipHabit({
    required String habitId,
    required String userId,
    required String skipReason,
  }) async {
    state = state.copyWith(isLoading: true);
    
    final result = await _repository.skipHabit(
      habitId: habitId,
      userId: userId,
      skipReason: skipReason,
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
final habitActionProvider = StateNotifierProvider<HabitActionNotifier, HabitActionState>((ref) {
  return HabitActionNotifier(ref.watch(habitRepositoryProvider));
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