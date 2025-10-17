import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/sync_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/result.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../achievements/presentation/widgets/achievement_unlocked_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../social/data/repositories/friend_repository_impl.dart';
import '../../../social/data/repositories/habit_activity_repository_impl.dart';
import '../../../social/data/repositories/shared_habit_repository_impl.dart';
import '../../../social/utils/habit_summary.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../providers/habits_provider.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/streak_recovery_dialog.dart';
import 'habit_timer_screen.dart'; // Part 4: Timer screen

/// Today screen showing user's daily habits.
/// This is the main screen where users check in their habits.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with SingleTickerProviderStateMixin {
  bool _showCompleted = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Trigger sync when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitActionProvider.notifier).syncWithFirebase();
      _checkForBrokenStreaks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Check for broken streaks and show recovery dialog if applicable.
  Future<void> _checkForBrokenStreaks() async {
    if (!mounted) return; // Check if widget is still mounted
    
    final user = await ref.read(currentUserProvider.future);
    if (user == null || !mounted) return;

    final habitsAsync = await ref.read(habitsProvider(user.id).future);
    if (!mounted) return;

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayNormalized =
        DateTime(yesterday.year, yesterday.month, yesterday.day);

    // Check each habit for broken streak
    for (final habit in habitsAsync) {
      if (!mounted) return; // Check before each iteration
      
      // Skip habits created today or after yesterday
      // (they shouldn't have yesterday's log)
      final habitCreatedDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      if (habitCreatedDate.isAfter(yesterdayNormalized) ||
          habitCreatedDate.isAtSameMomentAs(DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ))) {
        continue; // Skip newly created habits
      }
      
      // Get logs for this habit
      final habitLogsResult =
          await ref.read(habitRepositoryProvider).getLogsForHabit(habit.id);
      if (habitLogsResult is! Success<List<HabitLog>> || !mounted) continue;

      final habitLogs = habitLogsResult.data;

      // Check if there's a log for yesterday
      final hasYesterdayLog = habitLogs.any((log) {
        final logDate = DateTime(log.date.year, log.date.month, log.date.day);
        return logDate.isAtSameMomentAs(yesterdayNormalized) && log.completed;
      });

      // If no log for yesterday, check if recovery is available
      if (!hasYesterdayLog && mounted) {
        final eligibilityAsync = await ref.read(
          streakRecoveryEligibilityProvider((
            habitId: habit.id,
            userId: user.id,
            missedDate: yesterday,
          ),).future,
        );
        
        if (!mounted) return;

        // Calculate current streak to show in dialog
        final statsResult = await ref
            .read(habitRepositoryProvider)
            .getHabitStatistics(habit.id);
        
        if (!mounted) return;
        
        final currentStreak = statsResult is Success<HabitStatistics>
            ? statsResult.data.currentStreak
            : 0;

        // Show recovery dialog if mounted
        if (mounted && eligibilityAsync.canRecover) {
          await _showStreakRecoveryDialog(
            habit: habit,
            userId: user.id,
            missedDate: yesterday,
            currentStreak: currentStreak,
            eligibility: eligibilityAsync,
          );
          break; // Only show one dialog at a time
        }
      }
    }
  }

  /// Show streak recovery dialog.
  Future<void> _showStreakRecoveryDialog({
    required Habit habit,
    required String userId,
    required DateTime missedDate,
    required int currentStreak,
    required eligibility,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreakRecoveryDialog(
        habit: habit,
        missedDate: missedDate,
        currentStreak: currentStreak,
        canRecover: eligibility.canRecover,
        reasonText: eligibility.reason,
        onRecover: () => Navigator.of(context).pop(true),
        onSkip: () => Navigator.of(context).pop(false),
      ),
    );

    if (result == true && mounted) {
      // User chose to recover
      final success =
          await ref.read(habitActionProvider.notifier).useStreakRecovery(
                habitId: habit.id,
                userId: userId,
                missedDate: missedDate,
              );

      if (success && mounted) {
        // Refresh habits to show updated streak
        await _refreshHabits();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Seri başarıyla kurtarıldı!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _refreshHabits() async {
    // Refresh habits from repository
    final user = await ref.read(currentUserProvider.future);
    if (user != null) {
      ref
        ..invalidate(habitsProvider(user.id))
        ..invalidate(todayLogsProvider(user.id));
    }

    // Sync with Firebase
    await ref.read(habitActionProvider.notifier).syncWithFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today),
        actions: [
          // Sync indicator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: SyncIndicator()),
          ),
          // Sync button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _refreshHabits,
            tooltip: 'Senkronize et',
          ),
          // Profile button
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.profile);
            },
            tooltip: l10n.profile,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bugün'),
            Tab(text: 'Günü Değil'),
          ],
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            // Guest mode or not logged in
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Misafir modundasınız',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(AppRouter.welcome);
                    },
                    child: Text(l10n.signIn),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildHabitsList(user.id, showScheduledOnly: true),
              _buildHabitsList(user.id, showScheduledOnly: false),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: _refreshHabits,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () async {
          final result =
              await Navigator.of(context).pushNamed(AppRouter.habitCreate);
          if (result == true && mounted) {
            // Refresh habits after creating new one
            unawaited(_refreshHabits());
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.createHabit),
      ),
    );
  }

  Widget _buildHabitsList(String userId, {required bool showScheduledOnly}) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsProvider(userId));
    final todayLogsAsync = ref.watch(todayLogsProvider(userId));
    final today = DateTime.now();

    return RefreshIndicator(
      onRefresh: _refreshHabits,
      child: habitsAsync.when(
        data: (allHabits) {
          // Filter habits based on schedule
          final habits = allHabits.where((habit) {
            // "Günü Değil" sekmesi sadece günlük+belirli günler olanları gösterir
            if (!showScheduledOnly) {
              // Sadece günlük + specific days olanları kontrol et
              if (habit.frequency.type != FrequencyType.daily) {
                return false; // Haftalık/özel sıklık "Günü Değil"de görünmez
              }
              final config = habit.frequency.config;
              if (config['everyDay'] == true) {
                return false; // "Her gün" olanlar "Günü Değil"de görünmez
              }
              // Bugün programda olmayan günlük alışkanlıkları göster
              return !habit.frequency.isScheduledForToday(today);
            } else {
              // "Bugün" sekmesi - bugün programda olanları göster
              return habit.frequency.isScheduledForToday(today);
            }
          }).toList();

          if (habits.isEmpty) {
            return EmptyStateWidget(
              icon: showScheduledOnly 
                  ? Icons.calendar_today_outlined 
                  : Icons.event_busy_outlined,
              title: showScheduledOnly ? l10n.noHabitsYet : 'Günü değil',
              message: showScheduledOnly 
                  ? l10n.createYourFirstHabit 
                  : 'Bugün programda olmayan alışkanlık yok',
              actionLabel: showScheduledOnly ? l10n.createHabit : null,
              onAction: showScheduledOnly ? () async {
                final result = await Navigator.of(context)
                    .pushNamed(AppRouter.habitCreate);
                if (result == true && mounted) {
                  unawaited(_refreshHabits());
                }
              } : null,
            );
          }

          return todayLogsAsync.when(
            data: (logs) {
              // Separate completed and pending habits
              final pending = habits.where((habit) {
                final log =
                    logs.where((l) => l.habitId == habit.id).firstOrNull;
                return log == null || !log.completed;
              }).toList();

              final completed = habits.where((habit) {
                final log =
                    logs.where((l) => l.habitId == habit.id).firstOrNull;
                return log != null && log.completed;
              }).toList();

              // Group pending habits by time section
              final morningHabits = <Habit>[];
              final afternoonHabits = <Habit>[];
              final eveningHabits = <Habit>[];
              final allDayHabits = <Habit>[];

              for (final habit in pending) {
                final section = _getTimeSection(habit);
                switch (section) {
                  case 'Sabah':
                    morningHabits.add(habit);
                    break;
                  case 'Öğleden Sonra':
                    afternoonHabits.add(habit);
                    break;
                  case 'Akşam':
                    eveningHabits.add(habit);
                    break;
                  case 'Gün Boyu':
                    allDayHabits.add(habit);
                    break;
                }
              }

              // Calculate current streak (placeholder - will be calculated from logs)
              const currentStreak = 0;

              return CustomScrollView(
                slivers: [
                  // Date Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateTime.now().toFormattedDate(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DailyProgressCard(
                            completedCount: completed.length,
                            totalCount: habits.length,
                            currentStreak: currentStreak,
                            onTap: () {
                              // Navigate to statistics screen
                              Navigator.of(context)
                                  .pushNamed(AppRouter.statistics);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Morning section
                  if (morningHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '🌅 Sabah',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = morningHabits[index];
                            final log = logs
                                .where((l) => l.habitId == habit.id)
                                .firstOrNull;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: (data) =>
                                    _completeHabit(habit.id, userId, data),
                                onSkip: (data) =>
                                    _skipHabit(habit.id, userId, data),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                                onShare: () => _shareHabit(habit, userId),
                                onTimer: habit.isTimedHabit
                                    ? () => _openTimer(habit)
                                    : null, // Part 4: Timer
                                onRecoverStreak: () async {
                                  final yesterday = DateTime.now()
                                      .subtract(const Duration(days: 1));
                                  final eligibility = await ref.read(
                                    streakRecoveryEligibilityProvider((
                                      habitId: habit.id,
                                      userId: userId,
                                      missedDate: yesterday,
                                    ),).future,
                                  );

                                  final statsResult = await ref
                                      .read(habitRepositoryProvider)
                                      .getHabitStatistics(habit.id);
                                  final currentStreak =
                                      statsResult is Success<HabitStatistics>
                                          ? statsResult.data.currentStreak
                                          : 0;

                                  if (mounted) {
                                    await _showStreakRecoveryDialog(
                                      habit: habit,
                                      userId: userId,
                                      missedDate: yesterday,
                                      currentStreak: currentStreak,
                                      eligibility: eligibility,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                          childCount: morningHabits.length,
                        ),
                      ),
                    ),
                  ],

                  // Afternoon section
                  if (afternoonHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '☀️ Öğleden Sonra',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = afternoonHabits[index];
                            final log = logs
                                .where((l) => l.habitId == habit.id)
                                .firstOrNull;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: (data) =>
                                    _completeHabit(habit.id, userId, data),
                                onSkip: (data) =>
                                    _skipHabit(habit.id, userId, data),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                                onShare: () => _shareHabit(habit, userId),
                                onTimer: habit.isTimedHabit
                                    ? () => _openTimer(habit)
                                    : null, // Part 4: Timer
                              ),
                            );
                          },
                          childCount: afternoonHabits.length,
                        ),
                      ),
                    ),
                  ],

                  // Evening section
                  if (eveningHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '🌙 Akşam',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = eveningHabits[index];
                            final log = logs
                                .where((l) => l.habitId == habit.id)
                                .firstOrNull;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: (data) =>
                                    _completeHabit(habit.id, userId, data),
                                onSkip: (data) =>
                                    _skipHabit(habit.id, userId, data),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                                onShare: () => _shareHabit(habit, userId),
                                onTimer: habit.isTimedHabit
                                    ? () => _openTimer(habit)
                                    : null, // Part 4: Timer
                              ),
                            );
                          },
                          childCount: eveningHabits.length,
                        ),
                      ),
                    ),
                  ],

                  // All day section
                  if (allDayHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '📅 Gün Boyu',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = allDayHabits[index];
                            final log = logs
                                .where((l) => l.habitId == habit.id)
                                .firstOrNull;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: (data) =>
                                    _completeHabit(habit.id, userId, data),
                                onSkip: (data) =>
                                    _skipHabit(habit.id, userId, data),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                                onShare: () => _shareHabit(habit, userId),
                                onTimer: habit.isTimedHabit
                                    ? () => _openTimer(habit)
                                    : null, // Part 4: Timer
                              ),
                            );
                          },
                          childCount: allDayHabits.length,
                        ),
                      ),
                    ),
                  ],

                  // Completed section (collapsible)
                  if (completed.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showCompleted = !_showCompleted;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Row(
                            children: [
                              Icon(
                                _showCompleted
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '✅ Tamamlananlar (${completed.length})',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_showCompleted)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final habit = completed[index];
                              final log = logs
                                  .where((l) => l.habitId == habit.id)
                                  .firstOrNull;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HabitCard(
                                  habit: habit,
                                  log: log,
                                  onComplete: (data) =>
                                      _completeHabit(habit.id, userId, data),
                                  onSkip: (data) =>
                                      _skipHabit(habit.id, userId, data),
                                  onTap: () => _navigateToDetail(habit.id),
                                  onEdit: () => _editHabit(habit.id),
                                  onDelete: () =>
                                      _deleteHabit(habit.id, userId),
                                  onShare: () => _shareHabit(habit, userId),
                                  onTimer: habit.isTimedHabit
                                      ? () => _openTimer(habit)
                                      : null, // Part 4: Timer
                                ),
                              );
                            },
                            childCount: completed.length,
                          ),
                        ),
                      ),
                  ],

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(
              child: Text('Hata: $error'),
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: CustomErrorWidget(
            message: error.toString(),
            onRetry: _refreshHabits,
          ),
        ),
      ),
    );
  }

  String _getTimeSection(Habit habit) {
    // For now, we'll use category or name to determine time section
    // In the future, this could be based on a reminderTime field
    final name = habit.name.toLowerCase();
    final category = habit.category.toLowerCase();

    // Check for morning keywords
    if (name.contains('sabah') ||
        name.contains('morning') ||
        category.contains('sabah') ||
        name.contains('kahvaltı') ||
        name.contains('uyanmak')) {
      return 'Sabah';
    }

    // Check for evening keywords
    if (name.contains('akşam') ||
        name.contains('gece') ||
        name.contains('evening') ||
        name.contains('night') ||
        category.contains('akşam') ||
        name.contains('uyumak')) {
      return 'Akşam';
    }

    // Check for afternoon keywords
    if (name.contains('öğlen') ||
        name.contains('afternoon') ||
        category.contains('öğleden')) {
      return 'Öğleden Sonra';
    }

    // Default to all day
    return 'Gün Boyu';
  }

  Future<void> _completeHabit(
      String habitId, String userId, Map<String, dynamic> data,) async {
    final quality = data['quality'] as LogQuality?;
    final note = data['note'] as String?;
    final photo = data['photo'] as File?;
    final shareWithFriends = data['shareWithFriends'] as bool? ?? false;

    final success = await ref.read(habitActionProvider.notifier).completeHabit(
          habitId: habitId,
          userId: userId,
          quality: quality,
          note: note,
        );

    if (success && mounted) {
      // Share activity with friends if requested
      if (shareWithFriends) {
        // Get habit details from current habits list
        final habitsAsync = ref.read(habitsProvider(userId));
        
        habitsAsync.whenData((habits) {
            try {
              final habit = habits.firstWhere((h) => h.id == habitId);

              // Convert hex color string to int
              int habitColor;
              try {
                final hexColor = habit.color.replaceAll('#', '');
                habitColor = int.parse('FF$hexColor', radix: 16);
              } catch (e) {
                habitColor = 0xFF6200EA; // Default purple
              }

              final frequencyLabel = buildFrequencyLabel({
                'type': habit.frequency.type.value,
                'config': habit.frequency.config,
              });
              final goalLabel = buildGoalLabel({
                'isTimedHabit': habit.isTimedHabit,
                'targetDurationMinutes': habit.targetDurationMinutes,
              });

              // Share activity in background (don't block UI)
              unawaited(
                ref.read(habitActivityRepositoryProvider).shareActivity(
                  habitId: habit.id,
                  habitName: habit.name,
                  habitIcon: habit.icon,
                  habitColor: habitColor,
                  completedAt: DateTime.now(),
                  habitDescription: habit.description,
                  habitCategory: habit.category,
                  habitFrequencyLabel: frequencyLabel,
                  habitGoalLabel: goalLabel,
                  quality: quality?.toString().split('.').last,
                  note: note,
                  photo: photo,
                ),
              );
          } catch (e) {
            // Habit not found or error, silently fail
          }
        });
      }

      // Check for new achievements
      final state = ref.read(habitActionProvider);
      final newAchievements = state.lastUnlockedAchievements;

      unawaited(_refreshHabits());
      context.showSuccessSnackBar('Tamamlandı! 🎉');

      // Show achievement dialogs if any
      if (newAchievements.isNotEmpty && mounted) {
        for (final achievement in newAchievements) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            showAchievementUnlockedDialog(context, achievement);
            // Wait for user to close the dialog before showing next one
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }
    }
  }

  Future<void> _skipHabit(
      String habitId, String userId, Map<String, dynamic> data,) async {
    final reason = data['reason'] as String?;
    final note = data['note'] as String?;

    final success = await ref.read(habitActionProvider.notifier).skipHabit(
          habitId: habitId,
          userId: userId,
          skipReason: reason ?? 'Atlandı',
          note: note,
        );

    if (success && mounted) {
      unawaited(_refreshHabits());
      context.showSnackBar('Atlandı');
    }
  }

  void _navigateToDetail(String habitId) {
    Navigator.of(context).pushNamed(
      AppRouter.habitDetail,
      arguments: habitId,
    );
  }

  void _editHabit(String habitId) {
    Navigator.of(context)
        .pushNamed(
      AppRouter.habitEdit,
      arguments: habitId,
    )
        .then((result) {
      if (result == true && mounted) {
        unawaited(_refreshHabits());
      }
    });
  }

  Future<void> _deleteHabit(String habitId, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alışkanlığı Sil'),
        content:
            const Text('Bu alışkanlığı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(habitRepositoryProvider);
      final result = await repository.deleteHabit(habitId);

      if (result.isSuccess && mounted) {
        unawaited(_refreshHabits());
        context.showSuccessSnackBar('Alışkanlık silindi');
      } else if (result.isFailure && mounted) {
        context.showErrorSnackBar(result.errorOrNull ?? 'Silme başarısız');
      }
    }
  }

  Future<void> _shareHabit(Habit habit, String userId) async {
    // Get friends list
    final friendsResult = await ref.read(friendRepositoryProvider).getFriends(userId);
    
    if (friendsResult is Failure) {
      if (mounted) {
        context.showErrorSnackBar('Arkadaş listesi yüklenemedi');
      }
      return;
    }
    
    final friends = (friendsResult as Success).data;
    
    if (friends.isEmpty) {
      if (mounted) {
        context.showErrorSnackBar('Henüz arkadaşınız yok. Önce arkadaş ekleyin!');
      }
      return;
    }

    // Confirm sharing with all friends
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('"${habit.name}" alışkanlığını paylaş'),
        content: Text(
          'Bu alışkanlık tüm arkadaşlarınızla (${friends.length} kişi) paylaşılacak. Onayyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Paylaş'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Share habit with all friends
    int successCount = 0;
    int failureCount = 0;

    for (final friend in friends) {
      final shareResult = await ref.read(sharedHabitRepositoryProvider).shareHabit(
        habitId: habit.id,
        friendId: friend.friendId,
        canEdit: false,
      );

      if (shareResult is Success) {
        successCount++;
      } else {
        failureCount++;
      }
    }

    if (mounted) {
      if (successCount > 0) {
        context.showSuccessSnackBar(
          'Alışkanlık $successCount arkadaşınızla paylaşıldı!${failureCount > 0 ? ' ($failureCount başarısız)' : ''}',
        );
      } else {
        context.showErrorSnackBar('Alışkanlık paylaşılamadı');
      }
    }
  }

  /// Part 4: Open timer screen for timed habit
  Future<void> _openTimer(Habit habit) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => HabitTimerScreen(habit: habit),
      ),
    );
    
    // If habit was completed from timer, process it
    if (result != null && mounted) {
      final user = await ref.read(currentUserProvider.future);
      if (user != null) {
        await _completeHabit(habit.id, user.id, result);
      }
    }
  }
}
