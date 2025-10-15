import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/friend_repository_impl.dart';
import '../../data/repositories/habit_activity_repository_impl.dart';
import '../../data/repositories/shared_habit_repository_impl.dart';
import '../../data/repositories/user_search_repository.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/habit_activity.dart';
import '../../domain/entities/shared_habit.dart';

// ============================================================================
// Friends
// ============================================================================

/// Friends list provider (accepted friends).
final friendsProvider = StreamProvider<List<Friend>>((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  final user = authState.value;
  if (user == null) return Stream.value([]);

  return repository.watchFriends(user.id);
});

/// Pending friend requests provider (received).
final pendingRequestsProvider = StreamProvider<List<Friend>>((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  final user = authState.value;
  if (user == null) return Stream.value([]);

  return repository.watchPendingRequests(user.id);
});

/// Send friend request.
final sendFriendRequestProvider = Provider((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.sendFriendRequest;
});

/// Accept friend request.
final acceptFriendRequestProvider = Provider((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.acceptFriendRequest;
});

/// Reject friend request.
final rejectFriendRequestProvider = Provider((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.rejectFriendRequest;
});

/// Remove friend.
final removeFriendProvider = Provider((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.removeFriend;
});

// ============================================================================
// Shared Habits
// ============================================================================

/// Shared habits (shared with me).
final sharedWithMeProvider = StreamProvider<List<SharedHabit>>((ref) {
  final repository = ref.watch(sharedHabitRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  final user = authState.value;
  if (user == null) return Stream.value([]);

  return repository.watchSharedWithMe(user.id);
});

/// Shared habits (shared by me).
final sharedByMeProvider = StreamProvider<List<SharedHabit>>((ref) {
  final repository = ref.watch(sharedHabitRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  final user = authState.value;
  if (user == null) return Stream.value([]);

  return repository.watchSharedByMe(user.id);
});

/// Share habit.
final shareHabitProvider = Provider((ref) {
  final repository = ref.watch(sharedHabitRepositoryProvider);
  return repository.shareHabit;
});

/// Unshare habit.
final unshareHabitProvider = Provider((ref) {
  final repository = ref.watch(sharedHabitRepositoryProvider);
  return repository.unshareHabit;
});

// ============================================================================
// User Search
// ============================================================================

/// Search users by username.
final userSearchProvider = Provider((ref) {
  final repository = ref.watch(userSearchRepositoryProvider);
  return repository.searchByUsername;
});

/// Get user by username.
final getUserByUsernameProvider = Provider((ref) {
  final repository = ref.watch(userSearchRepositoryProvider);
  return repository.getUserByUsername;
});

// ============================================================================
// Activity Feed
// ============================================================================

/// Activity feed provider (friends' activities).
final activityFeedProvider = FutureProvider<List<HabitActivity>>((ref) async {
  final repository = ref.watch(habitActivityRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  final user = authState.value;
  if (user == null) return [];

  final result = await repository.getActivityFeed(user.id);
  return result is Success<List<HabitActivity>> ? result.data : [];
});
