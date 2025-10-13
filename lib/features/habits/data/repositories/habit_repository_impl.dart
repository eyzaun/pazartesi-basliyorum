import 'package:uuid/uuid.dart';

import '../../../../shared/models/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_datasource.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

/// Implementation of HabitRepository using Firebase only.
/// Simple and straightforward - all data stored in Firestore.
class HabitRepositoryImpl implements HabitRepository {
  
  HabitRepositoryImpl({
    required this.remoteDataSource,
    required this.uuid,
  });
  
  final HabitRemoteDataSource remoteDataSource;
  final Uuid uuid;
  
  // ========================================================================
  // Habit CRUD Operations
  // ========================================================================
  
  @override
  Future<Result<Habit>> createHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);
      await remoteDataSource.createHabit(habitModel);
      return Success(habitModel.toEntity());
    } catch (e) {
      return Failure('Alışkanlık oluşturulamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<List<Habit>>> getHabits(String userId) async {
    try {
      final habits = await remoteDataSource.getAllHabits(userId);
      return Success(habits.map((h) => h.toEntity()).toList());
    } catch (e) {
      return Failure('Alışkanlıklar alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<List<Habit>>> getActiveHabits(String userId) async {
    try {
      final habits = await remoteDataSource.getActiveHabits(userId);
      return Success(habits.map((h) => h.toEntity()).toList());
    } catch (e) {
      return Failure('Aktif alışkanlıklar alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<Habit>> getHabitById(String habitId) async {
    try {
      final habit = await remoteDataSource.getHabitById(habitId);
      
      if (habit == null) {
        return const Failure('Alışkanlık bulunamadı');
      }
      
      return Success(habit.toEntity());
    } catch (e) {
      return Failure('Alışkanlık alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<Habit>> updateHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);
      await remoteDataSource.updateHabit(habitModel);
      return Success(habitModel.toEntity());
    } catch (e) {
      return Failure('Alışkanlık güncellenemedi: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<void>> deleteHabit(String habitId) async {
    try {
      await remoteDataSource.deleteHabit(habitId);
      return const Success(null);
    } catch (e) {
      return Failure('Alışkanlık silinemedi: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<Habit>> changeHabitStatus(
    String habitId,
    HabitStatus status,
  ) async {
    try {
      final habit = await remoteDataSource.getHabitById(habitId);
      
      if (habit == null) {
        return const Failure('Alışkanlık bulunamadı');
      }
      
      final updatedHabit = habit.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      
      return await updateHabit(updatedHabit.toEntity());
    } catch (e) {
      return Failure('Durum değiştirilemedi: ${e.toString()}');
    }
  }
  
  // ========================================================================
  // Habit Log Operations
  // ========================================================================
  
  @override
  Future<Result<HabitLog>> completeHabit({
    required String habitId,
    required String userId,
    LogQuality? quality,
    String? note,
  }) async {
    try {
      final now = DateTime.now();
      final logId = uuid.v4();
      
      final log = HabitLogModel(
        id: logId,
        habitId: habitId,
        userId: userId,
        date: now,
        completed: true,
        quality: quality,
        note: note,
        createdAt: now,
      );
      
      await remoteDataSource.upsertHabitLog(log);
      return Success(log.toEntity());
    } catch (e) {
      return Failure('Tamamlanamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<HabitLog>> skipHabit({
    required String habitId,
    required String userId,
    required String skipReason,
  }) async {
    try {
      final now = DateTime.now();
      final logId = uuid.v4();
      
      final log = HabitLogModel(
        id: logId,
        habitId: habitId,
        userId: userId,
        date: now,
        completed: false,
        skipped: true,
        skipReason: skipReason,
        createdAt: now,
      );
      
      await remoteDataSource.upsertHabitLog(log);
      return Success(log.toEntity());
    } catch (e) {
      return Failure('Atlanamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<void>> undoCheckIn(String habitId, String userId) async {
    try {
      final now = DateTime.now();
      final logs = await remoteDataSource.getLogsForHabit(habitId);
      
      // Find today's log
      final todayLog = logs.where((log) {
        return log.date.year == now.year &&
               log.date.month == now.month &&
               log.date.day == now.day;
      }).firstOrNull;
      
      if (todayLog == null) {
        return const Failure('Bugün için kayıt bulunamadı');
      }
      
      await remoteDataSource.deleteHabitLog(todayLog.id);
      return const Success(null);
    } catch (e) {
      return Failure('Geri alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<List<HabitLog>>> getLogsForHabit(String habitId) async {
    try {
      final logs = await remoteDataSource.getLogsForHabit(habitId);
      return Success(logs.map((l) => l.toEntity()).toList());
    } catch (e) {
      return Failure('Kayıtlar alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<HabitLog?>> getLogForDate(
    String habitId,
    DateTime date,
  ) async {
    try {
      final logs = await remoteDataSource.getLogsForHabit(habitId);
      
      final log = logs.where((l) {
        return l.date.year == date.year &&
               l.date.month == date.month &&
               l.date.day == date.day;
      }).firstOrNull;
      
      return Success(log?.toEntity());
    } catch (e) {
      return Failure('Kayıt alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<List<HabitLog>>> getTodayLogs(String userId) async {
    try {
      final logs = await remoteDataSource.getTodayLogsForUser(userId);
      return Success(logs.map((l) => l.toEntity()).toList());
    } catch (e) {
      return Failure('Bugünün kayıtları alınamadı: ${e.toString()}');
    }
  }
  
  // ========================================================================
  // Statistics Operations
  // ========================================================================
  
  @override
  Future<Result<HabitStatistics>> getHabitStatistics(String habitId) async {
    try {
      final logs = await remoteDataSource.getLogsForHabit(habitId);
      final completedLogs = logs.where((l) => l.completed).toList();
      
      final completionCount = completedLogs.length;
      final currentStreak = _calculateCurrentStreak(completedLogs);
      final longestStreak = _calculateLongestStreak(completedLogs);
      
      final stats = HabitStatistics(
        habitId: habitId,
        totalCompletions: completionCount,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        completionRate: 0, // TODO: Calculate based on frequency
      );
      
      return Success(stats);
    } catch (e) {
      return Failure('İstatistikler alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<int>> getCompletionCount(String habitId) async {
    try {
      final logs = await remoteDataSource.getLogsForHabit(habitId);
      final count = logs.where((l) => l.completed).length;
      return Success(count);
    } catch (e) {
      return Failure('Tamamlanma sayısı alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<int>> getCurrentStreak(String habitId) async {
    try {
      final logs = await remoteDataSource.getLogsForHabit(habitId);
      final completedLogs = logs.where((l) => l.completed).toList();
      final streak = _calculateCurrentStreak(completedLogs);
      return Success(streak);
    } catch (e) {
      return Failure('Seri alınamadı: ${e.toString()}');
    }
  }
  
  // ========================================================================
  // Helper Methods
  // ========================================================================
  
  int _calculateCurrentStreak(List<HabitLogModel> logs) {
    if (logs.isEmpty) return 0;
    
    // Sort by date descending
    final sortedLogs = logs.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    var streak = 0;
    var currentDate = DateTime.now();
    
    for (final log in sortedLogs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (logDate.isAtSameMomentAs(checkDate) || 
          logDate.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
        streak++;
        currentDate = log.date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  int _calculateLongestStreak(List<HabitLogModel> logs) {
    if (logs.isEmpty) return 0;
    
    // Sort by date
    final sortedLogs = logs.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    var longestStreak = 1;
    var currentStreak = 1;
    
    for (var i = 1; i < sortedLogs.length; i++) {
      final prevDate = DateTime(
        sortedLogs[i - 1].date.year,
        sortedLogs[i - 1].date.month,
        sortedLogs[i - 1].date.day,
      );
      final currDate = DateTime(
        sortedLogs[i].date.year,
        sortedLogs[i].date.month,
        sortedLogs[i].date.day,
      );
      
      if (currDate.difference(prevDate).inDays == 1) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else {
        currentStreak = 1;
      }
    }
    
    return longestStreak;
  }
  
  // ========================================================================
  // Sync Operations (No-op in Firebase-only version)
  // ========================================================================
  
  @override
  Future<Result<void>> syncWithFirebase() async {
    // No sync needed - everything is already in Firebase
    return const Success(null);
  }
  
  @override
  Stream<List<Habit>> watchHabits(String userId) {
    return remoteDataSource
        .watchHabits(userId)
        .map((habits) => habits.map((h) => h.toEntity()).toList());
  }
  
  @override
  Stream<List<HabitLog>> watchTodayLogs(String userId) {
    return remoteDataSource
        .watchTodayLogs(userId)
        .map((logs) => logs.map((l) => l.toEntity()).toList());
  }
}
