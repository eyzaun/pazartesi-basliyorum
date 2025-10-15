import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/timer_session_model.dart';

/// Remote data source for timer sessions using Firestore.
class TimerSessionRemoteDataSource {
  TimerSessionRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Create a new timer session
  Future<void> createSession(TimerSessionModel session) async {
    final data = session.toFirestore();
    
    await _firestore
        .collection('timer_sessions')
        .doc(session.id)
        .set(data);
  }

  /// Update an existing timer session
  Future<void> updateSession(TimerSessionModel session) async {
    await _firestore
        .collection('timer_sessions')
        .doc(session.id)
        .update(session.toFirestore());
  }

  /// Get a single timer session by ID
  Future<TimerSessionModel?> getSession(String sessionId) async {
    final doc = await _firestore
        .collection('timer_sessions')
        .doc(sessionId)
        .get();

    if (!doc.exists) return null;

    return TimerSessionModel.fromFirestore(doc.data()!);
  }

  /// Get all timer sessions for a habit
  Future<List<TimerSessionModel>> getSessionsForHabit(String habitId) async {
    final querySnapshot = await _firestore
        .collection('timer_sessions')
        .where('habitId', isEqualTo: habitId)
        .orderBy('startedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TimerSessionModel.fromFirestore(doc.data()))
        .toList();
  }

  /// Get timer sessions for a habit within a date range
  Future<List<TimerSessionModel>> getSessionsInRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final querySnapshot = await _firestore
        .collection('timer_sessions')
        .where('habitId', isEqualTo: habitId)
        .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('startedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TimerSessionModel.fromFirestore(doc.data()))
        .toList();
  }

  /// Get total time spent on a habit (in seconds)
  Future<int> getTotalTimeForHabit(String habitId) async {
    final sessions = await getSessionsForHabit(habitId);
    return sessions.fold<int>(
      0,
      (total, session) => total + session.actualSeconds,
    );
  }

  /// Get today's sessions for a habit
  Future<List<TimerSessionModel>> getTodaySessions(String habitId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getSessionsInRange(habitId, startOfDay, endOfDay);
  }

  /// Delete a timer session
  Future<void> deleteSession(String sessionId) async {
    await _firestore
        .collection('timer_sessions')
        .doc(sessionId)
        .delete();
  }

  /// Watch timer sessions for a habit (real-time updates)
  Stream<List<TimerSessionModel>> watchSessionsForHabit(String habitId) {
    return _firestore
        .collection('timer_sessions')
        .where('habitId', isEqualTo: habitId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimerSessionModel.fromFirestore(doc.data()))
            .toList());
  }
}
