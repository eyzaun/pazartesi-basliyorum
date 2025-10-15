import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/timer_session_remote_datasource.dart';
import '../../data/repositories/timer_session_repository_impl.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/repositories/timer_session_repository.dart';

/// Provider for TimerSessionRemoteDataSource
final timerSessionRemoteDataSourceProvider =
    Provider<TimerSessionRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TimerSessionRemoteDataSource(firestore);
});

/// Provider for TimerSessionRepository
final timerSessionRepositoryProvider = Provider<TimerSessionRepository>((ref) {
  final remoteDataSource = ref.watch(timerSessionRemoteDataSourceProvider);
  return TimerSessionRepositoryImpl(remoteDataSource);
});

/// Provider to watch timer sessions for a habit
final timerSessionsProvider =
    StreamProvider.family<List<TimerSession>, String>((ref, habitId) {
  final repository = ref.watch(timerSessionRepositoryProvider);
  return repository.watchSessionsForHabit(habitId);
});

/// Provider to get today's sessions for a habit
final todaySessionsProvider =
    FutureProvider.family<List<TimerSession>, String>((ref, habitId) async {
  final repository = ref.watch(timerSessionRepositoryProvider);
  return repository.getTodaySessions(habitId);
});

/// Provider to get total time for a habit
final totalTimeProvider =
    FutureProvider.family<int, String>((ref, habitId) async {
  final repository = ref.watch(timerSessionRepositoryProvider);
  return repository.getTotalTimeForHabit(habitId);
});
