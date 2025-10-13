import '../../../../shared/models/result.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';

/// Abstract repository defining habit operations.
/// Follows offline-first approach with automatic sync.
abstract class HabitRepository {
  // ========================================================================
  // Habit CRUD Operations
  // ========================================================================
  
  /// Create a new habit.
  Future<Result<Habit>> createHabit(Habit habit);
  
  /// Get all habits for a user.
  Future<Result<List<Habit>>> getHabits(String userId);
  
  /// Get active habits for a user.
  Future<Result<List<Habit>>> getActiveHabits(String userId);
  
  /// Get a single habit by ID.
  Future<Result<Habit>> getHabitById(String habitId);
  
  /// Update an existing habit.
  Future<Result<Habit>> updateHabit(Habit habit);
  
  /// Delete a habit.
  Future<Result<void>> deleteHabit(String habitId);
  
  /// Change habit status (active, paused, archived).
  Future<Result<Habit>> changeHabitStatus(String habitId, HabitStatus status);
  
  // ========================================================================
  // Habit Log Operations
  // ========================================================================
  
  /// Complete a habit for today.
  Future<Result<HabitLog>> completeHabit({
    required String habitId,
    required String userId,
    LogQuality? quality,
    String? note,
  });
  
  /// Skip a habit for today.
  Future<Result<HabitLog>> skipHabit({
    required String habitId,
    required String userId,
    required String skipReason,
  });
  
  /// Undo today's check-in.
  Future<Result<void>> undoCheckIn(String habitId, String userId);
  
  /// Get logs for a habit.
  Future<Result<List<HabitLog>>> getLogsForHabit(String habitId);
  
  /// Get log for a specific date.
  Future<Result<HabitLog?>> getLogForDate(String habitId, DateTime date);
  
  /// Get today's logs for a user.
  Future<Result<List<HabitLog>>> getTodayLogs(String userId);
  
  // ========================================================================
  // Statistics Operations
  // ========================================================================
  
  /// Get statistics for a habit.
  Future<Result<HabitStatistics>> getHabitStatistics(String habitId);
  
  /// Get completion count for a habit.
  Future<Result<int>> getCompletionCount(String habitId);
  
  /// Get current streak for a habit.
  Future<Result<int>> getCurrentStreak(String habitId);
  
  // ========================================================================
  // Sync Operations
  // ========================================================================
  
  /// Sync local changes with Firebase.
  Future<Result<void>> syncWithFirebase();
  
  /// Stream of habits (real-time updates).
  Stream<List<Habit>> watchHabits(String userId);
  
  /// Stream of habit logs (real-time updates).
  Stream<List<HabitLog>> watchTodayLogs(String userId);
}