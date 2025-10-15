import '../entities/timer_session.dart';

/// Repository interface for timer sessions.
abstract class TimerSessionRepository {
  /// Create a new timer session
  Future<void> createSession(TimerSession session);

  /// Update an existing timer session
  Future<void> updateSession(TimerSession session);

  /// Get a single timer session by ID
  Future<TimerSession?> getSession(String sessionId);

  /// Get all timer sessions for a habit
  Future<List<TimerSession>> getSessionsForHabit(String habitId);

  /// Get timer sessions for a habit within a date range
  Future<List<TimerSession>> getSessionsInRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get total time spent on a habit (in seconds)
  Future<int> getTotalTimeForHabit(String habitId);

  /// Get today's sessions for a habit
  Future<List<TimerSession>> getTodaySessions(String habitId);

  /// Delete a timer session
  Future<void> deleteSession(String sessionId);

  /// Watch timer sessions for a habit (real-time updates)
  Stream<List<TimerSession>> watchSessionsForHabit(String habitId);
}
