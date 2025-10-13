import '../../../../shared/models/result.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';
import '../repositories/habit_repository.dart';

// ============================================================================
// Habit CRUD Use Cases
// ============================================================================

/// Use case for creating a new habit.
class CreateHabit {
  
  CreateHabit(this.repository);
  final HabitRepository repository;
  
  Future<Result<Habit>> call(Habit habit) {
    return repository.createHabit(habit);
  }
}

/// Use case for getting all habits.
class GetHabits {
  
  GetHabits(this.repository);
  final HabitRepository repository;
  
  Future<Result<List<Habit>>> call(String userId) {
    return repository.getHabits(userId);
  }
}

/// Use case for getting active habits.
class GetActiveHabits {
  
  GetActiveHabits(this.repository);
  final HabitRepository repository;
  
  Future<Result<List<Habit>>> call(String userId) {
    return repository.getActiveHabits(userId);
  }
}

/// Use case for getting a single habit.
class GetHabitById {
  
  GetHabitById(this.repository);
  final HabitRepository repository;
  
  Future<Result<Habit>> call(String habitId) {
    return repository.getHabitById(habitId);
  }
}

/// Use case for updating a habit.
class UpdateHabit {
  
  UpdateHabit(this.repository);
  final HabitRepository repository;
  
  Future<Result<Habit>> call(Habit habit) {
    return repository.updateHabit(habit);
  }
}

/// Use case for deleting a habit.
class DeleteHabit {
  
  DeleteHabit(this.repository);
  final HabitRepository repository;
  
  Future<Result<void>> call(String habitId) {
    return repository.deleteHabit(habitId);
  }
}

/// Use case for changing habit status.
class ChangeHabitStatus {
  
  ChangeHabitStatus(this.repository);
  final HabitRepository repository;
  
  Future<Result<Habit>> call(String habitId, HabitStatus status) {
    return repository.changeHabitStatus(habitId, status);
  }
}

// ============================================================================
// Habit Log Use Cases
// ============================================================================

/// Use case for completing a habit.
class CompleteHabit {
  
  CompleteHabit(this.repository);
  final HabitRepository repository;
  
  Future<Result<HabitLog>> call({
    required String habitId,
    required String userId,
    LogQuality? quality,
    String? note,
  }) {
    return repository.completeHabit(
      habitId: habitId,
      userId: userId,
      quality: quality,
      note: note,
    );
  }
}

/// Use case for skipping a habit.
class SkipHabit {
  
  SkipHabit(this.repository);
  final HabitRepository repository;
  
  Future<Result<HabitLog>> call({
    required String habitId,
    required String userId,
    required String skipReason,
  }) {
    return repository.skipHabit(
      habitId: habitId,
      userId: userId,
      skipReason: skipReason,
    );
  }
}

/// Use case for undoing a check-in.
class UndoCheckIn {
  
  UndoCheckIn(this.repository);
  final HabitRepository repository;
  
  Future<Result<void>> call(String habitId, String userId) {
    return repository.undoCheckIn(habitId, userId);
  }
}

/// Use case for getting habit logs.
class GetLogsForHabit {
  
  GetLogsForHabit(this.repository);
  final HabitRepository repository;
  
  Future<Result<List<HabitLog>>> call(String habitId) {
    return repository.getLogsForHabit(habitId);
  }
}

/// Use case for getting today's logs.
class GetTodayLogs {
  
  GetTodayLogs(this.repository);
  final HabitRepository repository;
  
  Future<Result<List<HabitLog>>> call(String userId) {
    return repository.getTodayLogs(userId);
  }
}

// ============================================================================
// Statistics Use Cases
// ============================================================================

/// Use case for getting habit statistics.
class GetHabitStatistics {
  
  GetHabitStatistics(this.repository);
  final HabitRepository repository;
  
  Future<Result<HabitStatistics>> call(String habitId) {
    return repository.getHabitStatistics(habitId);
  }
}

/// Use case for getting completion count.
class GetCompletionCount {
  
  GetCompletionCount(this.repository);
  final HabitRepository repository;
  
  Future<Result<int>> call(String habitId) {
    return repository.getCompletionCount(habitId);
  }
}

/// Use case for getting current streak.
class GetCurrentStreak {
  
  GetCurrentStreak(this.repository);
  final HabitRepository repository;
  
  Future<Result<int>> call(String habitId) {
    return repository.getCurrentStreak(habitId);
  }
}

// ============================================================================
// Sync Use Cases
// ============================================================================

/// Use case for syncing with Firebase.
class SyncHabits {
  
  SyncHabits(this.repository);
  final HabitRepository repository;
  
  Future<Result<void>> call() {
    return repository.syncWithFirebase();
  }
}