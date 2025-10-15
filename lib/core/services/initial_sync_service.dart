import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitialSyncProgress {

  const InitialSyncProgress(this.message, this.progress);
  final String message;
  final double progress;
}

class InitialSyncException implements Exception {
  InitialSyncException(this.message);
  final String message;

  @override
  String toString() => message;
}

class InitialSyncService {

  InitialSyncService(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> performInitialSync({
    required Function(InitialSyncProgress) onProgress,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw InitialSyncException('Kullanıcı oturumu bulunamadı');
    }

    try {
      onProgress(const InitialSyncProgress('Başlıyor...', 0));

      // Download habits
      onProgress(const InitialSyncProgress('Alışkanlıklar indiriliyor...', 0.1));
      await _downloadHabits(userId);

      // Download logs
      onProgress(const InitialSyncProgress('Kayıtlar indiriliyor...', 0.4));
      await _downloadLogs(userId);

      // Download achievements
      onProgress(const InitialSyncProgress('Rozetler indiriliyor...', 0.7));
      await _downloadAchievements(userId);

      // Download user profile
      onProgress(const InitialSyncProgress('Profil indiriliyor...', 0.9));
      await _downloadUserProfile(userId);

      onProgress(const InitialSyncProgress('Tamamlandı!', 1));
    } catch (e) {
      throw InitialSyncException('İlk senkronizasyon başarısız: $e');
    }
  }

  Future<void> _downloadHabits(String userId) async {
    await _firestore
        .collection('habits')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();
    // Habits are already cached by Firestore
  }

  Future<void> _downloadLogs(String userId) async {
    // Download logs from last 90 days
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));

    await _firestore
        .collection('habit_logs')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: ninetyDaysAgo)
        .get();
    // Logs are already cached by Firestore
  }

  Future<void> _downloadAchievements(String userId) async {
    await _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .get();
    // Achievements are already cached by Firestore
  }

  Future<void> _downloadUserProfile(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!snapshot.exists) {
      throw InitialSyncException('Kullanıcı profili bulunamadı');
    }
    // User profile is already cached by Firestore
  }

  Future<bool> needsInitialSync(String userId) async {
    // Check if user has done initial sync
    final userDoc = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    final data = userDoc.data();
    if (data == null) return true;

    final lastSyncTime = data['lastInitialSync'] as Timestamp?;
    return lastSyncTime == null;
  }

  Future<void> markInitialSyncComplete(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastInitialSync': FieldValue.serverTimestamp(),
    });
  }
}

// Provider
final initialSyncServiceProvider = Provider<InitialSyncService>((ref) {
  return InitialSyncService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
