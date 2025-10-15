import '../../../../core/services/sync_service.dart';
import '../../../../shared/models/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/streak_recovery.dart';
import '../../domain/repositories/habit_repository.dart';

/// Offline-first wrapper for HabitRepository
/// This decorator adds sync queue functionality to any HabitRepository
class OfflineFirstHabitRepository implements HabitRepository {

  OfflineFirstHabitRepository(
    this._baseRepository,
    this._syncService,
  );
  final HabitRepository _baseRepository;
  final SyncService _syncService;

  @override
  Future<Result<Habit>> createHabit(Habit habit) async {
    // First, save locally via base repository
    final result = await _baseRepository.createHabit(habit);

    // Queue for sync if successful
    if (result is Success<Habit>) {
      await _syncService.queueOperation(
        operation: 'create',
        entityType: 'habit',
        entityId: habit.id,
        data: _habitToMap(habit),
      );
    }

    return result;
  }

  @override
  Future<Result<Habit>> updateHabit(Habit habit) async {
    // First, update locally
    final result = await _baseRepository.updateHabit(habit);

    // Queue for sync if successful
    if (result is Success<Habit>) {
      await _syncService.queueOperation(
        operation: 'update',
        entityType: 'habit',
        entityId: habit.id,
        data: _habitToMap(habit),
      );
    }

    return result;
  }

  @override
  Future<Result<void>> deleteHabit(String habitId) async {
    // First, delete locally
    final result = await _baseRepository.deleteHabit(habitId);

    // Queue for sync if successful
    if (result is Success<void>) {
      await _syncService.queueOperation(
        operation: 'delete',
        entityType: 'habit',
        entityId: habitId,
        data: {'id': habitId},
      );
    }

    return result;
  }

  @override
  Future<Result<HabitLog>> completeHabit({
    required String habitId,
    required String userId,
    LogQuality? quality,
    String? note,
  }) async {
    // Complete locally
    final result = await _baseRepository.completeHabit(
      habitId: habitId,
      userId: userId,
      quality: quality,
      note: note,
    );

    // Queue for sync if successful
    if (result is Success<HabitLog>) {
      final log = result.data;
      await _syncService.queueOperation(
        operation: 'create',
        entityType: 'log',
        entityId: log.id,
        data: _logToMap(log),
      );
    }

    return result;
  }

  @override
  Future<Result<HabitLog>> skipHabit({
    required String habitId,
    required String userId,
    required String skipReason,
    String? note,
  }) async {
    // Skip locally
    final result = await _baseRepository.skipHabit(
      habitId: habitId,
      userId: userId,
      skipReason: skipReason,
      note: note,
    );

    // Queue for sync if successful
    if (result is Success<HabitLog>) {
      final log = result.data;
      await _syncService.queueOperation(
        operation: 'create',
        entityType: 'log',
        entityId: log.id,
        data: _logToMap(log),
      );
    }

    return result;
  }

  @override
  Future<Result<void>> undoCheckIn(String habitId, String userId) async {
    // Get the log first to queue for deletion
    final logResult = await _baseRepository.getLogForDate(
      habitId,
      DateTime.now(),
    );

    // Undo locally
    final result = await _baseRepository.undoCheckIn(habitId, userId);

    // Queue deletion for sync if successful
    if (result is Success<void> && 
        logResult is Success<HabitLog?> && 
        logResult.data != null) {
      await _syncService.queueOperation(
        operation: 'delete',
        entityType: 'log',
        entityId: logResult.data!.id,
        data: {'id': logResult.data!.id},
      );
    }

    return result;
  }

  @override
  Future<Result<void>> useStreakRecovery({
    required String habitId,
    required String userId,
    required DateTime missedDate,
  }) async {
    // Use recovery locally
    final result = await _baseRepository.useStreakRecovery(
      habitId: habitId,
      userId: userId,
      missedDate: missedDate,
    );

    // Queue for sync if successful
    if (result is Success<void>) {
      // This creates both a log and a recovery record
      // We need to queue both

      // Get the created log
      final logResult = await _baseRepository.getLogForDate(
        habitId,
        missedDate,
      );

      if (logResult is Success<HabitLog?> && logResult.data != null) {
        await _syncService.queueOperation(
          operation: 'create',
          entityType: 'log',
          entityId: logResult.data!.id,
          data: _logToMap(logResult.data!),
        );
      }

      // Queue recovery record
      final recoveryId = '${habitId}_${missedDate.millisecondsSinceEpoch}';
      await _syncService.queueOperation(
        operation: 'create',
        entityType: 'streak_recovery',
        entityId: recoveryId,
        data: {
          'id': recoveryId,
          'habitId': habitId,
          'userId': userId,
          'missedDate': missedDate.toIso8601String(),
          'usedAt': DateTime.now().toIso8601String(),
        },
      );
    }

    return result;
  }

