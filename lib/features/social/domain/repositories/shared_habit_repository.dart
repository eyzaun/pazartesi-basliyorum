import '../../../../shared/models/result.dart';
import '../entities/shared_habit.dart';

/// Repository interface for shared habit operations.
abstract class SharedHabitRepository {
  /// Share habit with a friend.
  Future<Result<SharedHabit>> shareHabit({
    required String habitId,
    required String friendId,
    bool canEdit = false,
  });

  /// Unshare habit.
  Future<Result<void>> unshareHabit(String sharedHabitId);

  /// Get habits shared by current user.
  Future<Result<List<SharedHabit>>> getSharedByMe(String userId);

  /// Get habits shared with current user.
  Future<Result<List<SharedHabit>>> getSharedWithMe(String userId);

  /// Stream of habits shared with user.
  Stream<List<SharedHabit>> watchSharedWithMe(String userId);

  /// Stream of habits shared by user.
  Stream<List<SharedHabit>> watchSharedByMe(String userId);
}
