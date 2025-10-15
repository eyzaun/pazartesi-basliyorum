import '../../domain/entities/timer_session.dart';
import '../../domain/repositories/timer_session_repository.dart';
import '../datasources/timer_session_remote_datasource.dart';
import '../models/timer_session_model.dart';

/// Implementation of TimerSessionRepository.
class TimerSessionRepositoryImpl implements TimerSessionRepository {
  TimerSessionRepositoryImpl(this._remoteDataSource);

  final TimerSessionRemoteDataSource _remoteDataSource;

  @override
  Future<void> createSession(TimerSession session) async {
    final model = TimerSessionModel.fromEntity(session);
    await _remoteDataSource.createSession(model);
  }

  @override
  Future<void> updateSession(TimerSession session) async {
    final model = TimerSessionModel.fromEntity(session);
    await _remoteDataSource.updateSession(model);
  }

  @override
  Future<TimerSession?> getSession(String sessionId) async {
    final model = await _remoteDataSource.getSession(sessionId);
    return model?.toEntity();
  }

  @override
  Future<List<TimerSession>> getSessionsForHabit(String habitId) async {
    final models = await _remoteDataSource.getSessionsForHabit(habitId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<TimerSession>> getSessionsInRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await _remoteDataSource.getSessionsInRange(
      habitId,
      startDate,
      endDate,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> getTotalTimeForHabit(String habitId) async {
    return _remoteDataSource.getTotalTimeForHabit(habitId);
  }

  @override
  Future<List<TimerSession>> getTodaySessions(String habitId) async {
    final models = await _remoteDataSource.getTodaySessions(habitId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _remoteDataSource.deleteSession(sessionId);
  }

  @override
  Stream<List<TimerSession>> watchSessionsForHabit(String habitId) {
    return _remoteDataSource
        .watchSessionsForHabit(habitId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }
}
