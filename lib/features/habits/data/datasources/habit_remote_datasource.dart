import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit_log_model.dart';
import '../models/habit_model.dart';
import '../models/streak_recovery_model.dart';

/// Remote data source for habits using Firebase Firestore.
/// Handles all cloud database operations.
class HabitRemoteDataSource {
  HabitRemoteDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  // Collection references
  CollectionReference get _habitsCollection => _firestore.collection('habits');
  CollectionReference get _logsCollection =>
      _firestore.collection('habit_logs');
  CollectionReference get _recoveriesCollection =>
      _firestore.collection('streak_recoveries');

  // ========================================================================
  // Habit Operations
  // ========================================================================

  /// Get all habits for a user from Firestore.
  Future<List<HabitModel>> getAllHabits(String userId) async {
    try {
      final querySnapshot = await _habitsCollection
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              HabitModel.fromFirestore(doc.data() as Map<String, dynamic>),)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch habits: $e');
    }
  }

  /// Get active habits for a user from Firestore.
  Future<List<HabitModel>> getActiveHabits(String userId) async {
    try {
      final querySnapshot = await _habitsCollection
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              HabitModel.fromFirestore(doc.data() as Map<String, dynamic>),)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active habits: $e');
    }
  }

  /// Get a single habit by ID from Firestore.
  Future<HabitModel?> getHabitById(String habitId) async {
    try {
      final doc = await _habitsCollection.doc(habitId).get();

      if (!doc.exists) return null;

      return HabitModel.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch habit: $e');
    }
  }

  /// Create a new habit in Firestore.
  Future<void> createHabit(HabitModel habit) async {
    try {
      await _habitsCollection.doc(habit.id).set(habit.toFirestore());
    } catch (e) {
      throw Exception('Failed to create habit: $e');
    }
  }

  /// Update an existing habit in Firestore.
  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _habitsCollection.doc(habit.id).update({
        ...habit.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  /// Delete a habit from Firestore.
  Future<void> deleteHabit(String habitId) async {
    try {
      // Delete the habit
      await _habitsCollection.doc(habitId).delete();

      // Also delete all logs for this habit
      final logsQuery =
          await _logsCollection.where('habitId', isEqualTo: habitId).get();

      final batch = _firestore.batch();
      for (final doc in logsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  /// Stream of habits for real-time updates.
  Stream<List<HabitModel>> watchHabits(String userId) {
    return _habitsCollection
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  HabitModel.fromFirestore(doc.data() as Map<String, dynamic>),)
              .toList(),
        );
  }

  // ========================================================================
  // Habit Log Operations
  // ========================================================================

  /// Get logs for a habit from Firestore.
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async {
    try {
      final querySnapshot = await _logsCollection
          .where('habitId', isEqualTo: habitId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              HabitLogModel.fromFirestore(doc.data() as Map<String, dynamic>),)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch logs: $e');
    }
  }

  /// Get log for a specific habit and date.
  Future<HabitLogModel?> getLogForDate(String habitId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _logsCollection
          .where('habitId', isEqualTo: habitId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return HabitLogModel.fromFirestore(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to fetch log for date: $e');
    }
  }

  /// Get today's logs for a user.
  Future<List<HabitLogModel>> getTodayLogsForUser(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _logsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs
          .map((doc) =>
              HabitLogModel.fromFirestore(doc.data() as Map<String, dynamic>),)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch today logs: $e');
    }
  }

  /// Create or update a habit log in Firestore.
  Future<void> upsertHabitLog(HabitLogModel log) async {
    try {
      await _logsCollection.doc(log.id).set(log.toFirestore());
    } catch (e) {
      throw Exception('Failed to save habit log: $e');
    }
  }

  /// Delete a habit log from Firestore.
  Future<void> deleteHabitLog(String logId) async {
    try {
      await _logsCollection.doc(logId).delete();
    } catch (e) {
      throw Exception('Failed to delete log: $e');
    }
  }

  /// Stream of today's logs for real-time updates.
  Stream<List<HabitLogModel>> watchTodayLogs(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _logsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HabitLogModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,),)
              .toList(),
        );
  }

  // ========================================================================
  // Batch Operations
  // ========================================================================

  /// Sync multiple habits to Firestore.
  Future<void> syncHabits(List<HabitModel> habits) async {
    try {
      final batch = _firestore.batch();

      for (final habit in habits) {
        batch.set(
          _habitsCollection.doc(habit.id),
          habit.toFirestore(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync habits: $e');
    }
  }

  /// Sync multiple logs to Firestore.
  Future<void> syncLogs(List<HabitLogModel> logs) async {
    try {
      final batch = _firestore.batch();

      for (final log in logs) {
        batch.set(
          _logsCollection.doc(log.id),
          log.toFirestore(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync logs: $e');
    }
  }

  // Streak Recovery Operations

  Future<void> createStreakRecovery(StreakRecoveryModel recovery) async {
    try {
      await _recoveriesCollection.doc(recovery.id).set(recovery.toFirestore());
    } catch (e) {
      throw Exception('Failed to create streak recovery: $e');
    }
  }

  Future<List<StreakRecoveryModel>> getRecentRecoveries({
    required String habitId,
    required String userId,
  }) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final querySnapshot = await _recoveriesCollection
          .where('habitId', isEqualTo: habitId)
          .where('userId', isEqualTo: userId)
          .where('usedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),)
          .orderBy('usedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(StreakRecoveryModel.fromFirestore)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recovery records: $e');
    }
  }

  Future<void> createHabitLog(HabitLogModel log) async {
    try {
      await _logsCollection.doc(log.id).set(log.toFirestore());
    } catch (e) {
      throw Exception('Failed to create habit log: $e');
    }
  }
}
