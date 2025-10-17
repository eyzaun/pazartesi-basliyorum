import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend.dart';

/// Data model for Friend.
class FriendModel extends Friend {
  const FriendModel({
    required super.id,
    required super.userId,
    required super.friendId,
    required super.friendUsername,
    required super.friendDisplayName,
    required super.status,
    required super.createdAt,
    super.friendPhotoUrl,
    super.updatedAt,
    super.direction,
    super.requestedBy,
    super.acceptedAt,
  });

  /// Create from Firestore document.
  factory FriendModel.fromFirestore(Map<String, dynamic> json) {
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return FriendModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      friendUsername: json['friendUsername'] as String,
      friendDisplayName: json['friendDisplayName'] as String,
      friendPhotoUrl: json['friendPhotoUrl'] as String?,
      status: _statusFromString(json['status'] as String),
      createdAt: parseTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(json['updatedAt']),
      direction: json['direction'] as String?,
      requestedBy: json['requestedBy'] as String?,
      acceptedAt: parseTimestamp(json['acceptedAt']),
    );
  }

  /// Create from DocumentSnapshot.
  factory FriendModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendModel.fromFirestore({...data, 'id': doc.id});
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    final data = {
      'userId': userId,
      'friendId': friendId,
      'friendUsername': friendUsername,
      'friendDisplayName': friendDisplayName,
      'friendPhotoUrl': friendPhotoUrl,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
    if (direction != null) {
      data['direction'] = direction;
    }
    if (requestedBy != null) {
      data['requestedBy'] = requestedBy;
    }
    if (acceptedAt != null) {
      data['acceptedAt'] = Timestamp.fromDate(acceptedAt!);
    }
    return data;
  }

  /// Convert to entity.
  Friend toEntity() => this;

  static FriendStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return FriendStatus.pending;
      case 'accepted':
        return FriendStatus.accepted;
      case 'rejected':
        return FriendStatus.rejected;
      default:
        return FriendStatus.pending;
    }
  }

  static String _statusToString(FriendStatus status) {
    switch (status) {
      case FriendStatus.pending:
        return 'pending';
      case FriendStatus.accepted:
        return 'accepted';
      case FriendStatus.rejected:
        return 'rejected';
    }
  }
}
