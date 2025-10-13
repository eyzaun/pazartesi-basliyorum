import '../../../../shared/models/result.dart';
import '../entities/friend.dart';

/// Repository interface for friend operations.
abstract class FriendRepository {
  /// Send friend request to user.
  Future<Result<Friend>> sendFriendRequest(String friendId);

  /// Accept friend request.
  Future<Result<void>> acceptFriendRequest(String friendshipId);

  /// Reject friend request.
  Future<Result<void>> rejectFriendRequest(String friendshipId);

  /// Remove friend.
  Future<Result<void>> removeFriend(String friendshipId);

  /// Get all friends (accepted).
  Future<Result<List<Friend>>> getFriends(String userId);

  /// Get pending friend requests (received).
  Future<Result<List<Friend>>> getPendingRequests(String userId);

  /// Get sent friend requests.
  Future<Result<List<Friend>>> getSentRequests(String userId);

  /// Stream of friends.
  Stream<List<Friend>> watchFriends(String userId);

  /// Stream of pending requests.
  Stream<List<Friend>> watchPendingRequests(String userId);
}
