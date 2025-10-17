import 'dart:async';

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

  CollectionReference<Map<String, dynamic>> get _friendships =>
      _firestore.collection('friendships');

  String _friendshipDocId(String ownerId, String friendId) =>
      '${ownerId}_$friendId';

  String _readString(Map<String, dynamic> data, String key,
          [String fallback = '']) =>
      data[key] as String? ?? fallback;

  String? _readPhoto(Map<String, dynamic> data) =>
      data['photoURL'] as String? ?? data['photoUrl'] as String?;

  FriendStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return FriendStatus.accepted;
      case 'rejected':
        return FriendStatus.rejected;
      default:
        return FriendStatus.pending;
    }
  }

  String _statusToString(FriendStatus status) {
    switch (status) {
      case FriendStatus.accepted:
        return 'accepted';
      case FriendStatus.rejected:
        return 'rejected';
      case FriendStatus.pending:
        return 'pending';
    }
  }

  Future<void> _migrateLegacyFriendship(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    if (data == null) return;
    if (data.containsKey('direction')) return;

    final ownerId = _readString(data, 'userId');
    final friendId = _readString(data, 'friendId');
    if (ownerId.isEmpty || friendId.isEmpty) {
      return;
    }

    final ownerSnapshot =
        await _firestore.collection('users').doc(ownerId).get();
    final friendSnapshot =
        await _firestore.collection('users').doc(friendId).get();
    if (!ownerSnapshot.exists || !friendSnapshot.exists) {
      return;
    }

    final ownerData = ownerSnapshot.data()!;
    final friendData = friendSnapshot.data()!;
    final status = _parseStatus(data['status'] as String?);
    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);

    final ownerDirection =
        status == FriendStatus.accepted ? 'accepted' : 'outgoing';
    final friendDirection =
        status == FriendStatus.accepted ? 'accepted' : 'incoming';

    final ownerUpdate = <String, dynamic>{
      'friendUsername': _readString(friendData, 'username'),
      'friendDisplayName': _readString(
        friendData,
        'displayName',
        _readString(friendData, 'username'),
      ),
      'friendPhotoUrl': _readPhoto(friendData),
      'direction': ownerDirection,
      'requestedBy': ownerId,
      'updatedAt': timestamp,
    };
    if (status == FriendStatus.accepted && data['acceptedAt'] == null) {
      ownerUpdate['acceptedAt'] = timestamp;
    }

    final batch = _firestore.batch();
    batch.update(doc.reference, ownerUpdate);

    final counterpartRef =
        _friendships.doc(_friendshipDocId(friendId, ownerId));
    final counterpartSnap = await counterpartRef.get();

    if (counterpartSnap.exists) {
      final counterpartData = counterpartSnap.data() ?? {};
      final update = <String, dynamic>{
        'updatedAt': timestamp,
      };
      if (!counterpartData.containsKey('direction')) {
        update['direction'] = friendDirection;
      }
      if (!counterpartData.containsKey('requestedBy')) {
        update['requestedBy'] = ownerId;
      }
      if (!counterpartData.containsKey('friendUsername')) {
        update['friendUsername'] = _readString(ownerData, 'username');
        update['friendDisplayName'] = _readString(
          ownerData,
          'displayName',
          _readString(ownerData, 'username'),
        );
        update['friendPhotoUrl'] = _readPhoto(ownerData);
      }
      if (status == FriendStatus.accepted &&
          counterpartData['acceptedAt'] == null) {
        update['acceptedAt'] = timestamp;
      }
      batch.update(counterpartRef, update);
    } else {
      batch.set(counterpartRef, {
        'userId': friendId,
        'friendId': ownerId,
        'friendUsername': _readString(ownerData, 'username'),
        'friendDisplayName': _readString(
          ownerData,
          'displayName',
          _readString(ownerData, 'username'),
        ),
        'friendPhotoUrl': _readPhoto(ownerData),
        'status': _statusToString(status),
        'direction': friendDirection,
        'requestedBy': ownerId,
        'createdAt': data['createdAt'] ?? timestamp,
        'updatedAt': timestamp,
        if (status == FriendStatus.accepted) 'acceptedAt': timestamp,
      });
    }

    await batch.commit();
  }

  Future<void> _ensureLegacyEntriesForUser(String userId) async {
    final futures = <Future<void>>[];

    final ownerSnapshot =
        await _friendships.where('userId', isEqualTo: userId).get();
    for (final doc in ownerSnapshot.docs) {
      final data = doc.data();
      if (!data.containsKey('direction')) {
        futures.add(_migrateLegacyFriendship(doc));
      }
    }

    final friendSnapshot =
        await _friendships.where('friendId', isEqualTo: userId).get();
    for (final doc in friendSnapshot.docs) {
      final data = doc.data();
      if (!data.containsKey('direction')) {
        futures.add(_migrateLegacyFriendship(doc));
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

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

      final outgoingId = _friendshipDocId(userId, friendId);
      final incomingId = _friendshipDocId(friendId, userId);

      final outgoingDoc = await _friendships.doc(outgoingId).get();
      if (outgoingDoc.exists) {
        final status = _readString(outgoingDoc.data()!, 'status', 'pending');
        if (status == 'accepted') {
          return const Failure('Bu kullanıcıyla zaten arkadaşsınız');
        }
        return const Failure('Bu kullanıcıya zaten arkadaşlık isteği gönderdiniz');
      }

      final incomingDoc = await _friendships.doc(incomingId).get();
      if (incomingDoc.exists) {
        final status = _readString(incomingDoc.data()!, 'status', 'pending');
        if (status == 'accepted') {
          return const Failure('Bu kullanıcıyla zaten arkadaşsınız');
        }
        return const Failure('Bu kullanıcıdan bekleyen bir isteğiniz var');
      }

      // Get current user profile
      final senderDoc = await _firestore.collection('users').doc(userId).get();
      if (!senderDoc.exists) {
        return const Failure('Kullanıcı bulunamadı');
      }
      final senderData = senderDoc.data()!;

      // Get friend user profile
      final friendDoc = await _firestore.collection('users').doc(friendId).get();
      if (!friendDoc.exists) {
        return const Failure('Kullanıcı bulunamadı');
      }
      final friendData = friendDoc.data()!;

      final now = DateTime.now();
      final createdAt = Timestamp.fromDate(now);

      final outgoingData = {
        'userId': userId,
        'friendId': friendId,
        'friendUsername': _readString(friendData, 'username'),
        'friendDisplayName': _readString(
          friendData,
          'displayName',
          _readString(friendData, 'username'),
        ),
        'friendPhotoUrl': _readPhoto(friendData),
        'status': 'pending',
        'direction': 'outgoing',
        'requestedBy': userId,
        'createdAt': createdAt,
        'updatedAt': createdAt,
      };

      final incomingData = {
        'userId': friendId,
        'friendId': userId,
        'friendUsername': _readString(senderData, 'username'),
        'friendDisplayName': _readString(
          senderData,
          'displayName',
          _readString(senderData, 'username'),
        ),
        'friendPhotoUrl': _readPhoto(senderData),
        'status': 'pending',
        'direction': 'incoming',
        'requestedBy': userId,
        'createdAt': createdAt,
        'updatedAt': createdAt,
      };

      final batch = _firestore.batch();
      batch.set(_friendships.doc(outgoingId), outgoingData);
      batch.set(_friendships.doc(incomingId), incomingData);
      await batch.commit();

      final friendEntity = Friend(
        id: outgoingId,
        userId: userId,
        friendId: friendId,
        friendUsername: outgoingData['friendUsername'] as String,
        friendDisplayName: outgoingData['friendDisplayName'] as String,
        friendPhotoUrl: outgoingData['friendPhotoUrl'] as String?,
        status: FriendStatus.pending,
        createdAt: now,
        updatedAt: now,
        direction: 'outgoing',
        requestedBy: userId,
      );

      return Success(friendEntity);
    } catch (e) {
      return Failure('Arkadaşlık isteği gönderilemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> acceptFriendRequest(String friendshipId) async {
    try {
      final snapshot = await _friendships.doc(friendshipId).get();
      if (!snapshot.exists) {
        return const Failure('İstek bulunamadı');
      }

      final data = snapshot.data()!;
      final userId = data['userId'] as String;
      final friendId = data['friendId'] as String;
      final counterpartId = _friendshipDocId(friendId, userId);
      final counterpartRef = _friendships.doc(counterpartId);
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      final batch = _firestore.batch();
      batch.update(snapshot.reference, {
        'status': 'accepted',
        'direction': 'accepted',
        'updatedAt': timestamp,
        'acceptedAt': timestamp,
      });

      final counterpartSnap = await counterpartRef.get();
      if (counterpartSnap.exists) {
        batch.update(counterpartRef, {
          'status': 'accepted',
          'direction': 'accepted',
          'updatedAt': timestamp,
          'acceptedAt': timestamp,
        });
      } else {
        // Legacy fallback: create counterpart entry if it doesn't exist.
        final userProfile =
            await _firestore.collection('users').doc(userId).get();
        final friendProfile =
            await _firestore.collection('users').doc(friendId).get();

        if (userProfile.exists && friendProfile.exists) {
          final ownerData = userProfile.data()!;

          batch.set(counterpartRef, {
            'userId': friendId,
            'friendId': userId,
            'friendUsername': _readString(ownerData, 'username'),
            'friendDisplayName': _readString(
              ownerData,
              'displayName',
              _readString(ownerData, 'username'),
            ),
            'friendPhotoUrl': _readPhoto(ownerData),
            'status': 'accepted',
            'direction': 'accepted',
            'requestedBy': data['requestedBy'] ?? friendId,
            'createdAt': data['createdAt'] ?? timestamp,
            'updatedAt': timestamp,
            'acceptedAt': timestamp,
          });
        }
      }

      await batch.commit();

      return const Success(null);
    } catch (e) {
      return Failure('İstek kabul edilemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> rejectFriendRequest(String friendshipId) async {
    try {
      final snapshot = await _friendships.doc(friendshipId).get();
      if (!snapshot.exists) {
        return const Success(null);
      }

      final data = snapshot.data()!;
      final ownerId = data['userId'] as String;
      final friendId = data['friendId'] as String;
      final counterpartId = _friendshipDocId(friendId, ownerId);

      final batch = _firestore.batch();
      batch.delete(snapshot.reference);
      batch.delete(_friendships.doc(counterpartId));
      await batch.commit();

      return const Success(null);
    } catch (e) {
      return Failure('İstek reddedilemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> removeFriend(String friendshipId) async {
    try {
      final snapshot = await _friendships.doc(friendshipId).get();
      if (!snapshot.exists) {
        return const Failure('Arkadaşlık kaydı bulunamadı');
      }

      final data = snapshot.data()!;
      final ownerId = data['userId'] as String;
      final friendId = data['friendId'] as String;
      final counterpartId = _friendshipDocId(friendId, ownerId);

      final batch = _firestore.batch();
      batch.delete(snapshot.reference);
      batch.delete(_friendships.doc(counterpartId));
      await batch.commit();

      return const Success(null);
    } catch (e) {
      return Failure('Arkadaş silinemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Friend>>> getFriends(String userId) async {
    try {
      await _ensureLegacyEntriesForUser(userId);

      final query = await _friendships
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final friends = query.docs
          .map((doc) => FriendModel.fromDocument(doc).toEntity())
          .toList();

      return Success(friends);
    } catch (e) {
      return Failure('Arkadaşlar yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Friend>>> getPendingRequests(String userId) async {
    try {
      await _ensureLegacyEntriesForUser(userId);

      final query = await _friendships
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .where('direction', isEqualTo: 'incoming')
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
      await _ensureLegacyEntriesForUser(userId);

      final query = await _friendships
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .where('direction', isEqualTo: 'outgoing')
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
    unawaited(_ensureLegacyEntriesForUser(userId));

    return _friendships
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FriendModel.fromDocument(doc).toEntity()).toList());
  }

  @override
  Stream<List<Friend>> watchPendingRequests(String userId) {
    unawaited(_ensureLegacyEntriesForUser(userId));

    return _friendships
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .where('direction', isEqualTo: 'incoming')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendModel.fromDocument(doc).toEntity())
            .toList(),);
  }
}

// Provider
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepositoryImpl(
    FirebaseFirestore.instance,
    firebase_auth.FirebaseAuth.instance,
  );
});
