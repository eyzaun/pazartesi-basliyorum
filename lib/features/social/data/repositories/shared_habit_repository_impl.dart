import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/result.dart';
import '../../domain/entities/shared_habit.dart';
import '../../domain/repositories/shared_habit_repository.dart';
import '../models/shared_habit_model.dart';

/// Implementation of SharedHabitRepository.
class SharedHabitRepositoryImpl implements SharedHabitRepository {
  SharedHabitRepositoryImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Future<Result<SharedHabit>> shareHabit({
    required String habitId,
    required String friendId,
    bool canEdit = false,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return const Failure('Kullanıcı oturumu bulunamadı');
      }

      // Get habit details
      final habitDoc = await _firestore.collection('habits').doc(habitId).get();
      if (!habitDoc.exists) {
        return const Failure('Alışkanlık bulunamadı');
      }

      final habitData = habitDoc.data()!;

      // Get current user info
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data()!;

      // Get friend info
      final friendDoc = await _firestore.collection('users').doc(friendId).get();
      if (!friendDoc.exists) {
        return const Failure('Kullanıcı bulunamadı');
      }
      final friendData = friendDoc.data()!;

      // Check if already shared
      final existingQuery = await _firestore
          .collection('shared_habits')
          .where('habitId', isEqualTo: habitId)
          .where('ownerId', isEqualTo: userId)
          .where('sharedWithId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return const Failure('Bu alışkanlık zaten bu kullanıcıyla paylaşıldı');
      }

      // Create shared habit
      final docRef = _firestore.collection('shared_habits').doc();
      
      // Handle color conversion from String (hex) to int
      int? habitColor;
      final colorValue = habitData['color'];
      if (colorValue != null) {
        if (colorValue is int) {
          habitColor = colorValue;
        } else if (colorValue is String) {
          // Convert hex string to int (e.g., "#6C63FF" -> 0xFF6C63FF)
          try {
            final hexColor = colorValue.replaceAll('#', '');
            habitColor = int.parse('FF$hexColor', radix: 16);
          } catch (e) {
            // If parsing fails, use null
            habitColor = null;
          }
        }
      }
      
      final sharedHabit = SharedHabitModel(
        id: docRef.id,
        habitId: habitId,
        habitName: habitData['name'] as String,
        habitDescription: habitData['description'] as String?,
        habitIcon: habitData['icon'] as String?,
        habitColor: habitColor,
        ownerId: userId,
        ownerUsername: userData['username'] as String,
        sharedWithId: friendId,
        sharedWithUsername: friendData['username'] as String,
        canEdit: canEdit,
        createdAt: DateTime.now(),
      );

      await docRef.set(sharedHabit.toFirestore());

      return Success(sharedHabit.toEntity());
    } catch (e) {
      return Failure('Alışkanlık paylaşılamadı: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> unshareHabit(String sharedHabitId) async {
    try {
      await _firestore.collection('shared_habits').doc(sharedHabitId).delete();

      return const Success(null);
    } catch (e) {
      return Failure('Paylaşım iptal edilemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<SharedHabit>>> getSharedByMe(String userId) async {
    try {
      final query = await _firestore
          .collection('shared_habits')
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final sharedHabits = query.docs
          .map((doc) => SharedHabitModel.fromDocument(doc).toEntity())
          .toList();

      return Success(sharedHabits);
    } catch (e) {
      return Failure('Paylaşılan alışkanlıklar yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<SharedHabit>>> getSharedWithMe(String userId) async {
    try {
      final query = await _firestore
          .collection('shared_habits')
          .where('sharedWithId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final sharedHabits = query.docs
          .map((doc) => SharedHabitModel.fromDocument(doc).toEntity())
          .toList();

      return Success(sharedHabits);
    } catch (e) {
      return Failure('Paylaşılan alışkanlıklar yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Stream<List<SharedHabit>> watchSharedByMe(String userId) {
    return _firestore
        .collection('shared_habits')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedHabitModel.fromDocument(doc).toEntity())
            .toList(),);
  }

  @override
  Stream<List<SharedHabit>> watchSharedWithMe(String userId) {
    return _firestore
        .collection('shared_habits')
        .where('sharedWithId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedHabitModel.fromDocument(doc).toEntity())
            .toList(),);
  }
}

// Provider
final sharedHabitRepositoryProvider = Provider<SharedHabitRepository>((ref) {
  return SharedHabitRepositoryImpl(
    FirebaseFirestore.instance,
    firebase_auth.FirebaseAuth.instance,
  );
});
