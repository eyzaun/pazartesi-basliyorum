import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/result.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../models/friend_model.dart';

/// Implementation of FriendRepository.
class FriendRepositoryImpl implements FriendRepository {
  FriendRepositoryImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Future<Result<Friend>> sendFriendRequest(String friendId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return const Failure('Kullanıcı oturumu bulunamadı');
      }

      if (userId == friendId) {
        return const Failure('Kendinize arkadaşlık isteği gönderemezsiniz');
      }

      // Check if request already exists
      final existingQuery = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return const Failure('Bu kullanıcıya zaten arkadaşlık isteği gönderdıniz');
      }

      // Check reverse direction
      final reverseQuery = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: friendId)
          .where('friendId', isEqualTo: userId)
          .limit(1)
          .get();

      if (reverseQuery.docs.isNotEmpty) {
        return const Failure('Bu kullanıcıyla zaten arkadaşsınız veya bekleyen bir istek var');
      }

      // Get friend user info
      final friendDoc = await _firestore.collection('users').doc(friendId).get();
      if (!friendDoc.exists) {
        return const Failure('Kullanıcı bulunamadı');
      }

      final friendData = friendDoc.data()!;
      
      // Create friendship document
      final docRef = _firestore.collection('friendships').doc();
      final friendship = FriendModel(
        id: docRef.id,
        userId: userId,
        friendId: friendId,
        friendUsername: friendData['username'] as String,
        friendDisplayName: friendData['displayName'] as String,
        friendPhotoUrl: friendData['photoURL'] as String?,
        status: FriendStatus.pending,
        createdAt: DateTime.now(),
      );

      await docRef.set(friendship.toFirestore());

      return Success(friendship.toEntity());
    } catch (e) {
      return Failure('Arkadaşlık isteği gönderilemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> acceptFriendRequest(String friendshipId) async {
    try {
      await _firestore.collection('friendships').doc(friendshipId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Success(null);
    } catch (e) {
      return Failure('İstek kabul edilemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> rejectFriendRequest(String friendshipId) async {
    try {
      // Delete the request instead of marking rejected
      await _firestore.collection('friendships').doc(friendshipId).delete();

      return const Success(null);
    } catch (e) {
      return Failure('İstek reddedilemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> removeFriend(String friendshipId) async {
    try {
      await _firestore.collection('friendships').doc(friendshipId).delete();

      return const Success(null);
    } catch (e) {
      return Failure('Arkadaş silinemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Friend>>> getFriends(String userId) async {
    try {
      // Get friends where user is userId and status is accepted
      final sentQuery = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // Get friends where user is friendId and status is accepted
      final receivedQuery = await _firestore
          .collection('friendships')
          .where('friendId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final friends = <Friend>[
        ...sentQuery.docs.map((doc) => FriendModel.fromDocument(doc).toEntity()),
        ...receivedQuery.docs.map((doc) => FriendModel.fromDocument(doc).toEntity()),
      ];

      return Success(friends);
    } catch (e) {
      return Failure('Arkadaşlar yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Friend>>> getPendingRequests(String userId) async {
    try {
      // Get requests where user is friendId (received requests)
      final query = await _firestore
          .collection('friendships')
          .where('friendId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      final requests = query.docs
          .map((doc) => FriendModel.fromDocument(doc).toEntity())
          .toList();

      return Success(requests);
    } catch (e) {
      return Failure('İstekler yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Friend>>> getSentRequests(String userId) async {
    try {
      // Get requests where user is userId (sent requests)
      final query = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      final requests = query.docs
          .map((doc) => FriendModel.fromDocument(doc).toEntity())
          .toList();

      return Success(requests);
    } catch (e) {
      return Failure('Gönderilen istekler yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Stream<List<Friend>> watchFriends(String userId) {
    // Watch both directions
    final sentStream = _firestore
        .collection('friendships')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();

    final receivedStream = _firestore
        .collection('friendships')
        .where('friendId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();

    return sentStream.asyncMap((sentSnapshot) async {
      final receivedSnapshot = await receivedStream.first;
      
      return [
        ...sentSnapshot.docs.map((doc) => FriendModel.fromDocument(doc).toEntity()),
        ...receivedSnapshot.docs.map((doc) => FriendModel.fromDocument(doc).toEntity()),
      ];
    });
  }

  @override
  Stream<List<Friend>> watchPendingRequests(String userId) {
    return _firestore
        .collection('friendships')
        .where('friendId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendModel.fromDocument(doc).toEntity())
            .toList());
  }
}

// Provider
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepositoryImpl(
    FirebaseFirestore.instance,
    firebase_auth.FirebaseAuth.instance,
  );
});
