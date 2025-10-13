/// Friend entity for social features.
class Friend {
  const Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendUsername,
    required this.friendDisplayName,
    required this.status,
    required this.createdAt,
    this.friendPhotoUrl,
    this.updatedAt,
  });

  final String id;
  final String userId; // Who sent/received the request
  final String friendId; // The other user
  final String friendUsername;
  final String friendDisplayName;
  final String? friendPhotoUrl;
  final FriendStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? friendUsername,
    String? friendDisplayName,
    String? friendPhotoUrl,
    FriendStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendUsername: friendUsername ?? this.friendUsername,
      friendDisplayName: friendDisplayName ?? this.friendDisplayName,
      friendPhotoUrl: friendPhotoUrl ?? this.friendPhotoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Friend request/connection status.
enum FriendStatus {
  pending, // Request sent, waiting for response
  accepted, // Request accepted, now friends
  rejected, // Request rejected
}