  // Pass-through methods (read-only, no sync needed)
  @override
  Future<Result<List<Habit>>> getHabits(String userId) =>
      _baseRepository.getHabits(userId);

  @override
  Future<Result<List<Habit>>> getActiveHabits(String userId) =>
      _baseRepository.getActiveHabits(userId);

  @override
  Future<Result<Habit>> getHabitById(String habitId) =>
      _baseRepository.getHabitById(habitId);

  @override
  Future<Result<Habit>> changeHabitStatus(String habitId, HabitStatus status) =>
      _baseRepository.changeHabitStatus(habitId, status);

  @override
  Future<Result<List<HabitLog>>> getLogsForHabit(String habitId) =>
      _baseRepository.getLogsForHabit(habitId);

  @override
  Future<Result<HabitLog?>> getLogForDate(String habitId, DateTime date) =>
      _baseRepository.getLogForDate(habitId, date);

  @override
  Future<Result<List<HabitLog>>> getTodayLogs(String userId) =>
      _baseRepository.getTodayLogs(userId);

  @override
  Future<Result<HabitStatistics>> getHabitStatistics(String habitId) =>
      _baseRepository.getHabitStatistics(habitId);

  @override
  Future<Result<int>> getCompletionCount(String habitId) =>
      _baseRepository.getCompletionCount(habitId);

  @override
  Future<Result<int>> getCurrentStreak(String habitId) =>
      _baseRepository.getCurrentStreak(habitId);

  @override
  Future<Result<List<StreakRecovery>>> getRecentRecoveries({
    required String habitId,
    required String userId,
  }) =>
      _baseRepository.getRecentRecoveries(
        habitId: habitId,
        userId: userId,
      );

  @override
  Future<Result<StreakRecoveryEligibility>> checkRecoveryEligibility({
    required String habitId,
    required String userId,
    required DateTime missedDate,
  }) =>
      _baseRepository.checkRecoveryEligibility(
        habitId: habitId,
        userId: userId,
        missedDate: missedDate,
      );

  @override
  Future<Result<void>> syncWithFirebase() async {
    await _syncService.syncPendingOperations();
    return const Success(null);
  }

  @override
  Stream<List<Habit>> watchHabits(String userId) =>
      _baseRepository.watchHabits(userId);

  @override
  Stream<List<HabitLog>> watchTodayLogs(String userId) =>
      _baseRepository.watchTodayLogs(userId);

  // Helper methods to convert entities to maps
  Map<String, dynamic> _habitToMap(Habit habit) {
    return {
      'id': habit.id,
      'userId': habit.userId,
      'name': habit.name,
      'description': habit.description,
      'category': habit.category,
      'icon': habit.icon,
      'color': habit.color,
      'frequency': _frequencyToMap(habit.frequency),
      'status': _statusToString(habit.status),
      'createdAt': habit.createdAt.toIso8601String(),
      'updatedAt': habit.updatedAt.toIso8601String(),
      'isShared': habit.isShared,
    };
  }

  Map<String, dynamic> _logToMap(HabitLog log) {
    return {
      'id': log.id,
      'habitId': log.habitId,
      'userId': log.userId,
      'date': log.date.toIso8601String(),
      'completed': log.completed,
      'skipped': log.skipped,
      'quality': log.quality != null ? _qualityToString(log.quality!) : null,
      'skipReason': log.skipReason,
      'note': log.note,
      'mood': log.mood,
      'createdAt': log.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _frequencyToMap(HabitFrequency frequency) {
    return {
      'type': _frequencyTypeToString(frequency.type),
      'config': frequency.config,
    };
  }

  String _frequencyTypeToString(FrequencyType type) {
    switch (type) {
      case FrequencyType.daily:
        return 'daily';
      case FrequencyType.weekly:
        return 'weekly';
      case FrequencyType.monthly:
        return 'monthly';
      case FrequencyType.flexible:
        return 'flexible';
      case FrequencyType.custom:
        return 'custom';
    }
  }

  String _statusToString(HabitStatus status) {
    switch (status) {
      case HabitStatus.active:
        return 'active';
      case HabitStatus.paused:
        return 'paused';
      case HabitStatus.archived:
        return 'archived';
    }
  }

  String _qualityToString(LogQuality quality) {
    switch (quality) {
      case LogQuality.minimal:
        return 'minimal';
      case LogQuality.good:
        return 'good';
      case LogQuality.excellent:
        return 'excellent';
    }
  }
}
