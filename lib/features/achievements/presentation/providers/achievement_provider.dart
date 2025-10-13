import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/achievement_service.dart';
import '../../domain/entities/achievement.dart';

/// Provider for UUID generator (reuse from habits).
final achievementUuidProvider = Provider<Uuid>((ref) => const Uuid());

/// Provider for achievement service.
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService(
    ref.watch(firestoreProvider),
    ref.watch(achievementUuidProvider),
  );
});

/// Provider for user's achievements.
final userAchievementsProvider =
    StreamProvider.family<List<Achievement>, String>(
  (ref, userId) {
    return ref.watch(achievementServiceProvider).watchUserAchievements(userId);
  },
);

/// Provider for achievement count.
final achievementCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final achievementsAsync = ref.watch(userAchievementsProvider(userId));
  return achievementsAsync.when(
    data: (achievements) => achievements.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Action notifier for achievements.
class AchievementActionNotifier extends StateNotifier<AchievementActionState> {
  AchievementActionNotifier(this._service)
      : super(const AchievementActionState());

  final AchievementService _service;

  /// Check and unlock achievements after habit completion.
  Future<List<Achievement>> checkAchievements({
    required String userId,
    required int totalCompletions,
    required int currentStreak,
    required int longestStreak,
    required bool isFirstCompletion,
    DateTime? completionTime,
    String? habitId,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final newAchievements = await _service.checkAndUnlockAchievements(
        userId: userId,
        totalCompletions: totalCompletions,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        isFirstCompletion: isFirstCompletion,
        completionTime: completionTime,
        habitId: habitId,
      );

      state = state.copyWith(
        isLoading: false,
        lastUnlockedAchievements: newAchievements,
      );

      return newAchievements;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return [];
    }
  }

  /// Clear last unlocked achievements.
  void clearLastUnlocked() {
    state = state.copyWith(lastUnlockedAchievements: []);
  }
}

/// State for achievement actions.
class AchievementActionState {
  const AchievementActionState({
    this.isLoading = false,
    this.error,
    this.lastUnlockedAchievements = const [],
  });

  final bool isLoading;
  final String? error;
  final List<Achievement> lastUnlockedAchievements;

  AchievementActionState copyWith({
    bool? isLoading,
    String? error,
    List<Achievement>? lastUnlockedAchievements,
  }) {
    return AchievementActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUnlockedAchievements:
          lastUnlockedAchievements ?? this.lastUnlockedAchievements,
    );
  }
}

/// Provider for achievement actions.
final achievementActionProvider =
    StateNotifierProvider<AchievementActionNotifier, AchievementActionState>(
        (ref) {
  return AchievementActionNotifier(ref.watch(achievementServiceProvider));
});
