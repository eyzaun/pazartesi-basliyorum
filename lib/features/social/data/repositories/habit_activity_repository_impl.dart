import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/result.dart';
import '../../domain/entities/habit_activity.dart';
import '../../domain/repositories/habit_activity_repository.dart';
import '../models/habit_activity_model.dart';

/// Implementation of HabitActivityRepository.
class HabitActivityRepositoryImpl implements HabitActivityRepository {
  HabitActivityRepositoryImpl(this._firestore, this._auth, this._storage);

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseStorage _storage;

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Future<Result<HabitActivity>> shareActivity({
    required String habitId,
    required String habitName,
    required String habitIcon,
    required int habitColor,
    required DateTime completedAt,
    String? quality,
    String? note,
    File? photo,
    int? timerDuration,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return const Failure('Kullanıcı oturumu bulunamadı');
      }

      // Get user info
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return const Failure('Kullanıcı bilgisi bulunamadı');
      }
      final userData = userDoc.data()!;
      final username = userData['username'] as String;

      // Upload photo if provided
      String? photoUrl;
      if (photo != null) {
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'habit_activities/$userId/${timestamp}_${photo.path.split('/').last}';
          final ref = _storage.ref().child(fileName);
          await ref.putFile(photo);
          photoUrl = await ref.getDownloadURL();
        } catch (e) {
          // Photo upload failed, continue without photo
          photoUrl = null;
        }
      }

      // Create activity document
      final docRef = _firestore.collection('habit_activities').doc();
      final activity = HabitActivityModel(
        id: docRef.id,
        userId: userId,
        username: username,
        habitId: habitId,
        habitName: habitName,
        habitIcon: habitIcon,
        habitColor: habitColor,
        completedAt: completedAt,
        createdAt: DateTime.now(),
        quality: quality,
        note: note,
        photoUrl: photoUrl,
        timerDuration: timerDuration,
      );

      await docRef.set(activity.toFirestore());

      return Success(activity.toEntity());
    } catch (e) {
      return Failure('Aktivite paylaşılamadı: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<HabitActivity>>> getActivityFeed(String userId) async {
    try {
      // Get user's friends
      final friendsQuery = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final friendIds = friendsQuery.docs
          .map((doc) => doc.data()['friendId'] as String)
          .toList();

      // Also check where user is the friend
      final friendsQuery2 = await _firestore
          .collection('friendships')
          .where('friendId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      friendIds.addAll(
        friendsQuery2.docs
            .map((doc) => doc.data()['userId'] as String)
            .toList(),
      );

      if (friendIds.isEmpty) {
        return const Success([]);
      }

      // Get activities from friends (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // Firestore 'in' query limit is 10, so we need to batch
      final activities = <HabitActivity>[];
      for (var i = 0; i < friendIds.length; i += 10) {
        final batch = friendIds.skip(i).take(10).toList();
        final query = await _firestore
            .collection('habit_activities')
            .where('userId', whereIn: batch)
            .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();

        activities.addAll(
          query.docs.map((doc) => HabitActivityModel.fromFirestore(doc).toEntity()),
        );
      }

      // Sort all activities by date
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Success(activities);
    } catch (e) {
      return Failure('Aktiviteler yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<HabitActivity>>> getUserActivities(String userId) async {
    try {
      final query = await _firestore
          .collection('habit_activities')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final activities = query.docs
          .map((doc) => HabitActivityModel.fromFirestore(doc).toEntity())
          .toList();

      return Success(activities);
    } catch (e) {
      return Failure('Aktiviteler yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteActivity(String activityId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return const Failure('Kullanıcı oturumu bulunamadı');
      }

      // Check if user owns this activity
      final doc = await _firestore.collection('habit_activities').doc(activityId).get();
      if (!doc.exists) {
        return const Failure('Aktivite bulunamadı');
      }

      final activityUserId = doc.data()!['userId'] as String;
      if (activityUserId != userId) {
        return const Failure('Bu aktiviteyi silme yetkiniz yok');
      }

      // Delete photo from storage if exists
      final photoUrl = doc.data()!['photoUrl'] as String?;
      if (photoUrl != null) {
        try {
          final ref = _storage.refFromURL(photoUrl);
          await ref.delete();
        } catch (e) {
          // Photo deletion failed, continue with document deletion
        }
      }

      // Delete activity document
      await _firestore.collection('habit_activities').doc(activityId).delete();

      return const Success(null);
    } catch (e) {
      return Failure('Aktivite silinemedi: ${e.toString()}');
    }
  }
}

/// Provider for HabitActivityRepository
final habitActivityRepositoryProvider = Provider<HabitActivityRepository>((ref) {
  return HabitActivityRepositoryImpl(
    FirebaseFirestore.instance,
    firebase_auth.FirebaseAuth.instance,
    FirebaseStorage.instance,
  );
});
