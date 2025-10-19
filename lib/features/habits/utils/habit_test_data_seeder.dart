import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/constants/env.dart';
import '../../../shared/models/result.dart';
import '../data/datasources/habit_remote_datasource.dart';
import '../data/models/habit_log_model.dart';
import '../domain/entities/habit.dart';
import '../domain/entities/habit_log.dart';
import '../domain/repositories/habit_repository.dart';
import '../presentation/providers/habits_provider.dart';

/// Seeds sample data for custom-frequency habit scoring when TEST_MODE is true.
class HabitTestDataSeeder {
  HabitTestDataSeeder(WidgetRef ref)
      : _uuid = ref.read(uuidProvider),
        _repository = ref.read(habitRepositoryProvider),
        _remote = ref.read(habitRemoteDataSourceProvider);
  final Uuid _uuid;
  final HabitRepository _repository;
  final HabitRemoteDataSource _remote;

  static const String _habitName = 'Test Özel Alışkanlık';
  static const String _testCategory = 'TEST';

  Future<void> ensureSeeded(String userId) async {
    if (!kTestMode) return;

    final habitsResult = await _repository.getHabits(userId);
    if (habitsResult is! Success<List<Habit>>) {
      return;
    }

    Habit? habit;
    for (final h in habitsResult.data) {
      if (h.name == _habitName && h.category == _testCategory) {
        habit = h;
        break;
      }
    }

    if (habit == null) {
      final now = DateTime.now();
      habit = Habit(
        id: _uuid.v4(),
        userId: userId,
        name: _habitName,
        description:
            'TEST_MODE için otomatik oluşturulan özel sıklık alışkanlığı.',
        category: _testCategory,
        icon: 'auto_graph',
        color: '#6C63FF',
        frequency: HabitFrequency.custom(timesInPeriod: 1, periodDays: 3),
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now,
      );

      await _repository.createHabit(habit);
    }

    await _ensureLogs(userId, habit);
  }

  Future<void> _ensureLogs(String userId, Habit habit) async {
    final logsResult = await _repository.getLogsForHabit(habit.id);
    final existingLogs = logsResult is Success<List<HabitLog>>
        ? logsResult.data
        : <HabitLog>[];

    final existingDates = existingLogs
        .where((log) => log.completed)
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toSet();

    final now = DateTime.now();
    final actionDays = <int>[18, 15, 12, 9, 6, 3];

    for (final offset in actionDays) {
      final date =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: offset));

      if (existingDates.contains(date)) {
        continue;
      }

      final log = HabitLogModel(
        id: _uuid.v4(),
        habitId: habit.id,
        userId: userId,
        date: date,
        completed: true,
        skipped: false,
        quality: LogQuality.excellent,
        note: 'Test modu otomatik kaydı',
        createdAt: date,
      );

      await _remote.createHabitLog(log);
    }
  }
}
