import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitialSyncProgress {
  final String message;
  final double progress;

  const InitialSyncProgress(this.message, this.progress);
}

class InitialSyncException implements Exception {
  final String message;
  InitialSyncException(this.message);

  @override
  String toString() => message;
}

class InitialSyncService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  InitialSyncService(this._firestore, this._auth);

  Future<void> performInitialSync({
    required Function(InitialSyncProgress) onProgress,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw InitialSyncException('Kullanıcı oturumu bulunamadı');
    }

    try {
      onProgress(const InitialSyncProgress('Başlıyor...', 0.0));

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

      onProgress(const InitialSyncProgress('Tamamlandı!', 1.0));
    } catch (e) {
      throw InitialSyncException('İlk senkronizasyon başarısız: $e');
    }
  }

  Future<void> _downloadHabits(String userId) async {
    final snapshot = await _firestore
        .collection('habits')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    // Habits are already cached by Firestore
    // Just triggering the download
    print('Downloaded ${snapshot.docs.length} habits');
  }

  Future<void> _downloadLogs(String userId) async {
    // Download logs from last 90 days
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));

    final snapshot = await _firestore
        .collection('habit_logs')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: ninetyDaysAgo)
        .get();

    print('Downloaded ${snapshot.docs.length} logs');
  }

  Future<void> _downloadAchievements(String userId) async {
    final snapshot = await _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .get();

    print('Downloaded ${snapshot.docs.length} achievements');
  }

  Future<void> _downloadUserProfile(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!snapshot.exists) {
      throw InitialSyncException('Kullanıcı profili bulunamadı');
    }

    print('Downloaded user profile');
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
